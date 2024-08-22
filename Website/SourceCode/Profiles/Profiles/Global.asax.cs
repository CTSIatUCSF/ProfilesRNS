/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.Routing;
using System.Web.Compilation;
using System.Diagnostics;

using Profiles.Framework.Utilities;
using System.Net;

namespace Profiles
{
    public class Global : System.Web.HttpApplication
    {
        //***************************************************************************************************************************************
        /// <summary>
        /// 
        ///   When a request is submitted to the ISAPI filter the following steps are executed in order to process a RESTful URL:
        ///     1. IIS will trigger the ProfilesRouteHandler that's defined in the Global.asax.cs file.  
        ///     2. All parameters of the RESTful URL are then packed into the HttpContext.Current.Items hash table and the request is transferred to the Alias.aspx page.   
        ///     
        /// </summary>
        /// <param name="sender"> .Net context object</param>
        /// <param name="e"> .Net Event Arguments</param>
        protected void Application_Start(object sender, EventArgs e)
        {
            new Framework.Utilities.DataIO().LoadInstitutions();
            new Framework.Utilities.DataIO().LoadBrands();
            new Framework.Utilities.DataIO().LoadUCSFIdSet();
            RegisterRoutes(RouteTable.Routes);
            LoadModuleCatalogue();
            // set this up
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3 | SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12;
        }


        //***************************************************************************************************************************************
        /// <summary>
        /// 
        ///     Starts a Profiles instance of Profiles Session Management and Session State Information used for
        ///     security/data filters, tracking, auditing.
        ///     
        /// </summary>
        /// <param name="sender"> .Net context object</param>
        /// <param name="e"> .Net Event Arguments</param>
        protected void Session_Start(object sender, EventArgs e)
        {                     
            SessionManagement session = new SessionManagement();
            session.SessionCreate();
            
            Framework.Utilities.DebugLogging.Log("SESSION CREATED for: " + session.Session().SessionID);
            session = null;
        }


        //***************************************************************************************************************************************
        /// <summary>
        /// This method loads the module names and locations into RAM.  This code is located in the Profiles.Framework.Utilities.ModuleCatalogueCache.cs file
        /// </summary>
        private void LoadModuleCatalogue()
        {
            if (ModuleCatalogueCache.Instance != null)
            {
            }
        }

        //***************************************************************************************************************************************
        /// <summary>
        /*
             
            This method implements the loading of all URLs patterns that contain file extensions that need to be ignored and 
            all URLs patterns that need to be processed:           
          
            
            Example of patterns to process:
            routes.Add("ProfilesAliasPath2", new Route("{Param0}/{Param1}/{Param2}", new ProfilesRouteHandler()));     
                The above example will register a URL pattern for processing by the Alias.aspx page.  When IIS makes a request,
                the URL pattern of http://domain.com/profile/person/32213, will trigger the .Net System.Web.Routing library to call ProfilesRouteHandler.GetHttpHandler(RequestContext requestContext){}.  This method will process the URL pattern into parameters and load the HttpContext.Current.Items hash table and then direct the request to the Alias.aspx page for processing.

         */

