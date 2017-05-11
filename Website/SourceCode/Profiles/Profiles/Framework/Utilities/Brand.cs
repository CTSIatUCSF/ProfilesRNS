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
        public static string DefaultBrandName = "Default";

        private static Dictionary<string, Brand> ByName = new Dictionary<string, Brand>();
        private static Dictionary<string, Brand> ByTheme = new Dictionary<string, Brand>();

        public string Name { get; set; }
        public string Theme { get; set; }
        public string BasePath { get; set; }
        public bool IsMultiInstitutional { get; set; }

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

        // return default if name is null or not found
        public static Brand GetByName(string Name)
        {
            return !String.IsNullOrEmpty(Name) && ByName.ContainsKey(Name) ? ByName[Name] : ByName[DefaultBrandName];
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

        // this one gets it from Web.config, and is not meant for page level use
        static public string GetSystemTheme()
        {
            PagesSection pages = (PagesSection)ConfigurationManager.GetSection("system.web/pages");
            return pages.Theme;
        }

        public Brand(string Name, string Theme, string BasePath)
            : this(Name, Theme, BasePath, false)
        {
        }

        public Brand(string Name, string Theme, string BasePath, bool IsMultiInstitutional)
        {
            this.Name = Name;
            this.Theme = Theme;
            this.BasePath = BasePath;
            this.IsMultiInstitutional = IsMultiInstitutional;

            ByName[this.Name] = this;
            ByTheme[this.Theme] = this;
        }
    }
}