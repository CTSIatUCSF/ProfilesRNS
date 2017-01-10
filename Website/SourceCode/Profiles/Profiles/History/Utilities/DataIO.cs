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
using System.Xml;
using System.Configuration;
using System.Web.Script.Serialization;
using Profiles.Framework.Utilities;

namespace Profiles.History.Utilities
{

    public class DataIO : Framework.Utilities.DataIO
    {

        private static readonly int activityCacheSize = 1000;
        private static readonly int cacheExpirationSeconds = 36000; // 10 hours
        private static readonly int chechForNewActivitiesSeconds = 60; // once a minute

        private readonly object syncLock = new object();
        private Random random = new Random();

        public List<Activity> GetActivity(Int64 lastActivityLogID, int count, bool declump)
        {
            List<Activity> activities = new List<Activity>();
            SortedList<Int64, Activity> cache = GetFreshCache();
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

            if (count > retval.Count)
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

        private SortedList<Int64, Activity> GetFreshCache()
        {
            SortedList<Int64, Activity> cache = (SortedList<Int64, Activity>)Framework.Utilities.Cache.FetchObject("ActivityHistory");
            object isFresh = Framework.Utilities.Cache.FetchObject("ActivityHistoryIsFresh");
            if (cache == null || cache.Count == 0)
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
                    SortedList<Int64, Activity> newActivities = GetRecentActivity(cache.Values[0].Id, activityCacheSize, false);
                    // in with the new
                    foreach (Activity activity in newActivities.Values)
                    {
                        cache.Add(activity.Id, activity);
                    }
                    // out with the old
                    while (cache.Count > activityCacheSize)
                    {
                        cache.RemoveAt(cache.Count - 1);
                    }
                }
                // look for new activities once every minute
                Framework.Utilities.Cache.SetWithTimeout("ActivityHistoryIsFresh", new object(), chechForNewActivitiesSeconds);
            }
            return cache;
        }

        private SortedList<Int64, Activity> GetRecentActivity(Int64 lastActivityLogID, int count, bool older)
        {
            SortedList<Int64, Activity> activities = new SortedList<Int64, Activity>(new ReverseComparer());

            string sql = "SELECT top " + count + "  i.activityLogID," +
                            "p.personid,n.nodeid,p.firstname,p.lastname," +
                            "i.methodName,i.property,cp._PropertyLabel as propertyLabel,i.param1,i.param2,i.createdDT " +
                            "FROM [Framework.].[Log.Activity] i " +
                            "LEFT OUTER JOIN [Profile.Data].[Person] p ON i.personId = p.personID " +
                            "LEFT OUTER JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId and n.[class] = 'http://xmlns.com/foaf/0.1/Person' " +
                            "LEFT OUTER JOIN [Ontology.].[ClassProperty] cp ON cp.Property = i.property  and cp.Class = 'http://xmlns.com/foaf/0.1/Person' " +
                            "where p.IsActive=1 and i.privacyCode=-1" +
                            (lastActivityLogID != -1 ? (" and i.activityLogID " + (older ? "< " : "> ") + lastActivityLogID) : "") +
                            " order by i.activityLogID desc";
            using (SqlDataReader reader = GetQueryOutputReader(sql))
            {
                while (reader.Read())
                {
                    try
                    {
                        string param1 = reader["param1"].ToString();
                        string param2 = reader["param2"].ToString();
                        string activityLogId = reader["activityLogId"].ToString();
                        string propertyLabel = reader["propertyLabel"].ToString();
                        string personid = reader["personid"].ToString();
                        string nodeid = reader["nodeid"].ToString();
                        string firstname = reader["firstname"].ToString();
                        string lastname = reader["lastname"].ToString();
                        string methodName = reader["methodName"].ToString();

                        string journalTitle = "";
                        string url = "";
                        string queryTitle = "";
                        string title = "";
                        string body = "";
                        if (param1 == "PMID")
                        {
                            url = "http://www.ncbi.nlm.nih.gov/pubmed/" + param2;
                            queryTitle = "SELECT JournalTitle FROM [Profile.Data].[Publication.PubMed.General] " +
                            "WHERE PMID = cast(" + param2 + " as int)";
                            journalTitle = GetStringValue(queryTitle, "JournalTitle");
                        }
                        if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddPublication") == 0)
                        {
                            title = "added a PubMed publication";
                            body = "added a publication from: " + journalTitle;
                        }
                        else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddCustomPublication") == 0)
                        {
                            title = "added a custom publication";
                            body = "added \"" + param1 + "\" into " + propertyLabel +
                                " section : " + param2;
                        }
                        else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.UpdateSecuritySetting") == 0)
                        {
                            title = "made a section visible";
                            body = "made \"" + propertyLabel + "\"public";
                        }
                        else if (methodName.IndexOf("Profiles.Edit.Utilities.DataIO.Add") == 0)
                        {
                            title = "added an item";
                            if (param1.Length != 0)
                            {
                                body = body = "added \"" + param1 + "\" into " + propertyLabel + " section";
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
                        else if (methodName.CompareTo("ProfilesGetNewHRAndPubs.Disambiguation") == 0)
                        {
                            title = "has a new PubMed publication";
                            body = "has a new publication listed from: " + journalTitle;
                        }
                        else if (methodName.CompareTo("ProfilesGetNewHRAndPubs.AddedToProfiles") == 0)
                        {
                            title = "added to Profiles";
                            body = "now has a Profile page";
                        }

                        // there are situations where a new person is loaded but we don't yet have them in the system
                        // best to skip them for now
                        if (!String.IsNullOrEmpty(title) && UCSFIDSet.ByNodeId.ContainsKey(Convert.ToInt64(nodeid)))
                        {

                            Activity act = new Activity
                            {
                                Id = Convert.ToInt64(activityLogId),
                                Message = body,
                                LinkUrl = url,
                                Title = title,
                                CreatedDT = Convert.ToDateTime(reader["CreatedDT"]),
                                CreatedById = activityLogId,
                                Profile = new Profile
                                {
                                    Name = firstname + " " + lastname,
                                    PersonId = Convert.ToInt32(personid),
                                    NodeID = Convert.ToInt64(nodeid),
                                    //  Nick, you might want this one
                                    //URL = Root.Domain + "/profile/" + nodeid  
                                    URL = Root.Domain + "/" + UCSFIDSet.ByNodeId[Convert.ToInt64(nodeid)].PrettyURL,
                                    Thumbnail = Root.Domain + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?person=" + personid + "&Thumbnail=True&Width=45"
                                }
                            };
                            activities.Add(act.Id, act);
                        }
                    }
                    catch (Exception e)
                    {
                        DebugLogging.Log(e.Message);
                    }
                }
            }
            return activities;
        }

        private SqlDataReader GetQueryOutputReader(string sql)
        {

            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;
            SqlConnection dbconnection = new SqlConnection(connstr);
            SqlCommand dbcommand = new SqlCommand(sql, dbconnection);
            SqlDataReader dbreader = null;
            dbconnection.Open();
            dbcommand.CommandTimeout = 5000;
            try
            {
                dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);
            }
            catch (Exception ex)
            { string dd = ex.Message; }
            return dbreader;
        }

        private string GetStringValue(string sql, string columnName)
        {
            string value = "";
            using (SqlDataReader reader = GetQueryOutputReader(sql))
            {
                if (reader.Read())
                {
                    value = reader[columnName].ToString();
                }
            }
            return value;
        }

    }
}
