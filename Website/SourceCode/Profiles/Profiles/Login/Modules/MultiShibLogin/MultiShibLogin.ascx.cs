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
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using System.Configuration;

using Profiles.Login.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.Login.Modules.MultiShibLogin
{
    public partial class MultiShibLogin : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string userNameHeader = ConfigurationManager.AppSettings["Shibboleth.UserNameHeader"];
                string displayNameHeader = ConfigurationManager.AppSettings["Shibboleth.DisplayNameHeader"];
                string redirectto = "true".Equals(Request["edit"]) ? "edit" : Request["redirectto"];

                Framework.Utilities.SessionManagement sm = new SessionManagement();
                
                if ("login".Equals(Request["method"]) && sm.Session().IsLoggedIn())
                {
                    Response.Redirect(Profiles.Login.Modules.ShibLogin.ShibLogin.GetRedirectForAuthenticatedUser(redirectto));
                }
                else if ("logout".Equals(Request["method"]))
                {
                    sm.SessionLogout();
                    sm.SessionDestroy();
                    string remainingDomains = "";
                    if (String.IsNullOrEmpty(Request["sessionId"]))
                    {
                        // first time, so build out the list, but note that this one is already done
                        foreach (Brand brand in Brand.GetAll())
                        {
                            if (!brand.BasePath.Equals(Brand.GetCurrentBrand().BasePath))
                            {
                                remainingDomains += brand.BasePath + ",";
                            }
                        }
                    }
                    else
                    {
                        remainingDomains = Request["remainingDomains"];
                    }
                    Response.Redirect(GetRedirect(false, remainingDomains, "continue", Request["redirectto"]));
                }
                else if ("shibboleth".Equals(Request["method"]))
                {
                    Session session = sm.Session();
                    string remainingDomains = String.IsNullOrEmpty(Request["remainingDomains"]) ? String.Empty : Request["remainingDomains"];

                    if (String.IsNullOrEmpty(Request["sessionId"]))
                    {
                        Profiles.Login.Utilities.DataIO data = new Profiles.Login.Utilities.DataIO();
                        // they just logged in
                        bool inProfiles = false;
                        string userName = Request.Headers.Get(userNameHeader); //"025693078";
                        Framework.Utilities.DebugLogging.Log("Logging in " + userName);
                        if (userName != null && userName.Trim().Length > 0)
                        {
                            Profiles.Login.Utilities.User user = new Profiles.Login.Utilities.User();

                            user.UserName = userName;
                            inProfiles = data.UserLoginExternal(ref user);
                        }
                        if (!inProfiles)
                        {
                            session.DisplayName = String.IsNullOrEmpty(Request.Headers.Get(displayNameHeader)) ? Request.Headers.Get(userNameHeader) : Request.Headers.Get(displayNameHeader);
                            // update the session to capture DisplayName
                            data.SessionUpdate(ref session);
                        }
                        Framework.Utilities.DebugLogging.Log("Logged in " + userName + " with session " + session.SessionID + " inProfiles " + inProfiles);
                    }
                    else 
                    {
                        // now we need to wire this into the session!
                        Profiles.Framework.Utilities.DataIO data = new Profiles.Framework.Utilities.DataIO();
                        session.SessionID = Request["sessionId"];
                        data.SessionUpdate(ref session);
                    }
                    Response.Redirect(GetRedirect(true, remainingDomains, session.SessionID, redirectto));
                }
            }
        }

        public MultiShibLogin() { }

        public MultiShibLogin(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
        }

        protected void cmdSubmit_Click(object sender, EventArgs e)
        {

            // root.domain (the one that matches the domain of the Shibboleth.LoginURL) needs to be first 
            string remainingDomains = Root.Domain + ",";
            // go through all the different Domains
            foreach (Brand brand in Brand.GetAll())
            {
                if (!brand.BasePath.Equals(Root.Domain))
                {
                    remainingDomains += brand.BasePath + ",";
                }
            }

            // Have login to just one Shibboleth instance and then just pass SessionID to everyone
            Institution institution = Institution.GetByAbbreviation(((ImageButton)sender).Attributes["InstitutionAbbreviation"]);

            // this is the only time we pass through Shibboleth. We currently assume Root.domain is the one that is set up.
            string target = GetRedirect(true, remainingDomains, "", Request["redirectto"]);
       
            string url = ConfigurationManager.AppSettings["Shibboleth.LoginURL"] + "?entityID=" + HttpUtility.UrlEncode(institution.GetShibbolethIdP()) +
                    "&target=" + HttpUtility.UrlEncode(target);
            Framework.Utilities.DebugLogging.Log("MultiShib redirecting to :" + url);
            Response.Redirect(url);
        }

        private string GetRedirect(bool login, string remainingDomains, string sessionId, string redirectto)
        {
            string url = null;
            // if we have many domains, redirect to the first one
            if (!String.IsNullOrEmpty(remainingDomains))
            {
                string nextDomain = remainingDomains.Split(',')[0];
                url = nextDomain + "/login/default.aspx?method=" + (login ? "shibboleth" : "logout") +
                    "&remainingDomains=" + HttpUtility.UrlEncode(remainingDomains.Replace(nextDomain + ",", "")) +
                    "&sessionId=" + sessionId + "&redirectto=" + HttpUtility.UrlEncode(redirectto);
            }
            else if (login)
            {
                // final part of login
                url = Profiles.Login.Modules.ShibLogin.ShibLogin.GetRedirectForAuthenticatedUser(redirectto);
            }
            else
            {
                // final part of logout
                url = ConfigurationManager.AppSettings["Shibboleth.LogoutURL"] + "?return=" + HttpUtility.UrlEncode(redirectto);
            }

            Framework.Utilities.DebugLogging.Log("MultiShib building redirect to :" + url);
            return url;
        }

    }
}