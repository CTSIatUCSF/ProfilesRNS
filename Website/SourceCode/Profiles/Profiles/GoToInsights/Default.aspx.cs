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

            String inst = "none";
            if (!String.IsNullOrEmpty(idpServerVar))
            {
                if (idpServerVar.Contains("ucsf.edu"))
                {
                    inst = "ucsf";
                }
                else if (idpServerVar.Contains("uci.edu"))
                {
                    inst = "uci";
                }
                else if (idpServerVar.Contains("ucla.edu"))
                {
                    inst = "ucla";
                }
                else if (idpServerVar.Contains("ucsd.edu"))
                {
                    inst = "ucsd";
                }
                else if (idpServerVar.Contains("ucdavis.edu"))
                {
                    inst = "ucdavis";
                }
                else if (idpServerVar.Contains("usc.edu"))
                {
                    inst = "usc";
                }
            }
            HttpCookie cookie = new HttpCookie("X-Profiles-Authenticating-Institution", inst);
            cookie.Expires = DateTime.Now.AddMinutes(30);
            Response.Cookies.Add(cookie);
            Response.Redirect("/insights/");
        }
    }
}