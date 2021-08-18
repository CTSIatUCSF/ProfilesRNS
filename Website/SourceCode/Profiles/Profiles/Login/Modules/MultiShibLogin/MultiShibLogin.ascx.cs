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
using System.Web;
using System.Web.UI.WebControls;
using System.Xml;
using System.Configuration;

using Profiles.Framework.Utilities;

namespace Profiles.Login.Modules.MultiShibLogin
{
    public partial class MultiShibLogin : System.Web.UI.UserControl
    {
        private static Random random = new Random();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string redirectto = getRedirectToFromRequest(Request);

                SessionManagement sm = new SessionManagement();
                
                // Note, this is used when used clicks Edit My Profile after logging in
                if ("login".Equals(Request["method"]) && sm.Session().IsLoggedIn())
                {
                    Response.Redirect(ShibLogin.ShibLogin.GetRedirectForAuthenticatedUser(redirectto));
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
                    Response.Redirect(GetRedirect(false, remainingDomains, "continue", "", "", getRedirectToFromRequest(Request)));
                }
                else if ("shibboleth".Equals(Request["method"]))
                {
                    Session session = sm.Session();
                    string remainingDomains = String.IsNullOrEmpty(Request["remainingDomains"]) ? String.Empty : Request["remainingDomains"];

                    // also need to take into account situations where they are logged into shibboleth but NOT profiles
                    if (String.IsNullOrEmpty(Request["sessionId"]))
                    {
                        Utilities.DataIO data = new Utilities.DataIO();
                        // they just logged in
                        bool inProfiles = false;

                        string userNameHeader = Request["userNameHeader"];
                        string displayNameHeader = Request["displayNameHeader"];

                        string userName = ShibLogin.ShibLogin.GetShibbolethAttribute(Request, userNameHeader); //"025693078";
                        DebugLogging.Log("Logging in " + userName);
                        if (userName != null && userName.Trim().Length > 0)
                        {
                            Utilities.User user = new Profiles.Login.Utilities.User();

                            user.UserName = userName;
                            inProfiles = data.UserLoginExternal(ref user);
                            DebugLogging.Log("Logged in " + userName + " with session " + session.SessionID + " inProfiles " + inProfiles);
                        }
                        if (!inProfiles)
                        {
                            session.DisplayName = String.IsNullOrEmpty(ShibLogin.ShibLogin.GetShibbolethAttribute(Request, displayNameHeader)) ? ShibLogin.ShibLogin.GetShibbolethAttribute(Request, userNameHeader) : ShibLogin.ShibLogin.GetShibbolethAttribute(Request, displayNameHeader);
                            // update the session to capture DisplayName
                            data.SessionUpdate(ref session);
                        }
                    }
                    else 
                    {
                        // now we need to wire this into the session!
                        DataIO data = new DataIO();
                        session.SessionID = Request["sessionId"];
                        data.SessionUpdate(ref session);
                    }
                    Response.Redirect(GetRedirect(true, remainingDomains, session.SessionID, "", "", redirectto));
                }
            }
        }

        public MultiShibLogin() { }

        public MultiShibLogin(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
        }

        public static String getRedirectToFromRequest(HttpRequest req)
        {
            return "true".Equals(req["edit"]) ? "edit" : req["redirectto"];
        }

        public static List<String> GetListOfDomainsShibbolizedFirst()
        {
            List<String> domains = new List<String>();
            domains.Add(Root.Domain);

            bool ROUND_ROBIN = false;
            if (!ROUND_ROBIN)
            {
                domains.Add(Brand.GetCurrentBrand().BasePath);
            }
            else
            {
                // go through all the different Domains
                foreach (Brand brand in Brand.GetAll())
                {
                    if (!brand.BasePath.Equals(Root.Domain))
                    {
                        domains.Add(brand.BasePath);
                    }
                }
            }

            // Make sure that the first domain matches that of the Shibboleth.LoginURL. 
            // If it does not then add it and assume the person who set up Profiles on this server knew what they were doing!
            Uri shibbolethLogin = new Uri(ConfigurationManager.AppSettings["Shibboleth.LoginURL"]);
            if (!domains[0].Contains(shibbolethLogin.Host))
            {
                domains.Insert(0, shibbolethLogin.Scheme + "://" + shibbolethLogin.Host);
            }

            return domains;
        }

        protected void cmdSubmit_Click(object sender, EventArgs e)
        {
            // Have login to just one Shibboleth instance and then just pass SessionID to everyone
            Institution institution = Institution.GetByAbbreviation(((ImageButton)sender).Attributes["InstitutionAbbreviation"]);
            string userNameHeader = institution.GetShibbolethUserNameHeader();  //ConfigurationManager.AppSettings["Shibboleth.UserNameHeader"];
            string displayNameHeader = institution.GetShibbolethDisplayNameHeader(); //ConfigurationManager.AppSettings["Shibboleth.DisplayNameHeader"];

            // this is the only time we pass through Shibboleth. We currently assume Root.domain is the one that is set up.
            string target = GetRedirect(true, String.Join(",", GetListOfDomainsShibbolizedFirst().ToArray()), "", userNameHeader, String.IsNullOrEmpty(displayNameHeader) ? userNameHeader : displayNameHeader, getRedirectToFromRequest(Request));
       
            string url = ConfigurationManager.AppSettings["Shibboleth.LoginURL"] + "?entityID=" + HttpUtility.UrlEncode(institution.GetShibbolethIdP()) +
                    "&target=" + HttpUtility.UrlEncode(target);
            DebugLogging.Log("MultiShib redirecting to :" + url);
            Response.Redirect(url);
        }

        public static string GetRedirect(bool login, string remainingDomainsStr, string sessionId, string userNameHeader, string displayNameHeader, string redirectto)
        {
            string url = null;
            // if we have many domains, redirect to the first one
            if (!String.IsNullOrEmpty(remainingDomainsStr))
            {
                List<string> remainingDomains = new List<string>(remainingDomainsStr.Split(','));
                string nextDomain = remainingDomains[0];
                remainingDomains.RemoveAt(0);
                url = nextDomain + "/login/default.aspx?method=" + (login ? "shibboleth" : "logout") +
                    "&remainingDomains=" + HttpUtility.UrlEncode(String.Join(",", remainingDomains.ToArray())) +
                    "&sessionId=" + sessionId + "&userNameHeader=" + HttpUtility.UrlEncode(userNameHeader) + 
                    "&displayNameHeader=" + HttpUtility.UrlEncode(displayNameHeader) + "&redirectto=" + HttpUtility.UrlEncode(redirectto) +
                    "&rnd=" + random.Next();
            }
            else if (login)
            {
                // final part of login
                // Maybe at this point we should add the ShibSessionID to the cache as a recognized login, and use that in ShibbolethSession.HasShibbolethSession
                url = ShibLogin.ShibLogin.GetRedirectForAuthenticatedUser(redirectto);
            }
            else
            {
                // final part of logout
                url = ConfigurationManager.AppSettings["Shibboleth.LogoutURL"] + "?return=" + HttpUtility.UrlEncode(redirectto);
            }

            DebugLogging.Log("MultiShib building redirect to :" + url);
            return url;
        }

    }
}