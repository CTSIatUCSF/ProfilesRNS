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

namespace Profiles.About.Utilities
{

    public class DataIO : Framework.Utilities.DataIO
    {

        public int GetEditedCount()
        {
            string sql = "select count(*) from (" +
                "select distinct personid from [Profile.Data].[Person.Photo] union " +
                //"select distinct personid from narratives union " +
                //"select distinct personid from awards union " +
                //"select distinct personid from my_pubs_general union " +
                "select distinct personid from [Profile.Data].[Publication.Person.Add] union " +
                "select distinct personid from [Profile.Data].[Publication.Person.Exclude]) as u;";

            return GetCount(sql);
        }

        public int GetProfilesCount()
        {
            return GetCount("select count(*) from [Profile.Data].[Person] where isactive = 1;");
        }

        public int GetPublicationsCount()
        {
            string sql = "select (select count(distinct(PMID)) from [Profile.Data].[Publication.Person.Include] i join [Profile.Data].[Person] p on p.personid = i.personid where PMID is not null and isactive = 1) + " +
                                "(select count(distinct(MPID)) from [Profile.Data].[Publication.Person.Include] i join [Profile.Data].[Person] p on p.personid = i.personid where MPID is not null and isactive = 1);";
            return GetCount(sql);
        }

        private int GetCount(string sql)
        {
            string key = "Statistics: " + sql;
            // store this in the cache. Use the sql as part of the key
            string cnt = (string)Framework.Utilities.Cache.FetchObject(key);

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
            return Convert.ToInt32(cnt);
        }


    }
}
