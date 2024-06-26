/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Threading;
using Profiles.Framework.Utilities;

namespace Profiles.Activity.Utilities
{

    public class DataIO : Framework.Utilities.DataIO
    {

        private static readonly int activityCacheSize = 1000;
        private static readonly int cacheExpirationSeconds = 36000; // 10 hours
        private static readonly int chechForNewActivitiesSeconds = 60; // once a minute

        private static bool rebuildingCache = false;
        private static readonly object syncLock = new object();
        private static Random random = new Random();

        public List<Activity> GetActivity(Int64 lastActivityLogID, int count, bool declump)
        {
            List<Activity> activities = new List<Activity>();
            SortedList<Int64, Activity> cache = GetCache();
            // grab as many as you can from the cache
            if (lastActivityLogID == -1)
            {
                activities.AddRange(cache.Values);
            }
            else if (cache.IndexOfKey(lastActivityLogID) != -1)
            {
                activities.AddRange(cache.Values);
                activities.RemoveRange(0, cache.IndexOfKey(lastActivityLogID) + 1);
            }

            List<Activity> retval = activities;

            if (declump)
            {
                retval = GetUnclumpedSubset(activities, count);
            }
            else if (count < retval.Count)
            {
                retval.RemoveRange(count, activities.Count - count);
            }

            if (count > retval.Count && retval.Count > 0)
            {
                // we need to go to the DB to get more. If we are declumping, we don't know exacly how many more we need but we make a good guess
                // and loop as needed
                if (declump)
                {
                    while (count > retval.Count)
                    {
                        SortedList<Int64, Activity> newActivities = GetRecentActivity(activities[activities.Count - 1].Id, 10 * (count - retval.Count), true);
                        if (newActivities.Count == 0)
                        {
                            // nothing more to load, time to bail
                            break;
                        }
                        else
                        {
                            activities.AddRange(newActivities.Values);
                            retval = GetUnclumpedSubset(activities, count);
                        }
                    }
                }
                else
                {
                    retval.AddRange(GetRecentActivity(retval[retval.Count - 1].Id, count - retval.Count, true).Values);
                }
            }
            return retval;
        }

        // makes sure you do not get consecutive activites for the same person. Instead, just randomly pick one of the activities in the consecutive 'clump'
        private List<Activity> GetUnclumpedSubset(List<Activity> activities, int count)
        {
            int id = -1;
            List<Activity> clumpedList = new List<Activity>();
            List<Activity> subset = new List<Activity>();

            foreach (Activity activity in activities)
            {
                if (id != activity.Profile.PersonId)
                {
                    //grab a random one from the old clumpedList
                    if (clumpedList.Count > 0)
                    {
                        subset.Add(clumpedList[random.Next(0, clumpedList.Count)]);
                        if (subset.Count == count)
                        {
                            clumpedList.Clear();
                            break;
                        }
                    }
                    // start a new clump for the new person
                    clumpedList.Clear();
                    id = activity.Profile.PersonId;
                }
                clumpedList.Add(activity);
            }
            // add the last one if needed
            if (clumpedList.Count > 0)
            {
                subset.Add(clumpedList[random.Next(0, clumpedList.Count)]);
            }

            return subset;
        }

        private static SortedList<Int64, Activity> GetCache()
        {
            SortedList<Int64, Activity> cache = (SortedList<Int64, Activity>)Framework.Utilities.Cache.FetchObject("ActivityHistory");
            if (cache == null)
            {
                cache = new SortedList<Int64, Activity>();
            }
            // need to pull decision logic out of GetFreshCache someday but for now this is good enough
            if (!rebuildingCache)
            {
                // not completely thread safe but will cause no harm
                rebuildingCache = true;
                Thread cacheThread = new Thread(DataIO.RefreshCache);
                cacheThread.Start();
            }

            return cache;
        }

        private static void RefreshCache()
        {
            // just a temp thing to see if it helps
            DataIO data = new DataIO();
            data.GetFreshCache();
            rebuildingCache = false;
        }

