﻿/*  
 
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
using System.Xml;



using Profiles.Framework.Utilities;


namespace Profiles
{
    //***************************************************************************************************************************************
    /// <summary>
    /*
     
         The ProfilesRouteHandler (in Global.asax) and the Alias.aspx file act as the traffic cop of all RESTful url processing.  
             
         When a request is submitted to the ISAPI filter the following steps are executed in order to process a RESTful URL:
         1. IIS will trigger the ProfilesRouteHandler that's defined in the Global.asax.cs file.  
         2. All parameters of the RESTful URL are then packed into the HttpContext.Current.Items hash table and the request is transferred to the Alias.aspx page.   
         3. Alias.aspx then unpacks the HttpContext.Current.Items hash table parameters and loads local string variables.
         4. The local string variables are then passed to the DataIO.GetResolvedURL method to be processed in the Database engine.
             a. This stored procedure breaks down the URL and analyzes it to see if it's a profile, network or connection within a type of application.
         5. The return from the DataIO.GetResolvedURL method/stored procedure call will yield what page and what query string values are passed to that page in order to process the user request.
         6. The request is further processed to determine if the user requests a data format response:
             Example http://domain.com/profile/person/32213/viewas/xml
             a. The 'viewas' parameter will tell the processing application page to not request a PresentationXML and just dump the raw XML to the page.
                 I. For a complete list of all known 'viewas' formats, please see the current Profiles documentation.

     
    */
    /// </summary>
    public partial class REST : BrandedPage
    {
        private static string TEXT_HTML = "text/html";
        private static string RDF_XML = "application/rdf+xml";
        private static string[] knownAcceptTypes = new string[] { TEXT_HTML, RDF_XML };

        //***************************************************************************************************************************************
        protected void Page_Load(object sender, EventArgs e)
        {
            ProcessRequest();
        }

        private string getBestAcceptType(String[] acceptTypes) {
            // If we find a known one, grab it.  Otherwise just go for the first one.
            if (acceptTypes != null)
            {
                foreach (string acceptType in acceptTypes)
                {
                    // remove the suff after a ; if present
                    string baseType = acceptType.Split(';')[0];
                    if (knownAcceptTypes.Contains(baseType))
                    {
                        return baseType;
                    }
                }
            }
            return knownAcceptTypes[0];
        }

        //***************************************************************************************************************************************
        private void ProcessRequest()
        {
            Framework.Utilities.DebugLogging.Log("{REST.aspx.cs} ProcessRequest() start ");


            string param0 = string.Empty; //Application Name {default for this install is profile}
            string param1 = string.Empty;
            string param2 = string.Empty;
            string param3 = string.Empty;
            string param4 = string.Empty;
            string param5 = string.Empty;
            string param6 = string.Empty;
            string param7 = string.Empty;
            string param8 = string.Empty;
            string param9 = string.Empty;

            XmlDocument frameworkurl = new XmlDocument();

            if (HttpContext.Current.Items["Param0"] != null)
            {
                param0 = HttpContext.Current.Items["Param0"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param1"] != null)
            {
                param1 = HttpContext.Current.Items["Param1"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param2"] != null)
            {
                param2 = HttpContext.Current.Items["Param2"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param3"] != null)
            {
                param3 = HttpContext.Current.Items["Param3"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param4"] != null)
            {
                param4 = HttpContext.Current.Items["Param4"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param5"] != null)
            {
                param5 = HttpContext.Current.Items["Param5"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param6"] != null)
            {
                param6 = HttpContext.Current.Items["Param6"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param7"] != null)
            {
                param7 = HttpContext.Current.Items["Param7"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param8"] != null)
            {
                param8 = HttpContext.Current.Items["Param8"].ToString();
            }
            else { }

            if (HttpContext.Current.Items["Param9"] != null)
            {
                param9 = HttpContext.Current.Items["Param9"].ToString();
            }
            else { }
            //Framework.Utilities.DebugLogging.Log("{UCSF REST.aspx.cs} ProcessRequest() params " + param0 + "/" + param1 + "/" + param2 + "/" + param3 + "/" + param4 + "/" + param5 + "/" + param6 + "/" + param7 + "/" + param8 + "/" + param9);

            DataIO data = new DataIO();

            //Alias.aspx is the hub for maintaining session state. With the exception of a log in Function.  
            //the Framework.Session is created and loaded into memory at the point a user session is created in the Global.asax file.
            //When a session has expired the Framework.Session.SessionLogout() method is called.
            SessionManagement sessionmanagement = new SessionManagement();
            Session session = sessionmanagement.Session();

            //UCSF for UC Wide Profiles
            string bestAcceptType = getBestAcceptType(HttpContext.Current.Request.AcceptTypes);
            Int64 nodeId = -1;
            URLResolve resolve = null;
            if (TEXT_HTML.Equals(bestAcceptType) && "profile".Equals(param0.ToLower()) && String.IsNullOrEmpty(param2) && Int64.TryParse(param1, out nodeId) && UCSFIDSet.ByNodeId.ContainsKey(nodeId))
            {
                // redirect to the pretty URL
                resolve = new URLResolve(true, "", UCSFIDSet.ByNodeId[nodeId].PrettyURL + 
                                            (String.IsNullOrEmpty(param2) ? "" : "/" + param2) +
                                            (String.IsNullOrEmpty(param3) ? "" : "/" + param3) +
                                            (String.IsNullOrEmpty(param4) ? "" : "/" + param4) +
                                            (String.IsNullOrEmpty(param5) ? "" : "/" + param5) +
                                            (String.IsNullOrEmpty(param6) ? "" : "/" + param6) +
                                            (String.IsNullOrEmpty(param7) ? "" : "/" + param7) +
                                            (String.IsNullOrEmpty(param8) ? "" : "/" + param8) +
                                            (String.IsNullOrEmpty(param9) ? "" : "/" + param9),
                                            TEXT_HTML, "200", true, false);
            }
            else
            {
                resolve = data.GetResolvedURL(param0,
                                   param1,
                                   param2,
                                   param3,
                                   param4,
                                   param5,
                                   param6,
                                   param7,
                                   param8,
                                   param9,
                                   session.SessionID,
                                   Brand.GetThemedDomain() + Root.AbsolutePath,
                                   session.UserAgent,
                                   getBestAcceptType(HttpContext.Current.Request.AcceptTypes));

            }
            Framework.Utilities.DebugLogging.Log("{REST.aspx.cs} ProcessRequest() redirect=" + resolve.Redirect.ToString() + " to=>" + resolve.ResponseURL);

            if (resolve.Resolved && !resolve.Redirect)
            {
                string URL = resolve.ResponseURL;
                Server.Execute(HttpUtility.HtmlDecode(URL));
            }
            else if (resolve.Resolved && resolve.Redirect)
            {
                // ugly hack to fix group branding
                if (TEXT_HTML.Equals(bestAcceptType) && "profile".Equals(param0.ToLower()) && String.IsNullOrEmpty(param2) && Int64.TryParse(param1, out nodeId) && Brand.GetForSubject(nodeId) != Brand.getDefault())
                {
                    Response.Redirect(resolve.ResponseURL.Replace(Root.Domain, Brand.GetForSubject(nodeId).BasePath), true);
                }
                else
                {
                    Response.Redirect(resolve.ResponseURL.Replace(Root.Domain, Brand.GetThemedDomain()), true);
                }
            }
            else
            {   // if we are not on a branded version, we need to be, so we redirect to the default
                Response.Redirect(Brand.GetThemedDomain() + "/search", true);


                //Response.Write("<b>Debug 404-- Your URL does not match a known Profiles RESTful pattern ---</b><br/><br/> ");

                //Response.Write("<br/>0: ");
                //Response.Write(param0);

                //Response.Write("<br/>1: ");
                //Response.Write(param1);

                //Response.Write("<br/>2: ");
                //Response.Write(param2);

                //Response.Write("<br/>3: ");
                //Response.Write(param3);

                //Response.Write("<br/>4: ");
                //Response.Write(param4);

                //Response.Write("<br/>5: ");
                //Response.Write(param5);

                //Response.Write("<br/>6: ");
                //Response.Write(param6);

                //Response.Write("<br/>7: ");
                //Response.Write(param7);

                //Response.Write("<br/>8: ");
                //Response.Write(param8);

                //Response.Write("<br/>9: ");
                //Response.Write(param9);

                //Response.Write("<br/><br/>Domain: ");
                //Response.Write(Brand.GetDomain());

                //throw new Exception("custom 404 needed here");
            }

            Framework.Utilities.DebugLogging.Log("{REST.aspx.cs} ProcessRequest() end ");

        }
    }
}
