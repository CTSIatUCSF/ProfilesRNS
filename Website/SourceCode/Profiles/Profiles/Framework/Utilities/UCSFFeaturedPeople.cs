using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public class UCSFFeaturedPeople : Framework.Utilities.DataIO
    {
        #region UCSFFeaturedPeople
        // added by UCSF
            public UCSFFeaturedPeople(string firstName, string lastName, string nodeId)
            {
                this.firstName = firstName;
                this.lastName = lastName;
                this.nodeId = nodeId;
            }
            public string firstName { get; set; }
            public string lastName { get; set; }
            public string nodeId { get; set; }

        public static List<UCSFFeaturedPeople> GetGroupMembersForBanner(string groupName, int size)
        {
            string cacheKey = "UCSF_FeaturedGroup_" + groupName;
            List<UCSFFeaturedPeople> allMembers = (List<UCSFFeaturedPeople>)Cache.FetchObject(cacheKey);
            if (allMembers == null)
            {
                allMembers = GetAllGroupMembersWithPhoto(groupName);
                Cache.Set(cacheKey, allMembers);
            }
            return allMembers.OrderBy(x => Guid.NewGuid()).Take(size).ToList();
        }

        // added by UCSF
        public static List<UCSFFeaturedPeople> GetAllGroupMembersWithPhoto(string groupName)
        {
            List<UCSFFeaturedPeople> featuredPeople = new List<UCSFFeaturedPeople>();
            using (System.Data.SqlClient.SqlDataReader sqldr = GetGroupMembersWithPhoto(groupName))
            {
                while (sqldr.Read())
                {
                    featuredPeople.Add(new UCSFFeaturedPeople(sqldr["FirstName"].ToString(), sqldr["LastName"].ToString(), sqldr["NodeID"].ToString()));
                }
            }
            return featuredPeople;
        }

        // Added by UCSF
        public static SqlDataReader GetGroupMembersWithPhoto(string groupName)
        {
            SqlDataReader dbreader = null;
            SessionManagement sm = new SessionManagement();

            try
            {

                string connstr = (new Profiles.Framework.Utilities.DataIO()).GetConnectionString();
                SqlConnection dbconnection = new SqlConnection(connstr);

                dbconnection.Open();

                SqlCommand dbcommand = new SqlCommand();
                dbcommand.CommandType = CommandType.StoredProcedure;

                dbcommand.CommandText = "[UCSF.].[Group.Member.GetMembersWithPhoto]";
                DataIO dataIO = new Profiles.Framework.Utilities.DataIO();
                dbcommand.CommandTimeout = dataIO.GetCommandTimeout();

                dbcommand.Parameters.Add(new SqlParameter("@GroupName", groupName));

                dbcommand.Connection = dbconnection;
                dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }

            return dbreader;
        }
        #endregion


    }
}