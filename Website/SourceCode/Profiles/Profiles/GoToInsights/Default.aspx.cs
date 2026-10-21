using Profiles.Framework.Utilities;
using System;
using System.Web;

namespace Profiles.Insights
{
    public partial class Default : BrandedPage
    {
        // Put a cookie showing who, if anyone, authenticated

        protected void Page_Load(object sender, EventArgs e)
        {
            string idpServerVar = Request.ServerVariables["Shib-Identity-Provider"];

            String inst = String.IsNullOrEmpty(idpServerVar) ? "none" : Institution.GetByShibbolethIdp(idpServerVar).GetAbbreviation().ToLower().Replace(" ", string.Empty);
            HttpCookie cookie = new HttpCookie("X-Profiles-Authenticating-Institution", inst);
            cookie.Expires = DateTime.Now.AddMinutes(30);
            Response.Cookies.Add(cookie);
            Response.Redirect("/insights/");
        }
    }
}