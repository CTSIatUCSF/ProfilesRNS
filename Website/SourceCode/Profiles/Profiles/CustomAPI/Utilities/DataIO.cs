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
using System.Web;
using Profiles.Framework.Utilities;

namespace Profiles.CustomAPI.Utilities
{
    public class PublicationDate
    {
        public string pubDate { get; set; }
    }

    public class DataIO : Framework.Utilities.DataIO
    {

        static readonly string PERSON = "Person";
        static readonly string DISAMBIGUATION = "Disambiguation";

        public UCSFIDSet GetPerson(HttpRequest request)
        {
            string Subject = request["Subject"];
            string PersonId = request["Person"];
            string EmployeeID = request["EmployeeID"];
            string FNO = request["FNO"];
            string PrettyURL = request["PrettyURL"];
            string UserName = request["UserName"];

            if (Subject != null)
            {
                return Framework.Utilities.UCSFIDSet.ByNodeId[Convert.ToInt64(Subject)];
            }
            else if (PrettyURL != null)
            {
                return Framework.Utilities.UCSFIDSet.ByPrettyURL[PrettyURL.ToLower()];
            }
            else if (PersonId != null)
            {
                return Framework.Utilities.UCSFIDSet.ByPersonId[Convert.ToInt32(PersonId)];
            }
            else if (FNO != null)
            {
                return Profiles.Framework.Utilities.UCSFIDSet.ByFNO[FNO.ToLower()];
            }
            else if (EmployeeID != null)
            {
                return Profiles.Framework.Utilities.UCSFIDSet.ByEmployeeID[EmployeeID];
            }
            else if (UserName != null)
            {
                return Profiles.Framework.Utilities.UCSFIDSet.ByUserName[UserName];
            }
            return null;
        }

        public string GetPublicationInclusionSource(int personId, string PMID)
        {
            if (PMID == null)
            {
                return PERSON;
            }
            return GetCount("select count(*) from  [Profile.Data].[Publication.Person.Add] where personId = " + personId + " and PMID = " + PMID) > 0 ? PERSON : DISAMBIGUATION;
        }

        public string ProcessPMID(string PMID)
        {
            string sql = "select cast(x as varchar(max)) from [Profile.Data].[Publication.PubMed.AllXML] where pmid = '" + PMID + "';";
            using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                if (sqldr.Read())
                {
                    return sqldr[0].ToString();
                }
            }
            return "";
        }


        private int GetCount(string sql)
        {
            Int32 cnt = 0;

            using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                if (sqldr.Read())
                {
                    cnt = Convert.ToInt32(sqldr[0].ToString());
                }
            }

            return cnt;
        }

        public string ProcessDateSQL(string dateSQL)
        {
            System.Text.StringBuilder sql = new System.Text.StringBuilder();
            string xmlstr = string.Empty;
            XmlDocument xmlrtn = new XmlDocument();

            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;


            sql.AppendLine(dateSQL);

            SqlConnection dbconnection = new SqlConnection(connstr);
            SqlCommand dbcommand = new SqlCommand();

            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;

            dbcommand.CommandText = sql.ToString();
            dbcommand.CommandTimeout = 5000;

            dbcommand.Connection = dbconnection;

            string dateStr = null;
            using (SqlDataReader dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection))
            {
                if (dbreader.Read())
                {
                    dateStr = dbreader[0].ToString();
                }
            }

            return dateStr != null ? Convert.ToDateTime(dateStr).ToShortDateString() : "";
        }

        public bool GetIsActive(int personid)
        {
            System.Text.StringBuilder sql = new System.Text.StringBuilder();
            string xmlstr = string.Empty;
            XmlDocument xmlrtn = new XmlDocument();

            bool isactive = false;

            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;


            sql.AppendLine("select p.IsActive from [Profile.Data].Person p with(nolock) where p.personid = " + personid);

            SqlConnection dbconnection = new SqlConnection(connstr);
            SqlCommand dbcommand = new SqlCommand();

            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;

            dbcommand.CommandText = sql.ToString();
            dbcommand.CommandTimeout = 5000;

            dbcommand.Connection = dbconnection;

            using (SqlDataReader dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection))
            {
                if (dbreader.Read())
                {
                    isactive = Convert.ToBoolean(dbreader[0].ToString());
                }
            }

            return isactive;
        }

        public string GetRejectedPMIDs(Int64 personid)
        {
            string retval = "";
            string sql = "select PMID from [Profile.Data].[Publication.Person.Exclude] WHERE PMID IS NOT NULL AND PersonID = " + personid;
            using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                while (sqldr.Read())
                {
                    retval += ", " + sqldr[0].ToString();
                }
            }
            return String.IsNullOrEmpty(retval) ? "" : retval.Substring(2);
        }

        public List<Dictionary<string, object>> GetRejectedPMIDsAsJSON(Int64 personid)
        {
            List<int> pmids = new List<int>();
            string sql = "select PMID from [Profile.Data].[Publication.Person.Exclude] WHERE PMID IS NOT NULL AND PersonID = " + personid;
            using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                while (sqldr.Read())
                {
                    pmids.Add(Convert.ToInt32(sqldr[0]));
                }
            }

            List<Dictionary<string, object>> retval = new List<Dictionary<string, object>>();
            foreach(int pmid in pmids)
            {
                retval.Add(GetPubMedPublication(pmid));
            }
            return retval;
        }

        private Dictionary<string, object> GetPubMedPublication(int pmid)
        {
            Dictionary<string, object> publication = new Dictionary<string, object>();
            Dictionary<string, string> publicationSource = new Dictionary<string, string>();
            string sql = "select [EntityName], [Reference], [EntityDate], [PubYear], [URL] from [Profile.Data].[vwPublication.Entity.InformationResource] where PMID = " + pmid;
            using (SqlDataReader sqldr = this.GetSQLDataReader("ProfilesDB", sql, CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                publicationSource["PublicationSourceName"] = "PubMed";
                publication["PublicationSource"] = publicationSource;
                publicationSource["PMID"] = "" + pmid;

                if (sqldr.Read())
                {
                    publication["Title"] = sqldr[0].ToString();
                    publication["Publication"] = sqldr[1].ToString();
                    publication["Date"] = sqldr[2].ToString();
                    publication["Year"] = sqldr[3].ToString();
                    publicationSource["PublicationSourceURL"] = sqldr[4].ToString();
                }
            }
            return publication;
        }
    }
}
