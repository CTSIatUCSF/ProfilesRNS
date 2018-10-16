/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Configuration;

using Profiles.Framework.Utilities;
using Profiles.Login.Modules.MultiShibLogin;
using Profiles.Login.Modules.ShibLogin;
using System.Web;

namespace Profiles.Login
{
    public partial class ShibbolethSession : BrandedPage
    {

        // add smart caching of all of these ID lookups!
        protected void Page_Load(object sender, EventArgs e)
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            Dictionary<string, string> jsonresult = new Dictionary<string, string>();
            SessionManagement sm = new SessionManagement();
            Session session = sm.Session();

            // not logged into this domain but logged in via shibboleth
            if ("False".Equals(Request["loggedIn"]) && HasShibbolethSession(Request))
            {
                // user is logged into shibboleth but not here
                jsonresult.Add("redirect", HttpUtility.UrlEncode(MultiShibLogin.GetRedirect(true, 
                    Brand.GetByTheme(Request["theme"]).BasePath, 
                    session.SessionID, "", "", 
                    Request["redirectto"])));
            }
            else if ("True".Equals(Request["loggedIn"]) && !HasShibbolethSession(Request))
            {
                sm.SessionLogout();
                sm.SessionDestroy();
            }

            Response.StatusCode = 200;
            Response.Charset = "charset=UTF-8";
            Response.ContentType = "application/javascript";
            Response.Write(Request["callback"] + "(" + serializer.Serialize(jsonresult) + ");"); 
        }

        public static bool HasShibbolethSession(HttpRequest request)
        {
            // new school vs oldschool
            return !String.IsNullOrEmpty(ShibLogin.GetShibbolethAttribute(request, "ShibSessionID")) || !String.IsNullOrEmpty(ShibLogin.GetShibbolethAttribute(request, "Shib-Session-ID"));
        }


        public static string GetJavascriptSrc(HttpRequest request)
        {        
            if (String.IsNullOrEmpty(ConfigurationManager.AppSettings["Shibboleth.LoginURL"]) || Brand.GetCurrentBrand() == null || request.Path.Contains("/Error"))
            {
                return null;
            }
            else
            {
                SessionManagement sm = new SessionManagement();
                Session session = sm.Session();
                return MultiShibLogin.GetListOfDomainsShibbolizedFirst()[0] + "/Login/ShibbolethSession.aspx?callback=redirectForLogin&theme=" +
                    Brand.GetCurrentBrand().Theme + "&loggedIn=" + session.IsLoggedIn() + "&redirectto=" + HttpUtility.UrlEncode(request.Url.ToString());
            }
        }

    }
}
