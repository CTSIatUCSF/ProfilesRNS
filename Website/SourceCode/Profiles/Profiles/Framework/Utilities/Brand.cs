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

        public static string GetDomain(Page page)
        {
            Brand brand = GetByTheme(page.Theme);
            return brand != null ? brand.BasePath : Root.Domain;
        }

        public static Brand GetByTheme(string Theme)
        {
            return Theme != null && ByTheme.ContainsKey(Theme) ? ByTheme[Theme] : null;
        }

        static public string GetThemeFromURL(string URL)
        {
            foreach (Brand brand in ByTheme.Values)
            {
                if (URL.ToLower().StartsWith(brand.BasePath.ToLower()))
                {
                    return brand.Theme;
                }
            }
            return GetDefaultTheme();
        }

        static public string GetThemeForSubject(long subjectId)
        {
            UCSFIDSet person = UCSFIDSet.ByNodeId.ContainsKey(subjectId) ? UCSFIDSet.ByNodeId[subjectId] : null;
            return person != null && person.Brand != null ? person.Brand.Theme : GetDefaultTheme();
        }

        static public string GetThemedFile(Page page, string file)
        {
            return GetDomain(page) + "/App_Themes/" + page.Theme + "/" + file;
        }

        // this one gets it from Web.config, and is not meant for page level use
        static public string GetDefaultTheme()
        {
            PagesSection pages = (PagesSection)ConfigurationManager.GetSection("system.web/pages");
            return pages.Theme;
        }

        public Brand(string Theme, string BasePath)
        {
            this.Theme = Theme;
            this.BasePath = BasePath;

            ByTheme[this.Theme] = this;
        }
    }
}