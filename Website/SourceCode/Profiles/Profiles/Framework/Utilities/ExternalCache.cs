using System;
using System.Net;
using System.Timers;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public class ExternalCache
    {
        private static bool overrideWhenInDebugger = false;

        static public bool HasBeenProxied()
        {
            return (!string.IsNullOrEmpty(HttpContext.Current.Request.Headers["X-Reverse-Caching-Proxy-Request"]) &&
                HttpContext.Current.Request.Headers["X-Reverse-Caching-Proxy-Request"].Equals("true", StringComparison.OrdinalIgnoreCase));
        }

        static public void ClearExternalCacheFor(string key)
        {
            long nodeid;
            if (long.TryParse(key, out nodeid))
            {
                ClearExternalCacheFor(nodeid);
            }
        }

        // make async somehow
        static public void ClearExternalCacheFor(long nodeid)
        {
            // only clear if a person and we are behind a proxy
            if (!overrideWhenInDebugger && (!UCSFIDSet.IsPerson(nodeid) || !HasBeenProxied()))
            {
                return;
            }
            // add note to nginx to remove from cache.
            String url = UCSFIDSet.ByNodeId[nodeid].PrettyURL;
            int lastIndex = url.LastIndexOf("/");
            HttpWebRequest myReq = (HttpWebRequest)WebRequest.Create(url.Substring(0, lastIndex) + "/nginx-admin/cache-purge/southern-rubber-boa" + url.Substring(lastIndex));
            try
            {
                myReq.GetResponse();
            }
            catch (Exception ex)
            {
                DebugLogging.Log("Error calling external cache for " + url + " " + ex.Message + " ; " + ex.StackTrace);
            }
            new ExternalCacheTimer(url);
        }

    }

    public class ExternalCacheTimer
    {
        private System.Timers.Timer timer;
        private String url;

        public ExternalCacheTimer(String url)
        {
            this.url = url;
            timer = new System.Timers.Timer(5000);
            timer.Elapsed += OnTimedEvent;
            timer.AutoReset = false;
            timer.Enabled = true;
        }

        private void OnTimedEvent(Object source, ElapsedEventArgs e)
        {
            // ping nginx to rebuild the cache
            HttpWebRequest myReq = (HttpWebRequest)WebRequest.Create(url);
            try
            {
                // This causes nginx to recache the page that just changed
                myReq.GetResponse();
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + ex.StackTrace);
                //throw new Exception(e.Message);
            }
            finally
            {
                timer.Stop();
                timer.Dispose();
            }
        }
    }

}