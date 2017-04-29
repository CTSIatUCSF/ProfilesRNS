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
            Page.Theme = Brand.GetThemeFromURL(Request.Url.ToString());
        }

    }
}