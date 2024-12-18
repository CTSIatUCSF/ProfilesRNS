﻿/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Web;

using System.Xml;



using Profiles.Framework.Utilities;

namespace Profiles.Profile.Utilities
{

    public class ProfileData : BrandedPage
    {
        #region "Local Private Data"

        #endregion

        #region "Constructor"
        protected void Page_PreRender(object sender, EventArgs e)
        {

        }

        protected override void OnPreInit(EventArgs e)
        {
            base.OnPreInit(e);
            
            if (!String.IsNullOrEmpty(Request.QueryString["Subject"]))
            {
                long nodeid = -1;                
                if (Int64.TryParse(Request.QueryString["subject"], out nodeid) && UCSFIDSet.ByNodeId.ContainsKey(nodeid))
                {
                    HttpContext.Current.Items["UCSFIDSet"] = UCSFIDSet.ByNodeId[nodeid];
                }
                /*
                Brand brand = Brand.GetForSubject(Int64.Parse(Request.QueryString["subject"]));
                HttpContext.Current.Items["Brand"] = brand;
                Page.Theme = brand.Theme;
                 */
            }
        }

        public ProfileData()
        {
            Init += new EventHandler(BasePage_Init);
        }
        public void BasePage_Init(object sender, EventArgs e)
        {
            //*****************************************************************************
            //Required            

            if (HttpContext.Current.Request.QueryString["Subject"] != null)
            {
                if (HttpContext.Current.Request.QueryString["Subject"] != string.Empty)
                    this.RDFTriple = new RDFTriple(Convert.ToInt64(Request.QueryString["Subject"].Trim()));
                else
                    HttpContext.Current.Response.Redirect(Brand.GetThemedDomain() + "/search");  //Need to take them to a search page when we have one.
            }else if(HttpContext.Current.Request.Form["Subject"]!=null){
                if (HttpContext.Current.Request.Form["Subject"] != string.Empty)
                    this.RDFTriple = new RDFTriple(Convert.ToInt64(Request.Form["Subject"].Trim()));
                else
                    HttpContext.Current.Response.Redirect(Brand.GetThemedDomain() + "/search");  //Need to take them to a search page when we have one.
            }
            else
                HttpContext.Current.Response.Redirect(Brand.GetThemedDomain() + "/search");  //Need to take them to a search page when we have one.

            //*****************************************************************************
            //Optional            
            if (HttpContext.Current.Request.QueryString["Predicate"] != null)
                if (HttpContext.Current.Request.QueryString["Predicate"] != string.Empty)
                {
                    this.RDFTriple.Predicate = Convert.ToInt64(Request.QueryString["Predicate"].Trim());
                }

            if (HttpContext.Current.Request.QueryString["Object"] != null)
                if (HttpContext.Current.Request.QueryString["Object"] != string.Empty)
                {
                    this.RDFTriple.Object = Convert.ToInt64(Request.QueryString["Object"].Trim());
                }

            if (HttpContext.Current.Request.QueryString["SessionID"] != null)
                this.SessionID = Request.QueryString["SessionID"];
            else
                this.SessionID = string.Empty;

            if (HttpContext.Current.Request.QueryString["Tab"] != null)
                this.Tab = Request.QueryString["Tab"];
            else
                this.Tab = string.Empty;

            //By default its expand true and showdetails true. Its set to Expand = false for external calls.
            this.RDFTriple.Expand = true;
            this.RDFTriple.ShowDetails = true;            
            
        }

        #endregion
        public void LoadRDFData()
        {
            Framework.Utilities.DebugLogging.Log("{Page Calling} Profile.ProfileData.LoadRDFData() start " + ((System.Web.UI.TemplateControl)(this)).AppRelativeVirtualPath);
            XmlDocument xml = new XmlDocument();
            Namespace rdfnamespaces = new Namespace();
            DataIO data = new DataIO();

            //if (HttpContext.Current.Request.Headers["Offset"] != null)
            //    this.RDFTriple.Offset = HttpContext.Current.Request.Headers["Offset"];

            //if (HttpContext.Current.Request.Headers["Limit"] != null)
            //    this.RDFTriple.Limit = HttpContext.Current.Request.Headers["Limit"];

            //if (HttpContext.Current.Request.Headers["ExpandRDFList"] != null)
            //    this.RDFTriple.ExpandRDFList = HttpContext.Current.Request.Headers["ExpandRDFList"];


            xml = data.GetRDFData(this.RDFTriple);
            this.RDFData = xml;
            this.RDFNamespaces = rdfnamespaces.LoadNamespaces(xml);
            Framework.Utilities.DebugLogging.Log("{Page Calling} Profile.ProfileData.LoadRDFData() end" + ((System.Web.UI.TemplateControl)(this)).AppRelativeVirtualPath);

        }


        public XmlNamespaceManager RDFNamespaces { get; set; }
        public XmlDocument RDFData { get; set; }
        public RDFTriple RDFTriple { get; set; }

        public string Tab { get; set; }
        public string SessionID { get; set; }

    }
}
