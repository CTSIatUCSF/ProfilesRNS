using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Profiles.Framework.Utilities;

namespace Profiles
{
    public partial class ProfilesDisplay : BrandedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {   
            if (Request.QueryString["Person"] != null)
            {
                Response.Redirect(Brand.GetThemedDomain() + "/profile/ecommons/" + Request.QueryString["Person"], true);
            }
        }
    }
}
