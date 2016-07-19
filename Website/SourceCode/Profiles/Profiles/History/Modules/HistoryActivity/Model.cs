using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ShowActivities.Model
{

 public enum ActivityType
    {
        Title,
        Statistic,
        ActualActivity,
    }


    public class Activity
    {
        internal Activity()
        {
        }

        /// <summary>
        /// Generated unique ID
        /// </summary>
        public string Id { get; set; }

        /// <summary>
        /// Who created the activity
        /// </summary>
        public string CreatedById { get; set; }

        public Entity Parent { get; set; }

        /// <summary>
        /// Simple TimeStamp 
        /// </summary>
        public DateTime CreatedDT { get; set; }

        public string Date
        {
            get { return String.Format("{0:MMMM d, yyyy}", CreatedDT); }
            set { }
        }

        public string Message { get; set; }

        public string LinkUrl { get; set; }

        public string Title { get; set; }

        public ActivityType Type { get; set; }

        public string ParentName
        {
            get { return Parent.Name; }
            set {}
        }

        public int ParentId
        {
            get { return Parent.GetType() == typeof(User) ? ((User)Parent).PersonId : 0; }
            set { }
        }
    }

    public class ActivitiesComparer : IComparer<Activity>
    {
        #region IComparer<Activity> Members

        public int Compare(Activity x, Activity y)
        {
            return DateTime.Compare(y.CreatedDT, x.CreatedDT);
        }

        #endregion
    }

    public class Entity
    {
        internal Entity()
        {
        }

        public string Id { get; set; }

        public string Name { get; set; }
    }

    public class User : Entity
    {
        internal User()
        {
        }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public string EmployeeId { get; set; }

        public int PersonId { get; set; }
    }
}
