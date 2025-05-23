﻿using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using Profiles.Framework.Utilities;
using System.Web;
using System.Text;
using System.Configuration;

namespace Profiles.ORNG.Utilities
{
    public class OpenSocialManager
    {
        public static string ORNG_ONTOLOGY_PREFIX = "http://orng.info/ontology/orng#";
        public static string ORNG_DEBUG = "ORNG_DEBUG";
        public static string ORNG_NOCACHE = "ORNG_NOCACHE";
        public static string ORNG_GADGETS = "ORNG_GADGETS";

        // for controls we need to keep track of
        public static string ORNG_CONTAINER_CONTROL_ID = "cntlORNGContainer";
        public static string ORNG_GADGET_CONTROL_ID = "cntlORNGGadgets";

        // Visibility Values.  TODO Should be an Enum
        public static string PUBLIC = "Public";
        public static string USERS = "Users";
        public static string PRIVATE = "Private";
        public static string NOBODY = "Nobody";

        private static string ORNG_MANAGER = "ORNG_MANAGER";
        public static string ORNG_GADGET_SPEC_KEY = "ORNG_GADGET_SPEC_KEY";

        private static SocketConnectionPool sockets = null;

        #region "LocalVars"

        private List<PreparedGadget> gadgets = new List<PreparedGadget>();
        private Guid guid;
        private string containerSecurityToken;
        private string viewerUri = null;
        private string ownerUri = null;
        internal bool isDebug = false;
        internal bool noCache = false;
        private string pageName;
        private Page page;
        private static string shindigURL;
        private static string features;

        // performance
        private static double socketTime = 0;
        private static int socketCounter = 1;

        #endregion

        #region InitPage Helpers

        static OpenSocialManager()
        {
            if (ORNGSettings.getSettings().Enabled)
            {
                shindigURL = ORNGSettings.getSettings().ShindigURL;
                features = ORNGSettings.getSettings().Features;

                string[] tokenService = ORNGSettings.getSettings().TokenService.Split(':');
                int min = ORNGSettings.getSettings().SocketPoolMin;
                int max = ORNGSettings.getSettings().SocketPoolMax;
                int expire = ORNGSettings.getSettings().SocketPoolExpire;
                int timeout = ORNGSettings.getSettings().SocketReceiveTimeout;

                sockets = new SocketConnectionPool(tokenService[0], Int32.Parse(tokenService[1]), min, max, expire, timeout);
            }
        }

        public static OpenSocialManager GetOpenSocialManager(string ownerUri, Page page)
        {
            return GetOpenSocialManager(ownerUri, page, false);
        }

        public static OpenSocialManager GetOpenSocialManager(string ownerUri, Page page, bool editMode)
        {
            // synchronize?  From the debugger this seems to be single threaded, so synchronization is not needed
            if (!page.Items.Contains(ORNG_MANAGER))
            {
                page.Items.Add(ORNG_MANAGER, new OpenSocialManager(ownerUri, page, editMode));
            }
            return (OpenSocialManager)page.Items[ORNG_MANAGER];
        }

        private OpenSocialManager(string ownerUri, Page page, bool editMode)
        {
            if (!ORNGSettings.getSettings().Enabled)
            {
                // do nothing
                return;
            }
            this.guid = Guid.NewGuid();
            this.isDebug = page.Session != null && page.Session[ORNG_DEBUG] != null && (bool)page.Session[ORNG_DEBUG];
            this.noCache = page.Session != null && page.Session[ORNG_NOCACHE] != null && (bool)page.Session[ORNG_NOCACHE];
            this.page = page;
            this.pageName = page.AppRelativeVirtualPath.Substring(2).ToLower();
            this.ownerUri = ownerUri;

            DebugLogging.Log("Creating OpenSocialManager " + this.guid.ToString() + " for " + ownerUri + ", " + pageName);

    		// in editMode we need to set the viewer to be the same as the owner
	    	// otherwise, the gadget will not be able to save appData correctly            
            if (editMode)
            {
                viewerUri = ownerUri;
            }
            else
            {
                Profiles.Framework.Utilities.SessionManagement sm = new Profiles.Framework.Utilities.SessionManagement();
                // if they have a Profile, use the Profile URI otherwise use the User URI.  This allows admins and other folks without profile pages to use gadgets
                if (sm.Session().PersonURI != null && sm.Session().PersonURI.Trim().Length > 0)
                {
                    viewerUri = sm.Session().PersonURI;
                }
                else 
                {
                    viewerUri = sm.Session().UserURI;
                }
                if (viewerUri != null && viewerUri.Trim().Length == 0)
                {
                    viewerUri = null;
                }
            }
            containerSecurityToken = SocketSendReceive(viewerUri, ownerUri, null);

            string requestAppId = page.Request.QueryString["appId"];
            foreach (GadgetSpec gadgetSpec in GetGadgetSpecifications())
            {
                // only add ones that are visible in this context!
                if (((requestAppId == null && gadgetSpec.IsEnabled()) || gadgetSpec.GetAppId() == Convert.ToInt32(requestAppId)) && gadgetSpec.Show(viewerUri, ownerUri, GetPageName()))
                {
                    gadgets.Add(new PreparedGadget(gadgetSpec, this));
                }
            }

            // if we are in edit mode, clear the cache
            if (editMode)
            {
                ClearOwnerCache();
            }

            // sort the gadgets
            DebugLogging.Log("Visible Gadget Count : " + gadgets.Count);
            gadgets.Sort();
        }

