using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public class UCSFIDSet
    {
        public static Dictionary<Int64, UCSFIDSet> ByPersonId = new Dictionary<Int64, UCSFIDSet>();
        public static Dictionary<Int64, UCSFIDSet> ByNodeId = new Dictionary<Int64, UCSFIDSet>();
        public static Dictionary<string, UCSFIDSet> ByPrettyURL = new Dictionary<string, UCSFIDSet>();
        public static Dictionary<string, UCSFIDSet> ByUserName = new Dictionary<string, UCSFIDSet>(); // hopefully EPPN
        public static HashSet<string> PrettyURLs = new HashSet<string>();
        public static HashSet<string> PrettyURLApplicationNames = new HashSet<string>();

        public int PersonId { get; set; }
        public Int64 NodeId { get; set; }
        public string PrettyURL { get; set; }
        public string UserName { get; set; }
        public Institution Institution { get; set; }
        public Brand Brand { get; set; }

        public UCSFIDSet(int PersonId, Int64 NodeId, string PrettyURL, string UserName, Institution Institution)
        {
            this.PersonId = PersonId;
            this.NodeId = NodeId;
            this.PrettyURL = PrettyURL.ToLower();
            this.UserName = UserName;
            this.Institution = Institution;
            this.Brand = Brand.GetByPrimaryInstituion(Institution);

            // check if everything is OK before adding it. If the import fails, these can be sour
            if (PrettyURL == null || UserName == null || Institution == null || Brand == null)
            {
                Framework.Utilities.DebugLogging.Log("Error loading person : " + PersonId + "," + NodeId + "," + PrettyURL + "," + UserName + "," + Institution + "," + Brand);
            }

            ByPersonId[this.PersonId] = this;
            ByNodeId[this.NodeId] = this;
            ByPrettyURL[this.PrettyURL] = this;
            ByUserName[this.UserName] = this;

            PrettyURLs.Add(PrettyURL);
            string[] uriparts = PrettyURL.Split('/');
            PrettyURLApplicationNames.Add(uriparts[uriparts.Length - 1]);
        }

    }
}