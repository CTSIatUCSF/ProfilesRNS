using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Configuration;
using System.Web.Configuration;
using Profiles.ORNG.Utilities;
using System.Data.SqlClient;
using System.Xml;

namespace Profiles.Framework.Utilities
{
    public class Brand
    {
        public static String GROUPS_CACHE_KEY = "GroupsCache";
        public static String THEMECONFIGURATION_CACHE_KEY = "ThemeConfiguration";

        private static Dictionary<string, Brand> ByTheme = new Dictionary<string, Brand>();
        private static Dictionary<Institution, Brand> ByPrimaryInstitution = new Dictionary<Institution, Brand>();

        public string Theme { get; set; }
        public string BasePath { get; set; }
        public string GATrackingID { get; set; }
        public string PersonFilter { get; set; }
        private List<Institution> RestrictedInstitutions = null;

        public static XmlNode GetGoogleValidationContent(string brandTheme,string groupName)
        {
            string xmlstr = GetThemePropertiesXML(brandTheme);
            DebugLogging.Log("ERROR" + "read from DB for " + brandTheme +" "+ xmlstr);
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(xmlstr);
            XmlNode root = doc.DocumentElement;
            string rootName = root.Name;
            XmlNode properties = root.SelectSingleNode("/" + rootName + "/" + groupName);
            DebugLogging.Log("ERROR" + "returning properties " + properties.InnerText);
            return properties;
        }

        static public string GetThemePropertiesXML(string themeName)
        {
            string xmlstr = (string)Framework.Utilities.Cache.FetchObject(themeName + "_" + THEMECONFIGURATION_CACHE_KEY);
            if (xmlstr != null)
            {
                return xmlstr;
            }
            else
            {
                SqlDataReader reader = new GroupAdmin.Utilities.DataIO().GetThemeConfiguration(themeName);
                while (reader.Read())
                {
                    xmlstr = reader["config"].ToString();
                }
                reader.Close();
                Framework.Utilities.Cache.Set(themeName + "_" + THEMECONFIGURATION_CACHE_KEY, xmlstr);
                return xmlstr;
            }
        }


        public bool IsMultiInstitutional()
        {
            // having NO institutions means you work for all of them
            return RestrictedInstitutions.Count != 1;
        }

        public static Brand GetCurrentBrand()
        {
            return (Brand)HttpContext.Current.Items["Brand"];
        }

        public static string GetThemedDomain()
        {
            Brand brand = GetCurrentBrand();
            //return brand != null ? brand.BasePath : Root.Domain;
            return brand != null ? brand.BasePath : Brand.GetByTheme("Default").BasePath;
        }

        public static string GetGATrackingID()
        {
            Brand brand = GetCurrentBrand();
            return brand != null ? brand.GATrackingID : null;
        }

        public static string GetThemeName()
        {
            Brand brand = GetCurrentBrand();
            return brand.Theme;
        }

        public static string GetDomainMatching(string URL)
        {
            Brand brand = GetByURL(URL);
            return brand != null ? brand.BasePath : Root.Domain;
        }

        public static List<Brand> GetAll()
        {
            return ByTheme.Values.ToList();
        }

        public static List<string> GetAllThemes()
        {
            return ByTheme.Keys.ToList();
        }

        public static Brand GetByTheme(string Theme)
        {
            return ByTheme.ContainsKey(Theme) ? ByTheme[Theme] : null;
        }

        public static Brand GetByPrimaryInstituion(Institution institution)
        {
            return ByPrimaryInstitution[institution];
        }

        public static String GetNiceTitle(string theme)
        {
            return Brand.GetByTheme(theme).IsMultiInstitutional() ? theme : Brand.GetByTheme(theme).GetInstitution().GetAbbreviation();
        }

