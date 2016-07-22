using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles.History.Utilities
{
    public class DeclumpedActivityList : List<Activity>
    {
        private Random random = new Random();
        private List<List<Activity>> clumpedData = new List<List<Activity>>();

        public void Clump()
        {
            // clear ours out first
            clumpedData.Clear();
            int id = -1;
            List<Activity> clumpedList = null;

            foreach (Activity activity in this)
            {
                if (id != activity.Profile.PersonId)
                {
                    //store the old clumpedList
                    if (clumpedList != null)
                    {
                        clumpedData.Add(clumpedList);
                    }
                    // create a new clump
                    clumpedList = new List<Activity>();
                    id = activity.Profile.PersonId;
                }
                clumpedList.Add(activity);
            }
            // add the last one
            if (clumpedList != null)
            {
                clumpedData.Add(clumpedList);
            }
        }

        public List<Activity> TakeUnclumped(int count)
        {
            List<Activity> retval = new List<Activity>();
            foreach (List<Activity> clumpedList in clumpedData)
            {
                // add a random one
                retval.Add(clumpedList[random.Next(0, clumpedList.Count)]);
                if (retval.Count == count)
                {
                    break;
                }
            }
            return retval;
        }
    }
}