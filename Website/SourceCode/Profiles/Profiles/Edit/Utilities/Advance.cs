using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Net;
using System.Linq;
using System.Web;
using Profiles.Framework.Utilities;
using Newtonsoft.Json.Linq;
using System.IO;
using System.Text;
using System.Drawing;
using System.Text.RegularExpressions;
using System.Diagnostics;

namespace Profiles.Edit.Utilities
{
    public class Advance
    {
        public static string[] ADVANCE_SECTIONS = { "http://vivoweb.org/ontology/core#educationalTraining",
                                             "http://vivoweb.org/ontology/core#awardOrHonor",
                                             "http://vivoweb.org/ontology/core#freetextKeyword",
                                             "http://profiles.catalyst.harvard.edu/ontology/plugins#Mentoring",
                                             "http://profiles.catalyst.harvard.edu/ontology/plugins#CommunityAndPublicService",
                                             "http://vivoweb.org/ontology/core#hasResearcherRole"};

        private static char[] DELIMETERS = new char[] {',', '\n'};

        private string employeeID;

        static public bool IsAdvanceEnabled()
        {
            return !String.IsNullOrEmpty(ConfigurationManager.AppSettings["Advance.API"]);
        }

        static public bool IsAdvanceEnabledFor(Institution institution)
        {
            return IsAdvanceEnabled() && institution != null && "UCSF".Equals(institution.GetAbbreviation());

        }
        static public bool IsAdvanceEnabledFor(Int64 nodeid)
        {
            return UCSFIDSet.IsPerson(nodeid) && IsAdvanceEnabledFor(UCSFIDSet.ByNodeId[nodeid].Institution);
        }

        public static List<string> getKeywordsFor(Int64 nodeid)
        {
            JObject advanceData = getAdvanceDataFor(nodeid);
            if (advanceData.TryGetValue("keywordsInterests", out JToken keywordsToken))
            {
                return Regex.Replace((string)keywordsToken["item"], "<.*?>", String.Empty).Split(DELIMETERS, StringSplitOptions.RemoveEmptyEntries).Select(keyword => keyword.Trim()).ToList()
                        .Where(s => !string.IsNullOrWhiteSpace(s)).Distinct().ToList();
            }
            return null;
        }
        public static string getMentoringNarrativeFor(Int64 nodeid)
        {
            JObject advanceData = getAdvanceDataFor(nodeid);
            if (advanceData.TryGetValue("mentoringNarrative", out JToken mentoringToken))
            {
                return Regex.Replace((string)mentoringToken["item"], "<.*?>", String.Empty).Replace("&nbsp;", "");
            }
            return null;
        }
        public static JToken getEducationFor(Int64 nodeid)
        {
            return getListItems("educationList", nodeid);
        }
        public static JToken getHonorsAndAwards(Int64 nodeid)
        {
            return getListItems("honorAwardList", nodeid);
        }
        public static JToken getPublicServiceFor(Int64 nodeid)
        {
            return getListItems("publicServiceList", nodeid);
        }
        public static JToken getCurrentAwardedGrantsFor(Int64 nodeid)
        {
            return getListItems("researchAwardGrantCurrentList", nodeid);
        }
        public static JToken getPastAwardedGrantsFor(Int64 nodeid)
        {
            return getListItems("researchAwardGrantPastList", nodeid);
        }

        private static JToken getListItems(string listName, Int64 nodeid)
        {
            JObject advanceData = getAdvanceDataFor(nodeid);
            if (advanceData.TryGetValue(listName, out JToken outerToken) && outerToken is JObject itemsAndDesciption && itemsAndDesciption.TryGetValue("items", out JToken itemsToken))
            {
                return itemsToken;
            }
            return null;
        }

        private static JObject getAdvanceDataFor(Int64 nodeid)
        {
            return getAdvanceDataFor(nodeid, false);
        }

        // add static cached method
        private static JObject getAdvanceDataFor(Int64 nodeid, bool useCache)
        {
            string cacheKey = "UCSF_AdvanceDataFor_" + nodeid;
            JObject advanceData = (JObject)Cache.FetchObject(cacheKey);
            if (advanceData == null)
            {
                Advance advance = new Advance(nodeid);
                advanceData = advance.GetAdvanceData(advance.GetAccessToken());
                if (useCache)
                {
                    Cache.Set(cacheKey, advanceData);
                }
            }
            return advanceData;
        }

        private Advance(Int64 nodeid)
        {
            SessionManagement sm = new SessionManagement();
            DataIO data = new DataIO();
            string connstr = (new Profiles.Framework.Utilities.DataIO()).GetConnectionString();

            using (SqlConnection dbconnection = new SqlConnection(connstr))
            {

                try
                {
                    dbconnection.Open();
                    //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                    using (SqlDataReader reader = data.GetDBCommand("select i.internalusername from [import_ucsf].[dbo].[vw_person] i join [UCSF.].vwPerson p on SUBSTRING(i.internalusername, 3, 6) + '@ucsf.edu' = p.InternalUsername  where p.nodeid = " + nodeid.ToString(), CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            employeeID = reader[0].ToString();
                        }
                    }
                }
                catch (Exception e)
                {
                    Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
                    throw new Exception(e.Message);
                }
            }
        }

        private JObject GetAdvanceData(string accessToken)
        {
            Uri uri = new Uri(ConfigurationManager.AppSettings["Advance.API"] + "/general/advance/1.0/cvs/" + employeeID + "?type=ucsfid&access_token=" + accessToken);
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            WebRequest myRequest = WebRequest.Create(uri);
            //myRequest.ContentType = "application/x-www-form-urlencoded";
            myRequest.Method = WebRequestMethods.Http.Get;
            myRequest.Headers.Add("client_id", ConfigurationManager.AppSettings["Advance.ClientID"]);
            myRequest.Headers.Add("client_secret", ConfigurationManager.AppSettings["Advance.ClientSecret"]);

            try
            {
                WebResponse myResponse = myRequest.GetResponse();
                using (StreamReader sr = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8))
                {
                    String json = sr.ReadToEnd();
                    return JObject.Parse(json);
                }
            }
            catch (Exception ex)
            {   // Eric Meeks. I know HTML in an exception is a BAD idea, maybe clean this up someday.
                throw new Exception("<b style=\"color:red;\">Error connecting to Advance. This may be temporary, please try again and let the <a href=\"mailto:profiles@ucsf.edu\">profiles@ucsf.edu</a> team know if this problem continues.</b>", ex);
            }
        } 

        private string GetAccessToken()
        {
            Uri uri = new Uri(ConfigurationManager.AppSettings["Advance.API"] + "/oauth/1.0/access_token?grant_type=password&client_id=" + ConfigurationManager.AppSettings["Advance.ClientID"] +
                "&client_secret=" + ConfigurationManager.AppSettings["Advance.ClientSecret"]);
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            WebRequest myRequest = WebRequest.Create(uri);
            myRequest.Method = WebRequestMethods.Http.Post;
            myRequest.Headers.Add("username", ConfigurationManager.AppSettings["Advance.Username"]);
            myRequest.Headers.Add("password", ConfigurationManager.AppSettings["Advance.Password"]);
            myRequest.ContentLength = 0;

            WebResponse myResponse = myRequest.GetResponse();
            using (StreamReader sr = new StreamReader(myResponse.GetResponseStream(), Encoding.UTF8))
            {
                JObject payload = JObject.Parse(sr.ReadToEnd());
                return payload.Value<string>("access_token");
            }
        } 

    }
}