        static public Brand GetByURL(string URL)
        {
            foreach (Brand brand in ByTheme.Values)
            {
                // cheap way to ignore protocol
                if (URL.ToLower().Replace("http:", "https:").StartsWith(brand.BasePath.ToLower().Replace("http:", "https:")))
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
            if (person != null)
            {
                return person.Brand;
            }

            // see if it is a group
            Dictionary<Int64, string> GroupToTheme = (Dictionary<long, string>)Framework.Utilities.Cache.FetchObject(GROUPS_CACHE_KEY);
            if (GroupToTheme == null)
            {
                GroupToTheme = new Dictionary<long, string>();
                SqlDataReader reader = new GroupAdmin.Utilities.DataIO().GetActiveGroups();
                while (reader.Read())
                {
                    GroupToTheme.Add(reader.GetInt64(reader.GetOrdinal("GroupNodeID")), reader["Theme"].ToString());
                }
                reader.Close();
                Framework.Utilities.Cache.Set(GROUPS_CACHE_KEY, GroupToTheme);
            }
            return GroupToTheme.ContainsKey(subjectId) ? GetByTheme(GroupToTheme[subjectId]) : getDefault();
        }

        static public string GetThemedFile(Page page, string file)
        {
            return GetThemedDomain() + "/App_Themes/" + page.Theme + "/" + file;
        }

        static public Brand getDefault()
        {
            return GetByTheme(GetSystemTheme());
        }

        public static string CleanURL(string uri)
        {
            // if it's a match to a person URI, swap in their URL
            long nodeid = -1;
            if (uri.StartsWith(Root.Domain + "/profile/") && Int64.TryParse(uri.Substring(Root.Domain.Length + 9), out nodeid) && UCSFIDSet.ByNodeId.ContainsKey(nodeid))
            {
                // its a person!
                return UCSFIDSet.ByNodeId[nodeid].PrettyURL;
            }
            // see if we have a person in the current context and this is a prefix to their URI
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
            // see if it is the Root.Domain and swap in the themed one. 

            /** 6/26/2017 change to only brand person centric pages 
             * Change back on 5/24/2018
             * **/
            if (uri.StartsWith(Root.Domain)) 
            {
                return uri.Replace(Root.Domain, GetThemedDomain());
            }
            
            return uri;
        }

        // this one gets it from Web.config, and is not meant for page level use
        static public string GetSystemTheme()
        {
            PagesSection pages = (PagesSection)ConfigurationManager.GetSection("system.web/pages");
            return pages.Theme;
        }

        // return if it only has one! 
        public Institution GetInstitution()
        {
            return RestrictedInstitutions.Count == 1 ? RestrictedInstitutions[0] : null;
        }

        public bool IsApplicableFor(Institution institution)
        {
            return RestrictedInstitutions.Count == 0 || RestrictedInstitutions.Contains(institution);
        }

        //don't show gadget filters that don't make sense for this brand
        public bool IsApplicableForFilter(string filter)
        {
            if (RestrictedInstitutions.Count > 0)
            {
                foreach (GadgetSpec gadget in OpenSocialManager.GetAllDBGadgets(true).Values)
                {
                    if (filter.Equals(gadget.GetPersonFilter()))
                    {
                        // see if this gadget is scoped to an included institution
                        foreach (Institution inst in RestrictedInstitutions)
                        {
                            if (gadget.IsVisibleFor(inst))
                            {
                                return true;
                            }
                        }
                        // this filter is a gadget but not for these folks
                        return false;
                    }
                }
            }
            // this filter is not a gadget
            return true;
        }

        static public bool ShowWomenInScience()
        {
            Institution inst = Brand.GetCurrentBrand().GetInstitution();
            return inst != null && "UCSF".Equals(inst.GetAbbreviation()) && Convert.ToBoolean(System.Configuration.ConfigurationSettings.AppSettings["WomenInScience"]);
        }

        public Brand(string Theme, string BasePath, string GATrackingID, string PersonFilter, List<Institution> institutions)
        {
            this.Theme = Theme;
            this.BasePath = BasePath;
            this.GATrackingID = GATrackingID;
            this.PersonFilter = String.IsNullOrEmpty(PersonFilter) ? null : PersonFilter;
            this.RestrictedInstitutions = institutions;

            ByTheme[this.Theme] = this;

            // should only have one primary
            if (GetInstitution() != null)
            {
                ByPrimaryInstitution[GetInstitution()] = this;
            }
        }
    }
}