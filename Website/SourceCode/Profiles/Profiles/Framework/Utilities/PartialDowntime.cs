using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public static class PartialDowntime
    {
        static readonly int SecondsToCheck = 120;

        static bool isPartialDowntime = false;
        static DateTime lastChecked = DateTime.Now.Subtract(new TimeSpan(0, 0, SecondsToCheck));

        public static bool IsPartialDowntimeNow()
        {
            // check every 10 minutes
            if (DateTime.Now.Subtract(lastChecked).TotalSeconds > SecondsToCheck)
            {
                isPartialDowntime = (new DataIO()).AreJobsRunning();
                lastChecked = DateTime.Now;
            }
            return isPartialDowntime;
        }
    }
}