        public PreparedGadget AddOntologyGadget(int appId, string view, string optParams)
        {
            // this only returns enabled gadgets, and that's what we want!
            foreach (GadgetSpec spec in GetGadgetSpecifications())
            {
                if (spec.GetAppId() == appId)
                {
                    PreparedGadget retval = new PreparedGadget(spec, this, view, optParams);
                    gadgets.Add(retval);
                    gadgets.Sort();
                    return retval;
                }
            }
            return null;
        }

        public void RemoveGadget(string label)
        {
            // if any visible gadgets depend on pubsub data that isn't present, throw them out
            PreparedGadget gadgetToRemove = null;
            foreach (PreparedGadget gadget in gadgets)
            {
                if (label.Equals(gadget.GetLabel()))
                {
                    gadgetToRemove = gadget;
                    break;
                }
            }
            gadgets.Remove(gadgetToRemove);
        }

        internal string GetViewerURI()
        {
            return this.viewerUri;
        }

        internal string GetOwnerURI()
        {
            return this.ownerUri;
        }

        internal Guid GetGuid()
        {
            return guid;
        }

        public void ClearOwnerCache()
        {
            if (ownerUri != null)
            {
                Framework.Utilities.Cache.AlterDependency(GetNodeID(ownerUri).ToString());
            }
        }

        public static Int64 GetNodeID(string uri)
        {
            string[] s = uri.Split('/');
            return Convert.ToInt64(s[s.Length - 1]);
        }

        public bool IsDebug()
        {
            return isDebug;
        }

        public bool NoCache()
        {
            return noCache;
        }

        public string GetPageName()
        {
            return pageName;
        }

        // is ORNG even turned on 
        public bool IsEnabled() 
        {
            return shindigURL != null;
        }

        // is ORNG turned on AND do we have something to show on this page
        public bool IsVisible()
        {
            // always have turned on for Profile/Display.aspx because we want to generate the "profile was viewed" in Javascript (bot proof) 
            // regardless of any gadgets being visible, and we need this to be True for the shindig javascript libraries to load
            bool retval = shindigURL != null && (GetVisibleGadgets().Count > 0);
            DebugLogging.Log("OpenSocialIsVisible = " + retval);
            return retval;
        }

        public List<PreparedGadget> GetUnrecognizedGadgets()
        {
            List<PreparedGadget> unrecognizedGadgets = new List<PreparedGadget>();
            foreach (PreparedGadget gadget in gadgets)
            {
                if (gadget.Unrecognized())
                {
                    unrecognizedGadgets.Add(gadget);
                }
            }
            return unrecognizedGadgets;
        }

        public List<PreparedGadget> GetGadgetsAttachingTo(string chromeIdBase)
        {
            List<PreparedGadget> attachingGadgets = new List<PreparedGadget>();
            foreach (PreparedGadget gadget in gadgets)
            {
                if (gadget.GetChromeId().StartsWith(chromeIdBase))
                {
                    attachingGadgets.Add(gadget);
                }
            }
            return attachingGadgets;
        }

        private List<PreparedGadget> GetVisibleGadgets()
        {
            return gadgets;
        }