        /// </summary>
        /// <param name="routes">RouteTable.Routes is passed as a RouteCollection by ref used to store all routes in the routing framework.</param>
        private static void RegisterRoutes(RouteCollection routes)
        {
            routes.RouteExistingFiles = false;

            // by UCSF
            routes.Add("RobotsTxt", new Route("robots.txt", new AspxHandler("~/RobotsTxt.aspx")));
            routes.Add("SiteMap", new Route("sitemap.xml", new AspxHandler("~/SiteMap.aspx")));
            routes.Add("WomenInScience", new Route("WomenInScience", new AspxHandler("~/Celebrating/Default.aspx")));
            routes.Add("LGBTQResearch", new Route("LGBTQResearch", new AspxHandler("~/Celebrating/Default.aspx")));

            foreach (string applicationName in UCSFIDSet.PrettyURLApplicationNames)
            {
                PrettyURLRouteHandler purh = new PrettyURLRouteHandler(applicationName);
                routes.Add(applicationName, new Route(applicationName, purh));
                routes.Add(applicationName + "2", new Route(applicationName + "/{Param2}", purh));
                /************  These things take a long time to make so they might be expensive to IIS. Uncomment more as you need them 
                    and make  sure To make Brand.CleanURL is OK with it!      :)                  ****************/
                //routes.Add(applicationName + "3", new Route(applicationName + "/{Param2}/{Param3}", purh));
                //routes.Add(applicationName + "4", new Route(applicationName + "/{Param2}/{Param3}/{Param4}", purh));
                //routes.Add(applicationName + "5", new Route(applicationName + "/{Param2}/{Param3}/{Param4}/{Param5}", purh));
                //routes.Add(applicationName + "6", new Route(applicationName + "/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}", purh));
                //routes.Add(applicationName + "7", new Route(applicationName + "/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}/{Param7}", purh));
                //routes.Add(applicationName + "8", new Route(applicationName + "/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}/{Param7}/{Param8}", purh));
                //routes.Add(applicationName + "9", new Route(applicationName + "/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}/{Param7}/{Param8}/{Param9}", purh));
            }

            //The REST Paths are built based on the applications setup in the Profiles database.
            ProfilesRouteHandler prh = new ProfilesRouteHandler();
            Framework.Utilities.DataIO d = new Framework.Utilities.DataIO();
            using (System.Data.SqlClient.SqlDataReader reader = d.GetRESTApplications())
            {
                int loop = 0;

                while (reader.Read())
                {
                    routes.Add("ProfilesAliasPath0" + loop, new Route(reader[0].ToString(), prh));
                    routes.Add("ProfilesAliasPath1" + loop, new Route(reader[0].ToString() + "/{Param1}", prh));
                    routes.Add("ProfilesAliasPath2" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}", prh));
                    routes.Add("ProfilesAliasPath3" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}", prh));
                    routes.Add("ProfilesAliasPath4" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}/{Param4}", prh));
                    routes.Add("ProfilesAliasPath5" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}/{Param4}/{Param5}", prh));
                    routes.Add("ProfilesAliasPath6" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}", prh));
                    routes.Add("ProfilesAliasPath7" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}/{Param7}", prh));
                    routes.Add("ProfilesAliasPath8" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}/{Param7}/{Param8}", prh));
                    routes.Add("ProfilesAliasPath9" + loop, new Route(reader[0].ToString() + "/{Param1}/{Param2}/{Param3}/{Param4}/{Param5}/{Param6}/{Param7}/{Param8}/{Param9}", prh));

                    Framework.Utilities.DebugLogging.Log("REST PATTERN(s) CREATED FOR " + reader[0].ToString());
                    loop++;
                }
            }
        }

        //***************************************************************************************************************************************
        /// <summary>
        /// 
        /// </summary>
        /// <param name="sender"> .Net context object</param>
        /// <param name="e"> .Net Event Arguments</param>
        void Application_BeginRequest(object sender, EventArgs e)
        {
            /**************
             * 
             * UCSF. We comment this out because EVERYTHING gets logged when this is on, including request for static files, jakarta processing requests, etc. It's just too much
             * 
            String path = Request.Url.ToString();
            Framework.Utilities.DebugLogging.Log("*** {Application_BeginRequest} IIS IS Processing: " + path + " , " + Request.HttpMethod);  
             ********************************/
        }