        private SortedList<Int64, Activity> GetFreshCache()
        {
            SortedList<Int64, Activity> cache = (SortedList<Int64, Activity>)Framework.Utilities.Cache.FetchObject("ActivityHistory");
            object isFresh = Framework.Utilities.Cache.FetchObject("ActivityHistoryIsFresh");
            if (cache == null)
            {
                // Grab a whole new one. This is expensive and should be unnecessary if we manage getting new ones well, so we don't do this often
                cache = GetRecentActivity(-1, activityCacheSize, true);
                Framework.Utilities.Cache.SetWithTimeout("ActivityHistory", cache, cacheExpirationSeconds);
            }
            else if (isFresh == null)
            {
                lock (syncLock)
                {
                    // get new ones from the DB

                    Int64 lastActivityLogID = cache.Count == 0 ? -1 : cache.Values[0].Id;
                    SortedList<Int64, Activity> newActivities = GetRecentActivity(lastActivityLogID, activityCacheSize, false);

                    // in with the new
                    foreach (Activity activity in newActivities.Values)
                        cache.Add(activity.Id, activity);
                    // out with the old
                    while (cache.Count > activityCacheSize)
                        cache.RemoveAt(cache.Count - 1);
                }
                // look for new activities once every minute
                Framework.Utilities.Cache.SetWithTimeout("ActivityHistoryIsFresh", new object(), chechForNewActivitiesSeconds);
            }
            return cache;
        }