        #endregion

        #region PostActivity
        public static void PostActivity(int userId, string title)
        {
            PostActivity(userId, title, null, null, null);
        }

        public static void PostActivity(int userId, string title, string body)
        {
            PostActivity(userId, title, body, null, null);
        }

        public static void PostActivity(int userId, string title, string body, string xtraId1Type, string xtraId1Value)
        {
            Profiles.ORNG.Utilities.DataIO data = new Profiles.ORNG.Utilities.DataIO();

            string sql = "INSERT INTO shindig_activity (userId, activity, xtraId1Type, xtraId1Value) VALUES (" + userId +
                ",'<activity xmlns=\"http://ns.opensocial.org/2008/opensocial\"><postedTime>" +
                Convert.ToInt64((DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalMilliseconds) + "</postedTime><title>" + title + "</title>"
                + (body != null ? "<body>" + body + "</body>" : "") + "</activity>','" + xtraId1Type + "','" + xtraId1Value + "');";

            data.ExecuteSQLDataCommand(sql);

        }
        #endregion

        public void LoadAssets()
        {
            // this is not really necessary, but it doesn't hurt to check 
            if (!IsVisible() ) 
            {
                return;
            }

            // this will get called potentially multiple times per page, see if this is the first time
            if (page.Header.FindControl(ORNG_CONTAINER_CONTROL_ID) == null)
            {
                // first one!
                // trigger the javascript to render gadgets
                //HtmlGenericControl body = (HtmlGenericControl)page.Master.FindControl("bodyMaster");
                //body.Attributes.Add("onload", "my.init();");

                HtmlLink gadgetscss = new HtmlLink();
                gadgetscss.Href = Brand.GetThemedDomain() + "/ORNG/CSS/gadgets.css";
                gadgetscss.Attributes["rel"] = "stylesheet";
                gadgetscss.Attributes["type"] = "text/css";
                gadgetscss.Attributes["media"] = "all";
                page.Header.Controls.Add(gadgetscss);

                HtmlGenericControl containerjs = new HtmlGenericControl("script");
                containerjs.ID = ORNG_CONTAINER_CONTROL_ID;
                containerjs.Attributes.Add("type", "text/javascript");
                containerjs.Attributes.Add("src", GetContainerJavascriptSrc());
                page.Header.Controls.Add(containerjs);

                HtmlGenericControl gadgetjs = new HtmlGenericControl("script");
                gadgetjs.ID = ORNG_GADGET_CONTROL_ID;
                gadgetjs.Attributes.Add("type", "text/javascript");
                gadgetjs.InnerHtml = GetGadgetJavascipt();
                page.Header.Controls.Add(gadgetjs);

                HtmlGenericControl shindigjs = new HtmlGenericControl("script");
                shindigjs.Attributes.Add("type", "text/javascript");
                //shindigjs.Attributes.Add("src", Brand.GetDomain() + (isDebug ? "/ORNG/JavaScript/orng.js" : "/ORNG/JavaScript/orng.min.js"));
                shindigjs.Attributes.Add("src", Brand.GetThemedDomain() + (isDebug ? "/ORNG/JavaScript/orng.js" : "/ORNG/JavaScript/orng.js"));
                page.Header.Controls.Add(shindigjs);
            }
            else
            {
                // this will have more gadgets then when called earlier, so we need to rebuilt that script
                HtmlGenericControl gadgetjs = (HtmlGenericControl)page.Header.FindControl(ORNG_GADGET_CONTROL_ID);
                gadgetjs.InnerHtml = GetGadgetJavascipt();
            }
        }

        private string GetContainerJavascriptSrc()
        {
            return shindigURL + "/gadgets/js/" + features + ".js?c=1&container=default" +
                (isDebug ? "&debug=1" : "") + (noCache ? "&nocache=1" : "");

            //return shindigURL + "/gadgets/js/shindig-container:rpc:osapi:rdf.js?c=1" +
            //    (isDebug ? "&debug=1" : "") + (noCache ? "&nocache=1" : "");
        }

        private string GetGadgetJavascipt()
        {
            string gadgetScriptText = Environment.NewLine +
                    "var my = {};" + Environment.NewLine +
                    "my.gadgetSpec = function(appId, label, url, view, chrome_id, opt_params, secureToken) {" + Environment.NewLine +
                    "this.appId = appId;" + Environment.NewLine +
                    "this.label = label;" + Environment.NewLine +
                    "this.url = url;" + Environment.NewLine +
                    "this.view = view || 'default';" + Environment.NewLine +
                    "this.chrome_id = chrome_id;" + Environment.NewLine +
                    "this.opt_params = opt_params;" + Environment.NewLine +
                    "this.secureToken = secureToken;" + Environment.NewLine +
                    "};" + Environment.NewLine;
            gadgetScriptText += "my.openSocialURL = '" + shindigURL + "';" + Environment.NewLine +
                "my.guid = '" + guid.ToString() + "';" + Environment.NewLine +
                "my.containerSecurityToken = '" + containerSecurityToken + "';" + Environment.NewLine +
                "my.containerSessionId = '" + new SessionManagement().Session().SessionID + "';" + Environment.NewLine +
                "my.debug = " + (IsDebug() ? "1" : "0") + ";" + Environment.NewLine +
                "my.noCache = " + (NoCache() ? "1" : "0") + ";" + Environment.NewLine +
                "my.noCache = " + (NoCache() ? "1" : "0") + ";" + Environment.NewLine +
                "my.gadgets = [";
            if (GetVisibleGadgets().Count > 0)
            {
                foreach (PreparedGadget gadget in GetVisibleGadgets())
                {
                    gadgetScriptText += "new my.gadgetSpec(" + gadget.GetAppId() + ",'" + gadget.GetLabel() + "','" + gadget.GetGadgetURL() + "','" +
                        gadget.GetView() + "','" + gadget.GetChromeId() + "'," +
                        gadget.GetOptParams() + ",'" + gadget.GetSecurityToken() + "'), " + Environment.NewLine;
                }
                gadgetScriptText = gadgetScriptText.Substring(0, gadgetScriptText.LastIndexOf(','));
            }
            gadgetScriptText += "];" + Environment.NewLine;

            // this uses jquery to kickstart the gadgets
            // better than using onload because this happens before the images finish
            /*** Either use this or the my.init call in LoadAssets!  Only use one.  This one is faster but seems to be having issues with Shindig 2.5.0 **/
            gadgetScriptText += "$(document).ready(function(){" + Environment.NewLine +
                                "my.init();" + Environment.NewLine +
                                "});" + Environment.NewLine;
            return gadgetScriptText;
        }

        public static GadgetSpec GetGadgetByPropertyURI(string propertyURI)
        {
            foreach (GadgetSpec spec in GetAllDBGadgets(true).Values)
            {
                if (propertyURI.Equals(ORNG_ONTOLOGY_PREFIX + "has" + spec.GetFileName()))
                {
                    return spec;
                }
            }
            return null;
        }

        public static Dictionary<string, GadgetSpec> GetAllDBGadgets(bool useCache)
        {
            // check cache first
            Dictionary<string, GadgetSpec> dbApps = useCache ? (Dictionary<string, GadgetSpec>)Cache.FetchObject(ORNG_GADGET_SPEC_KEY) : null;
            if (dbApps == null)
            {
                dbApps = new Dictionary<string, GadgetSpec>();
                Profiles.ORNG.Utilities.DataIO data = new Profiles.ORNG.Utilities.DataIO();
                using (SqlDataReader dr = data.GetGadgets())
                {
                    while (dr.Read())
                    {
                        GadgetSpec spec = new GadgetSpec(Convert.ToInt32(dr[0]), dr[1].ToString(), dr[2].ToString(), dr[3].ToString(), Convert.ToBoolean(dr[4]));
                        dbApps.Add(spec.GetFileName(), spec);
                    }
                }

                // add to cache unless noCache is turned on 
                if (useCache)
                {
                    // set it to not timeout
                    Cache.Set(ORNG_GADGET_SPEC_KEY, dbApps, -1, null);
                }
            }

            return dbApps;
        }

        private List<GadgetSpec> GetGadgetSpecifications()
        {
            DebugLogging.Log("OpenSocialManager GetAllDBGadgets " + !noCache);
            Dictionary<string, GadgetSpec> allDBGadgets = GetAllDBGadgets(!noCache);
            List<GadgetSpec> gadgetSpecs = new List<GadgetSpec>();

            // if someone used the sandbox to log in, grab those gadgets, and only those gadget.
            // if a gadget with the same file name is in the DB, merge it in so that we can inherit it's configuruation
            if (page.Session != null && (string)page.Session[ORNG_GADGETS] != null)
            {
                // Add sandbox gadgets if there are any
                // Note that this block of code only gets executed after someone logs in with GadgetSandbox.aspx!
                String openSocialGadgetURLS = (string)page.Session[ORNG_GADGETS];
                String[] urls = openSocialGadgetURLS.Split(Environment.NewLine.ToCharArray());
                for (int i = 0; i < urls.Length; i++)
                {
                    String openSocialGadgetURL = urls[i];
                    if (openSocialGadgetURL.Length == 0)
                        continue;
                    GadgetSpec sandboxGadget = new GadgetSpec(openSocialGadgetURL);
                    // see if we have a gadget with the same file name in the DB, if so use its configuration
                    if (allDBGadgets.ContainsKey(sandboxGadget.GetFileName()))
                    {
                        GadgetSpec gadget = allDBGadgets[sandboxGadget.GetFileName()];
                        gadget.MergeWithUnrecognizedGadget(sandboxGadget);
                        gadgetSpecs.Add(gadget);
                    }
                    else
                    {
                        gadgetSpecs.Add(sandboxGadget);
                    }
                }
            }
            else 
            {
                // the normal use case
                // just add in the db gadgets
                gadgetSpecs.AddRange(allDBGadgets.Values);
            }
            return gadgetSpecs;
        }

        #region Socket Communications

        internal string GetSecurityToken(String gadgetURL)
        {
            if ("true".Equals(ConfigurationManager.AppSettings["DEBUG"].ToLower()))
            {
                Stopwatch sw = new Stopwatch();
                sw.Start();
                string retval = SocketSendReceive(GetViewerURI(), GetOwnerURI(), gadgetURL);
                sw.Stop();
                socketTime += sw.Elapsed.TotalSeconds;
                DebugLogging.Log("Average socket = " + (socketTime / socketCounter++) + ", Elapsed = " + sw.Elapsed);
                return retval;
            }
            else
            {
                return SocketSendReceive(GetViewerURI(), GetOwnerURI(), gadgetURL);
            }
        }

        private static string SocketSendReceive(string viewer, string owner, string gadget)
        {
            //  These keys need to match what you see in edu.ucsf.profiles.shindig.service.SecureTokenGeneratorService in Shindig
            string request = "c=default" + (viewer != null ? "&v=" + HttpUtility.UrlEncode(viewer) : "") +
                (owner != null ? "&o=" + HttpUtility.UrlEncode(owner) : "") + (gadget != null ? "&u=" + HttpUtility.UrlEncode(gadget) : "") + "\r\n";
            Byte[] bytesSent = System.Text.Encoding.ASCII.GetBytes(request);
            Byte[] bytesReceived = new Byte[256];

            // Create a socket connection with the specified server and port.
            //Socket s = ConnectSocket(tokenService[0], Int32.Parse(tokenService[1]));

            // during startup we might fail a few times, so be willing to retry 
            string page = "";
            for (int i = 0; i < 3 && page.Length == 0; i++)
            {
                CustomSocket s = null;
                try
                {
                    s = sockets.GetSocket();

                    if (s == null)
                        return ("Connection failed");

                    // Send request to the server.
                    DebugLogging.Log("Sending Bytes");
                    s.Send(bytesSent);

                    // Receive the server home page content.
                    int bytes = 0;

                    // The following will block until the page is transmitted.
                    // we recognize the end of the message when the Trim drops the length by removing the EOL
                    do
                    {
                        DebugLogging.Log("Receiving Bytes");
                        bytes = s.Receive(bytesReceived);
                        page = page + Encoding.ASCII.GetString(bytesReceived, 0, bytes);
                        DebugLogging.Log("Socket Page=" + page + "|");
                    }
                    while (page.Length == page.TrimEnd().Length && bytes > 0);
                }
                catch (Exception ex)
                {
                    DebugLogging.Log("Socket Error :" + ex.Message);
                    page = "";
                }
                finally
                {
                    if (sockets != null && s != null) sockets.PutSocket(s);
                }
            }
            return page.TrimEnd();
        }
        #endregion
    }
}