        //***************************************************************************************************************************************
        /// <summary>
        /// 
        ///     Global Error Handler.
        ///     
        ///     When this event is triggered, the error is logged to the server event log and then loaded into the user Session and 
        ///     redirected to the error page for display to the user.  
        ///     
        ///     Note:
        ///         There is a profiles request/response debug tool that can be accessed in the browser if the Debug flag is set to true in the
        ///         web.config file.
        /// </summary>
        /// <param name="sender"> .Net context object</param>
        /// <param name="e"> .Net Event Arguments</param>
        void Application_Error(object sender, EventArgs e)
        {
            //Each error that occurs will trigger this event.
            try
            {
                //get reference to the source of the exception chain
                Exception ex = Server.GetLastError().GetBaseException();

                // Catch errors that occur by design not true Application errors
                // and handle them without logging as a system error.
                if (ex.GetBaseException() is System.Web.HttpRequestValidationException)
                {
                    if (Server.GetLastError().GetBaseException() is System.Web.HttpRequestValidationException)
                    {
                        HttpContext.Current.Session.Add("GLOBAL_ERROR", "HttpRequestValidationException");
                        Response.Redirect("~/Error/default.aspx", true);  
                        return;
                    }   
                }

                Framework.Utilities.DebugLogging.Log("You are in the Global.asax Application_Error event.  Something broke!");
                Framework.Utilities.DebugLogging.Log(ex.Message);
                Framework.Utilities.DebugLogging.Log(ex.Source.ToString());
                Framework.Utilities.DebugLogging.Log(ex.StackTrace);

                if (ex.Message.ToLower().Contains("file does not exist"))
                {//This can happen if the REST routing wildcard is not setup correctly in IIS.
                    Framework.Utilities.DebugLogging.Log("File Does Not Exist!!!!  Check if your IIS Wildcard path is setup correctly.");
                    return;
                }

                try
                {
                    EventLog.WriteEntry("Profiles",
                      "MESSAGE: " + ex.Message +
                      "\nSOURCE: " + ex.Source +
                      "\nFORM: " + Request.Form.ToString() +
                      "\nQUERYSTRING: " + Request.QueryString.ToString() +
                      "\nTARGETSITE: " + ex.TargetSite +
                      "\nSTACKTRACE: " + ex.StackTrace,
                      EventLogEntryType.Error);
                }
                catch (Exception) { }

                //After the error is written to the event log, a copy of the same message is loaded into a session variable and then
                //displayed in the ErrorPage.aspx file.     
                HttpContext.Current.Session.Add("GLOBAL_ERROR", "MESSAGE: " + ex.Message +
                  "\nSOURCE: " + ex.Source +
                  "\nFORM: " + Request.Form.ToString() +
                  "\nQUERYSTRING: " + Request.QueryString.ToString());
            
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace);
                
            }
            Response.Redirect("~/Error/default.aspx", true);      
        }
    }

    //***************************************************************************************************************************************
    /// <summary>
    /// The Profiles Route Handler:
    /// 
    /// This class processes the event that RESTful path is requested and matches the routes defined in the RegisterRoutes method of this file.
    /// </summary>
    public class ProfilesRouteHandler : IRouteHandler
    {
        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            String path = HttpContext.Current.Request.Url.ToString().Replace("https://", "").Replace("http://", "");

            String baseURI = Brand.GetDomainMatching(HttpContext.Current.Request.Url.ToString()).Replace("https://", "").Replace("http://", "");

            string PathWithoutRoot = path.Substring(baseURI.Length + 1);
            //This manualy loads the Profiles Application into Param0 of the collection.  
            if (PathWithoutRoot.Contains('/'))
            {
                HttpContext.Current.Items["Param0"] = PathWithoutRoot.Substring(0, PathWithoutRoot.IndexOf('/'));
            }
            else
            {
                HttpContext.Current.Items["Param0"] = PathWithoutRoot;
            }


            //Loop each of the parts of the path and pack them into the current request context as 
            //parameters so they can be processed by the REST.aspx process
            foreach (var urlParm in requestContext.RouteData.Values)
            {
                HttpContext.Current.Items[urlParm.Key] = urlParm.Value;
            }
            Framework.Utilities.DebugLogging.Log("*** {ProfilesRouteHandler.GetHttpHandler} IIS IS Processing: " + path + " , " + HttpContext.Current.Request.HttpMethod);           

            return BuildManager.CreateInstanceFromVirtualPath("~/REST.aspx", typeof(Page)) as IHttpHandler;

        }
    }

    public class AspxHandler : IRouteHandler
    {
        private string aspx;

        public AspxHandler(string aspx)
        {
            this.aspx = aspx;
        }

        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            return BuildManager.CreateInstanceFromVirtualPath(aspx, typeof(Page)) as IHttpHandler;
        }
    }

    public class PrettyURLRouteHandler : IRouteHandler
    {

        private string applicationName;

        public PrettyURLRouteHandler(string applicationName)
        {
            this.applicationName = applicationName;
        }

        public IHttpHandler GetHttpHandler(RequestContext requestContext)
        {
            string url = HttpContext.Current.Request.Url.ToString().ToLower();
            string prettyUrl = url.Substring(0, url.IndexOf(applicationName)) + applicationName;

            //Loop each of the parts of the path and pack them into the current request context as 
            //parameters so they can be processed by the REST.aspx process
            foreach (var urlParm in requestContext.RouteData.Values)
            {
                HttpContext.Current.Items[urlParm.Key] = urlParm.Value;
            }

            HttpContext.Current.Items["Param0"] = HttpContext.Current.Items.Contains("Param2") ? "profile" : "display";
            HttpContext.Current.Items["Param1"] = UCSFIDSet.ByPrettyURL[prettyUrl].NodeId;

            return BuildManager.CreateInstanceFromVirtualPath("~/REST.aspx", typeof(Page)) as IHttpHandler;
        }
    }

}