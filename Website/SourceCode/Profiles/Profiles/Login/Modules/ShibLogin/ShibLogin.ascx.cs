﻿/*  
 
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

namespace Profiles.Login.Modules.ShibLogin
{
    public partial class ShibLogin : System.Web.UI.UserControl
    {
        Framework.Utilities.SessionManagement sm = new SessionManagement();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string loginUrl = ConfigurationManager.AppSettings["Shibboleth.LoginURL"];
                string logoutUrl = ConfigurationManager.AppSettings["Shibboleth.LogoutURL"];
                string userNameHeader = ConfigurationManager.AppSettings["Shibboleth.UserNameHeader"];
                string displayNameHeader = ConfigurationManager.AppSettings["Shibboleth.DisplayNameHeader"];

                if (Request.QueryString["method"].ToString() == "logout")
                {

                    sm.SessionLogout();
                    sm.SessionDestroy();
                    Response.Redirect(logoutUrl + "?return=" + HttpUtility.UrlEncode(Request.QueryString["redirectto"].ToString()));
                }
                else if (Request.QueryString["method"].ToString() == "shibboleth")
                {
                    // added by Eric
                    // If they specify an Idp, then check that they logged in from the configured IDP
                    bool authenticated = false;

                    String userName = Request.Headers.Get(userNameHeader); //"025693078";
                    if (userName != null && userName.Trim().Length > 0)
                    {
                        Profiles.Login.Utilities.DataIO data = new Profiles.Login.Utilities.DataIO();
                        Profiles.Login.Utilities.User user = new Profiles.Login.Utilities.User();

                        user.UserName = userName;
                        if (data.UserLoginExternal(ref user))
                        {
                            authenticated = true;
                            RedirectAuthenticatedUser();
                        }
                    }
                    if (!authenticated)
                    {
                        // try and just put their name in the session.
                        sm.Session().DisplayName = String.IsNullOrEmpty(Request.Headers.Get(displayNameHeader)) ? Request.Headers.Get(userNameHeader) : Request.Headers.Get(displayNameHeader);
                        RedirectAuthenticatedUser();
                    }
                }
                else if (Request.QueryString["method"].ToString() == "login")
                {
                    // see if they already have a login session, if so don't send them to shibboleth
                    Profiles.Framework.Utilities.SessionManagement sm = new Profiles.Framework.Utilities.SessionManagement();
                    if (sm.Session().IsLoggedIn())
                    {
                        RedirectAuthenticatedUser();
                    }
                    else
                    {
                        string redirect = Brand.GetThemedDomain() + "/login/default.aspx?method=shibboleth";
                        if (Request.QueryString["redirectto"] == null && Request.QueryString["edit"] == "true")
                            redirect += "&edit=true";
                        else
                            redirect += "&redirectto=" + Request.QueryString["redirectto"].ToString();

                        Response.Redirect(loginUrl + "?target=" + HttpUtility.UrlEncode(redirect));
                    }
                }

            }


        }

        private void RedirectAuthenticatedUser()
        {
            Framework.Utilities.DebugLogging.Log("ShibLogin redirect authenticated user query = " + Request.Url.Query);
            if (Request.QueryString["redirectto"] == null && Request.QueryString["edit"] == "true")
            {
                Response.Redirect(Brand.GetForSubject(sm.Session().NodeID).BasePath + "/edit/" + sm.Session().NodeID);
            }
            else if (Request.QueryString["redirectto"] != null)
            {
                Response.Redirect(ShibLogin.GetRedirectForAuthenticatedUser(Request.QueryString["redirectto"]));
            }
            Response.Redirect(Brand.GetThemedDomain());
        }

        public static string GetRedirectForAuthenticatedUser(string redirectto)
        {
            Framework.Utilities.SessionManagement sm = new SessionManagement();
            if (String.IsNullOrEmpty(redirectto))
            {
                return Brand.GetThemedDomain();
            }
            else if ("mypage".Equals(redirectto.ToLower()) && sm.Session().NodeID > 0)
            {
                return Brand.GetForSubject(sm.Session().NodeID).BasePath + "/profile/" + sm.Session().NodeID;
            }
            else if ("myproxies".Equals(redirectto.ToLower()) && sm.Session().NodeID > 0)
            {
                return Brand.GetForSubject(sm.Session().NodeID).BasePath + "/proxy/default.aspx?subject=" + sm.Session().NodeID;
            }
            else if ("edit".Equals(redirectto.ToLower()) && sm.Session().NodeID > 0)
            {
                return Brand.GetForSubject(sm.Session().NodeID).BasePath + "/edit/" + sm.Session().NodeID;
            }
            else if (redirectto.ToLower().StartsWith("http")) // make sure it at least looks legit
            {
                // use full part of query after the redirectto parameter because it might have 
                // LOG THIS!
                return redirectto;
                //Response.Redirect(Request.Url.Query.Substring(Request.Url.Query.IndexOf("redirectto=") + "redirectto=".Length));
            }
            else
            {
                return Brand.GetThemedDomain();
            }
        }

        public ShibLogin() { }
        public ShibLogin(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
            sm = new Profiles.Framework.Utilities.SessionManagement();
        }

    }
}