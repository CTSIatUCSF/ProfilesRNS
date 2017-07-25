using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public class BrandedPage : System.Web.UI.Page
    {
        protected override void OnPreInit(EventArgs e)
        {
            // set the theme based on the request.
            // first see if it has been explicity set
            Brand brand = null;
            if (!String.IsNullOrEmpty(Request.Params["Theme"]))
            {
                brand = Brand.GetByTheme(Request.Params["Theme"]);
            }
            else
            {
                brand = Brand.GetByURL(Request.Url.ToString());
            }

            if (brand != null)
            {
                HttpContext.Current.Items["Brand"] = brand;
                if (Page.EnableTheming)
                {
                    Page.Theme = brand.Theme;
                }
            }
        }

    }
}