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
        public static Dictionary<string, UCSFIDSet> ByEmployeeID = new Dictionary<string, UCSFIDSet>();
        public static Dictionary<string, UCSFIDSet> ByPrettyURL = new Dictionary<string, UCSFIDSet>();
        public static Dictionary<string, UCSFIDSet> ByFNO = new Dictionary<string, UCSFIDSet>();
        public static Dictionary<string, UCSFIDSet> ByUserName = new Dictionary<string, UCSFIDSet>(); // hopefully EPPN
        public static HashSet<string> PrettyURLs = new HashSet<string>();
        public static HashSet<string> PrettyURLApplicationNames = new HashSet<string>();

        public Int64 PersonId { get; set; }
        public Int64 NodeId { get; set; }
        public string EmployeeID { get; set; }
        public string PrettyURL { get; set; }
        public string UserName { get; set; }
        public string FNO { get; set; }
        public Brand Brand { get; set; }

        public UCSFIDSet(Int64 PersonId, Int64 NodeId, string EmployeeID, string PrettyURL, string UserName, string FNO, Brand Brand)
        {
            this.PersonId = PersonId;
            this.NodeId = NodeId;
            this.EmployeeID = EmployeeID;
            this.PrettyURL = PrettyURL.ToLower();
            this.UserName = UserName;
            this.FNO = FNO.ToLower();
            this.Brand = Brand;

            ByPersonId[this.PersonId] = this;
            ByNodeId[this.NodeId] = this;
            ByEmployeeID[this.EmployeeID] = this;
            ByPrettyURL[this.PrettyURL] = this;
            ByUserName[this.UserName] = this;
            ByFNO[this.FNO] = this;

            PrettyURLs.Add(PrettyURL);
            string[] uriparts = PrettyURL.Split('/');
            PrettyURLApplicationNames.Add(uriparts[uriparts.Length - 1]);
        }

        public static string TrySwapInPrettyURL(string restURL)
        {
            // if it is for this person, swap in the proper baseURI
            UCSFIDSet person = (UCSFIDSet)HttpContext.Current.Items["UCSFIDSet"];
            if (person != null && person.Brand != null)
            {
                string toSwap = Root.Domain + "/profile/" + person.NodeId;
                // only allow as many /'s as RegisterRoutes will support in Globl.asax.cs!!! If you add more, up the <= 1 to a larger number
                if (restURL.StartsWith(toSwap) && restURL.Length - toSwap.Length - restURL.Replace(toSwap, "").Replace("/", "").Length <= 1) 
                {
                    // swap in the themed domain for the link
                    return restURL.Replace(Root.Domain + "/profile/" + person.NodeId, person.PrettyURL);
                }
            }
            return restURL;
        }
    }
}