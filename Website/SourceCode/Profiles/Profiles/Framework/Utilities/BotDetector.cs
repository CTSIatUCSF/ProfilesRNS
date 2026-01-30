using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public class BotDetector
    {
        private static List<Regex> BotPatterns = new List<Regex>();
        private static int IPIsBot_CacheTimeoutSeconds;
        private static int IPIsBot_Threshold;
        private static string[] Disallowed = { "shindigorng", "sparql", "profile", "display", "login", "activity" };
        private static List<string> WhiteListedUserAgents = null;

        static BotDetector()
        {
            IPIsBot_CacheTimeoutSeconds = Int32.Parse(ConfigurationManager.AppSettings["IPIsBot.CacheTimeoutSeconds"]);
            IPIsBot_Threshold = Int32.Parse(ConfigurationManager.AppSettings["IPIsBot.Threshold"]);
            WhiteListedUserAgents = new List<String>(ConfigurationManager.AppSettings["UserAgentIsBot.WhiteList"].Split(','));

            using (SqlDataReader reader = new DataIO().GetSQLDataReader("select UserAgent from [User.Session].[Bot]", CommandType.Text, CommandBehavior.CloseConnection, null))
            {
                while (reader.Read())
                {
                    BotPatterns.Add(new Regex(reader[0].ToString(), RegexOptions.IgnoreCase | RegexOptions.Compiled));
                    Framework.Utilities.DebugLogging.Log("BOT Agent = " + reader[0]);
                }
            }
        }

        public static bool UserAgentIsForBot(string UserAgent)
        {
            if (string.IsNullOrWhiteSpace(UserAgent))
            {
                return true; // Block empty user-agents
            }
            else if (BotPatterns.Any(regex => regex.IsMatch(UserAgent)))
            {
                return true;
            }
            return false;
        }

        /// Checks if the given user-agent belongs to a bot.
        /// returns True if it's a bot, False otherwise
        public static bool IsBot(Session session)
        {
            if (IsWhiteListed(session.UserAgent))
            {
                return false;
            }
            else if (UserAgentIsForBot(session.UserAgent))
            {
                return true; // Block empty user-agents
            }
            // If the useragent doesn't indicate it's a bot check the traffic volume because maybe it's a bot anyway
            else if (IPIsBot_CacheTimeoutSeconds > 0 && !String.IsNullOrEmpty(session.RequestIP))
            {
                String sessionIPKey = "IP Monitor " + session.RequestIP;
                List<DateTime> sessionTimes = (List<DateTime>)Cache.FetchObject(sessionIPKey);
                if (sessionTimes == null)
                {
                    sessionTimes = new List<DateTime>();
                }
                // add one for now
                sessionTimes.Add(DateTime.Now);
                // remove those that are older than the timeout
                DateTime oldest = sessionTimes[0];
                while (oldest < DateTime.Now.AddSeconds(-1 * IPIsBot_CacheTimeoutSeconds))
                {
                    sessionTimes.RemoveAt(0);
                    if (sessionTimes.Count == 0)
                    {
                        break;
                    }
                    else
                    {
                        oldest = sessionTimes[0];
                    }
                }
                Cache.SetWithTimeout(sessionIPKey, sessionTimes, IPIsBot_CacheTimeoutSeconds);
                if (sessionTimes.Count > IPIsBot_Threshold)
                {
                    // always log this
                    Framework.Utilities.DebugLogging.Log("This IP is acting like a bot! " + session.RequestIP + ", " + sessionTimes.Count + " requests within " +
                        IPIsBot_CacheTimeoutSeconds + " seconds", true);
                    return true;
                }
            }
            return false;
        }

        // Make sure this agrees with RobotsTxt.aspx!
        public static bool IsForbiddenToBots(HttpContext context)
        {
            if ("true".Equals(context.Items["PrettyURLRouteHandler"]) || context.Request.Url.ToString().ToLower().Contains("/profile/modules/customviewpersongeneralinfo/photohandler.ashx"))
            {
                return false;
            }
            else return Array.Exists(Disallowed, delegate (string s) { return s.Equals(context.Items["Param0"].ToString(), StringComparison.InvariantCultureIgnoreCase); });
        }

        private static bool IsWhiteListed(string UserAgent)
        {
            foreach (string s in WhiteListedUserAgents)
            {
                if (UserAgent.Contains(s))
                {
                    return true;
                }
            }
            return false;
        }

    }
}