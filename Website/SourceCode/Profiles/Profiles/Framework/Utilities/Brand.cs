using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Configuration;
using System.Web.Configuration;

namespace Profiles.Framework.Utilities
{
    public class Brand
    {
        private static Dictionary<string, Brand> ByTheme = new Dictionary<string, Brand>();

        public string Theme { get; set; }
        public string BasePath { get; set; }
        public string InstitutionName { get; set; }
        public string InstitutionAbbreviation { get; set; }
        public string PersonFilter { get; set; }

        public bool IsMultiInstitutional()
        {
            return !String.IsNullOrEmpty(InstitutionName);
        }

        public static Brand GetCurrentBrand()
        {
            return (Brand)HttpContext.Current.Items["Brand"];
        }

        public static string GetDomain()
        {
            Brand brand = GetCurrentBrand();
            return brand != null ? brand.BasePath : Root.Domain;
        }

        public static string GetDomainMatching(string URL)
        {
            Brand brand = GetByURL(URL);
            return brand != null ? brand.BasePath : Root.Domain;
        }

        public static Brand GetByTheme(string Theme)
        {
            return ByTheme.ContainsKey(Theme) ? ByTheme[Theme] : null;
        }

        static public Brand GetByURL(string URL)
        {
            foreach (Brand brand in ByTheme.Values)
            {
                if (URL.ToLower().StartsWith(brand.BasePath.ToLower()))
                {
                    return brand;
                }
            }
            return null;
        }

        // should we return default?
        static public Brand GetForSubject(long subjectId)
        {
            UCSFIDSet person = UCSFIDSet.ByNodeId.ContainsKey(subjectId) ? UCSFIDSet.ByNodeId[subjectId] : null;
            return person != null && person.Brand != null ? person.Brand : getDefault();
        }

        static public string GetThemedFile(Page page, string file)
        {
            return GetDomain() + "/App_Themes/" + page.Theme + "/" + file;
        }

        static public Brand getDefault()
        {
            return GetByTheme(GetSystemTheme());
        }

        public static string CleanURL(string uri)
        {
            // if it's a match to a person URI, swap in their URL
            long nodeid = -1;
            bool isNumeric = Int64.TryParse("123", out nodeid);
            if (uri.StartsWith(Root.Domain + "/profile/") && Int64.TryParse(uri.Substring(Root.Domain.Length + 9), out nodeid) && UCSFIDSet.ByNodeId.ContainsKey(nodeid))
            {
                // its a person!
                return UCSFIDSet.ByNodeId[nodeid].PrettyURL;
            }
            // see if we have a person in the current context and this is a prefix to their URI
            /**
            UCSFIDSet person = (UCSFIDSet)HttpContext.Current.Items["UCSFIDSet"];
            if (person != null && person.Brand != null)
            {
                string toSwap = Root.Domain + "/profile/" + person.NodeId;
                // only allow as many /'s as RegisterRoutes will support in Globl.asax.cs!!! If you add more, up the <= 1 to a larger number
                if (uri.StartsWith(toSwap) && uri.Length - toSwap.Length - uri.Replace(toSwap, "").Replace("/", "").Length <= 1) 
                {
                    // swap in the themed domain for the link
                    return uri.Replace(Root.Domain + "/profile/" + person.NodeId, person.PrettyURL);
                }
            }
             **/
            // see if it is the Root.Domain and swap in the themed one. 
            if (uri.StartsWith(Root.Domain)) 
            {
                return uri.Replace(Root.Domain, GetDomain());
            }
            return uri;
        }

        // this one gets it from Web.config, and is not meant for page level use
        static public string GetSystemTheme()
        {
            PagesSection pages = (PagesSection)ConfigurationManager.GetSection("system.web/pages");
            return pages.Theme;
        }

        public Brand(string Theme, string BasePath, string InstitutionName, string InstitutionAbbreviation, string PersonFilter)
        {
            this.Theme = Theme;
            this.BasePath = BasePath;
            this.InstitutionName = InstitutionName;
            this.InstitutionAbbreviation = InstitutionAbbreviation;
            this.PersonFilter = PersonFilter;

            ByTheme[this.Theme] = this;
        }
    }
}