        private SortedList<Int64, Activity> GetRecentActivity(Int64 lastActivityLogID, int count, bool older)
        {
            SortedList<Int64, Activity> activities = new SortedList<Int64, Activity>(new ReverseComparer());
            bool getMore = true;

            while (getMore)
            {
                int foundCnt = 0;

                string sql = "SELECT top " + count + "  i.activityLogID," +
                                "p.personid,n.nodeid,p.firstname,p.lastname," +
                                "i.methodName,i.property,cp._PropertyLabel as propertyLabel,i.param1,i.param2,i.createdDT " +
                                "FROM [Framework.].[Log.Activity] i " +
                                "LEFT OUTER JOIN [Profile.Data].[Person] p ON i.personId = p.personID " +
                            "LEFT OUTER JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId and n.[class] = 'http://xmlns.com/foaf/0.1/Person' " +
                                "LEFT OUTER JOIN [Ontology.].[ClassProperty] cp ON cp.Property = i.property  and cp.Class = 'http://xmlns.com/foaf/0.1/Person' " +
                                "LEFT OUTER JOIN [RDF.].[Node] rn on [RDF.].fnValueHash(null, null, i.property) = rn.ValueHash " +
                            //"LEFT OUTER JOIN [RDF.].[Node] rn on i.property = rn.value COLLATE Latin1_General_Bin " +
                            "LEFT OUTER JOIN [RDF.Security].[NodeProperty] np on n.NodeID = np.NodeID and rn.NodeID = np.Property " +
                                "where p.IsActive=1 and (np.ViewSecurityGroup = -1 or (i.privacyCode = -1 and np.ViewSecurityGroup is null) or (i.privacyCode is null and np.ViewSecurityGroup is null))" +
                                (lastActivityLogID != -1 ? (" and i.activityLogID " + (older ? "<" : ">") + lastActivityLogID) : "") +
                                " order by i.activityLogID desc";
                using (SqlDataReader reader = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
                {
                    while (reader.Read())
                    {
                        foundCnt++;
                        try
                        {
                            string param1 = reader["param1"].ToString();
                            string param2 = reader["param2"].ToString();
                            string activityLogId = reader["activityLogId"].ToString();
                            string property = reader["property"].ToString();
                            string propertyLabel = reader["propertyLabel"].ToString();
                            string personid = reader["personid"].ToString();
                            string nodeid = reader["nodeid"].ToString();
                            string firstname = reader["firstname"].ToString();
                            string lastname = reader["lastname"].ToString();
                            string methodName = reader["methodName"].ToString();

                            lastActivityLogID = Convert.ToInt64(activityLogId);

                            string journalTitle = "";
                            string url = "";
                            string queryTitle = "";
                            string title = "";
                            string body = "";
                            if (param1 == "PMID" || param1 == "Add PMID")
                            {
                                url = "http://www.ncbi.nlm.nih.gov/pubmed/" + param2;
                                queryTitle = "SELECT JournalTitle FROM [Profile.Data].[Publication.PubMed.General] with(nolock) " +
                                                        "WHERE PMID = cast(" + param2 + " as int)";
                                journalTitle = GetStringValue(queryTitle, "JournalTitle");
                            }
                            if (property == "http://vivoweb.org/ontology/core#ResearcherRole")
                            {
                                queryTitle = "select AgreementLabel from [Profile.Data].[Funding.Role] r " +
                                                "join [Profile.Data].[Funding.Agreement] a " +
                                                "on r.FundingAgreementID = a.FundingAgreementID " +
                                                " and r.FundingRoleID = '" + param1 + "'";
                                journalTitle = GetStringValue(queryTitle, "AgreementLabel");
                            }
                            if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddPublication") == 0)
                            {
                                title = "added a PubMed publication";
                                body = "added a publication from: " + journalTitle;
                            }
                            else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddCustomPublication") == 0)
                            {
                                title = "added a custom publication";
                                if (param2.Length > 100) param2 = param2.Substring(0, 100) + "...";
                                body = "added \"" + param1 + "\" into " + propertyLabel +
                                    " section : " + param2;
                            }
                            else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.UpdateSecuritySetting") == 0)
                            {
                                title = "made a section visible";
                                body = "made \"" + propertyLabel + "\" public";
                            }
                            else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddUpdateFunding") == 0)
                            {
                                title = "added a research activity or funding";
                                body = "added a research activity or funding: " + journalTitle;
                            }
                            else if (methodName.CompareTo("[Profile.Data].[Funding.LoadDisambiguationResults]") == 0)
                            {
                                title = "has a new research activity or funding";
                                body = "has a new research activity or funding: " + journalTitle;
                            }
                            else if (property == "http://vivoweb.org/ontology/core#hasMemberRole")
                            {
                                queryTitle = "select GroupName from [Profile.Data].[vwGroup.General] where GroupNodeID = " + param1;
                                string groupName = GetStringValue(queryTitle, "GroupName");
                                title = "joined group: " + groupName;
                                body = "joined group: " + groupName;
                            }
                            else if (methodName.IndexOf("Profiles.Edit.Utilities.DataIO.Add") == 0)
                            {
                                title = "added an item";
                                if (param1.Length != 0)
                                {
                                    body = "added \"" + param1 + "\" into " + propertyLabel + " section";
                                }
                                else
                                {
                                    body = "added \"" + propertyLabel + "\" section";
                                }

                            }
                            else if (methodName.IndexOf("Profiles.Edit.Utilities.DataIO.Update") == 0)
                            {
                                title = "updated an item";
                                if (param1.Length != 0)
                                {
                                    body = "updated \"" + param1 + "\" in " + propertyLabel + " section";
                                }
                                else
                                {
                                    body = "updated \"" + propertyLabel + "\" section";
                                }
                            }
                            else if (methodName.CompareTo("[Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]") == 0 && param1.CompareTo("Add PMID") == 0)
                            {
                                title = "has a new PubMed publication";
                                body = "has a new publication listed from: " + journalTitle;
                            }
                            else if (methodName.CompareTo("[Profile.Import].[LoadProfilesData]") == 0 && param1.CompareTo("Person Insert") == 0)
                            {
                                title = "added to Profiles";
                                body = "now has a Profile page";
                            }
                            else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.ClaimOnePublication") == 0 && param1.CompareTo("PMID") == 0)
                            {
                                title = "confirmed a PubMed publication found by Profiles";
                                body = "confirmed a publication from: " + journalTitle;
                            }

                            // there are situations where a new person is loaded but we don't yet have them in the system
                            // best to skip them for now
                            if (!String.IsNullOrEmpty(title) && !String.IsNullOrEmpty(nodeid) && UCSFIDSet.ByNodeId[Convert.ToInt64(nodeid)] != null)
                            {
                                Activity act = new Activity
                                {
                                    Id = Convert.ToInt64(activityLogId),
                                    Message = body.Trim(),
                                    LinkUrl = url.Trim(),
                                    Title = title.Trim(),
                                    CreatedDT = Convert.ToDateTime(reader["CreatedDT"]),
                                    CreatedById = activityLogId,
                                    Profile = new Profile
                                    {
                                        Name = firstname.Trim() + " " + lastname.Trim(),
                                        PersonId = Convert.ToInt32(personid),
                                        NodeID = Convert.ToInt64(nodeid),
                                        URL = UCSFIDSet.ByNodeId[Convert.ToInt64(nodeid)].PrettyURL,
                                        Thumbnail = Brand.GetForSubject(Convert.ToInt64(nodeid)).BasePath + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=" + nodeid + "&Thumbnail=True&Width=45",
                                        InstitutionAbbreviation = UCSFIDSet.ByNodeId[Convert.ToInt64(nodeid)].Institution.GetAbbreviation()
                                    }
                                };
                                activities.Add(act.Id, act);

                                // dont' grab more than we need
                                if (activities.Count >= count)
                                {
                                    break;
                                }
                            }
                        }
                        catch (Exception e)
                        {
                            Framework.Utilities.DebugLogging.Log("Exception loading activities (have,lookingfor,found) = (" + activities.Count + "," +
                                count + "," + foundCnt + ") :" + e.Message + e.StackTrace);
                        }
                    }
                }
                //sometimes we need to look deeper
                if (older && activities.Count < count && foundCnt == count)
                {
                    getMore = true;
                }
                else
                {
                    getMore = false;
                }
            }

            return activities;
        }

        public string GetEditedCount()
        {
            string sql = "select count(*) from [UCSF.].[vwPerson] p " +
                            "join (select PersonID from [UCSF.].[vwPerson] i " +
                            "join (select distinct subject from [RDF.].Triple t " +
                            "join [RDF.].Node n on t.Predicate = n.NodeID and n.value in " +
                            "('http://profiles.catalyst.harvard.edu/ontology/prns#mainImage', 'http://vivoweb.org/ontology/core#awardOrHonor', " +
                            "'http://vivoweb.org/ontology/core#educationalTraining', 'http://vivoweb.org/ontology/core#freetextKeyword', 'http://vivoweb.org/ontology/core#overview')) t " +
                            "on " + (Brand.GetCurrentBrand().GetInstitution() == null ? "" : "i.InstitutionAbbreviation = '" + Brand.GetCurrentBrand().GetInstitution() + "' AND ") +
                            "i.NodeID = t.Subject union " +
                            "select distinct personid from [Profile.Data].[Publication.Person.Add] union " +
                            "select distinct personid from [Profile.Data].[Publication.Person.Exclude] as u) t " +
                            "on t.PersonID = p.PersonID " + GetBrandedJoin() + GetBrandedWhere(" and p.isactive = 1");

            return GetCount(sql);
        }

        public string GetProfilesCount()
        {
            return GetCount("select count(*) from [UCSF.].[vwPerson] p" + GetBrandedJoin() + GetBrandedWhere(" where p.isactive = 1"));
        }

        public string GetPublicationsCount()
        {
            string sql = "select (select count(distinct(PMID)) from [Profile.Data].[Publication.Person.Include] i join [UCSF.].[vwPerson] p on p.personid = i.personid " +
                                GetBrandedJoin() + GetBrandedWhere(" where i.PMID is not null and p.isactive = 1") + ") + " +
                                "(select count(distinct(MPID)) from [Profile.Data].[Publication.Person.Include] i join [UCSF.].[vwPerson] p on p.personid = i.personid " +
                                GetBrandedJoin() + GetBrandedWhere(" where i.MPID is not null and p.isactive = 1") + ")";
            return GetCount(sql);
        }

        private string GetBrandedJoin()
        {
            if (Brand.GetCurrentBrand() == null || String.IsNullOrEmpty(Brand.GetCurrentBrand().PersonFilter))
            {
                return "";
            }
            else
            {
                return " join [Profile.Data].[Person.FilterRelationship] r on p.personid = r.personid join [Profile.Data].[Person.Filter] f on r.personfilterid = f.personfilterid";
            }
        }

        private string GetBrandedWhere(string currentWhere)
        {
            if (Brand.GetCurrentBrand() != null && Brand.GetCurrentBrand().GetInstitution() != null)
            {
                return currentWhere + " and p.institutionabbreviation = '" + Brand.GetCurrentBrand().GetInstitution().GetAbbreviation() + "'";
            }
            else if (Brand.GetCurrentBrand() == null || String.IsNullOrEmpty(Brand.GetCurrentBrand().PersonFilter))
            {
                return currentWhere;
            }
            else
            {
                return currentWhere + " and f.personfilter = '" + Brand.GetCurrentBrand().PersonFilter + "'";
            }
        }

        private string GetCount(string sql)
        {
            string key = "Statistics: " + sql;
            // store this in the cache. Use the sql as part of the key
            string cnt = (string)Framework.Utilities.Cache.FetchObject(key);

            try
            {
                if (String.IsNullOrEmpty(cnt))
                {
                    using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
                    {
                        if (sqldr.Read())
                        {
                            cnt = sqldr[0].ToString();
                            Framework.Utilities.Cache.Set(key, cnt);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log("Exception in GetCount calling: " + sql);
                Framework.Utilities.DebugLogging.Log("Exception in GetCount: " + ex.Message);
                cnt = "...";
            }
            return cnt;
        }

        private string GetStringValue(string sql, string columnName)
        {
            string value = "";
            using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                if (sqldr.Read())
                {
                    value = sqldr[columnName].ToString();
                }
            }
            return value;
        }

    }
}
