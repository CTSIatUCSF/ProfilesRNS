using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace ShowActivities.Model
{
    class Activities
    {
        public readonly int RequestedCount;
        public readonly List<Activity> items;

        public Activities(int reqCount, List<Activity> activities)
        {
            RequestedCount = reqCount;
            items = activities;
        }

        public Activity[] GetRandomList(int count)
        {
            SortedDictionary<int, Activity> list = new SortedDictionary<int, Activity>();

            Random random = new Random();
            for (int i = 0; i < count && i < items.Count; i++)
            {
                Activity act = items[i];
                int key = random.Next(items.Count);
                while (list.ContainsKey(key))
                {
                    key = random.Next(count * 10);
                }

                list.Add(key, act);
            }

            return list.Values.ToArray();
        }
    }
    
    public class DeclumpedList : List<Activity>
    {
        private Random random = new Random();
        private List<List<Activity>> clumpedData = new List<List<Activity>>();

        public void GrabDate()
        {
            // clear ours out first
           clumpedData.Clear();
           string headay = "";
           List<Activity> clumpedList = null;
           foreach (Activity activity in this)
            {
                if (headay != activity.Date)
                {
                    //store the old clumpedList
                    if (clumpedList != null)
                    {
                        clumpedData.Add(clumpedList);
                    }
                    // create a new clump
                    clumpedList = new List<Activity>();
                    headay = activity.Date;
                }
                clumpedList.Add(activity);
            }

        }

        
        public void Clump()
        {
            // clear ours out first
            clumpedData.Clear();
            int id = -1;
            List<Activity> clumpedList = null;
 
            foreach (Activity activity in this)
            {
                if (id != activity.ParentId)
                {
                    //store the old clumpedList
                    if (clumpedList != null)
                    {
                        clumpedData.Add(clumpedList);
                    }
                    // create a new clump
                    clumpedList = new List<Activity>();
                    id = activity.ParentId;
                }
                clumpedList.Add(activity);
            }
            // ad the last one
            if (clumpedList != null)
            {
                clumpedData.Add(clumpedList);
            }
        }

        public List<Activity> TakeUnclumped(int count)
        {
            List<Activity> retval = new List<Activity>();
            foreach(List<Activity> clumpedList in clumpedData)
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