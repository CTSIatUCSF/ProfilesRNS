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

        public List<Activity> GetRecentActivity(int cacheCapacity)
        {
            List<Activity> activities = new List<Activity>();

            string sql = "SELECT top " + cacheCapacity + "  i.activityLogID," +
                            "p.personid,n.nodeid,p.firstname,p.lastname," +
                            "i.methodName,i.property,cp._PropertyLabel as propertyLabel,i.param1,i.param2,i.createdDT " +
                            "FROM [Framework.].[Log.Activity] i " +
                            "LEFT OUTER JOIN [Profile.Data].[Person] p ON i.personId = p.personID " +
                            "LEFT OUTER JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId and n.[class] = 'http://xmlns.com/foaf/0.1/Person' "+ 
                            "LEFT OUTER JOIN [Ontology.].[ClassProperty] cp ON cp.Property = i.property " +
                            "where p.IsActive=1 and i.privacyCode=-1 " +
                            "order by i.activityLogID desc ";
            using (SqlDataReader reader = GetQueryOutputReader(sql))
            {
                while (reader.Read())
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

                    if (!String.IsNullOrEmpty(title))
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
                                //URL = "~/profile/" + nodeid  
                                URL = "~/" + UCSFIDSet.ByNodeId[Convert.ToInt64(nodeid)].PrettyURL
                            }
                        };
                        activities.Add(act);
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
