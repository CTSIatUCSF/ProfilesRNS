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

        public SqlDataReader GetQueryOutputReader(string sql)
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

        public string GetStringValue(string sql, string columnName)
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

    }
}
