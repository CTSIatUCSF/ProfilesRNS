﻿/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/


using System;
using System.Web.UI;
using System.Xml;
using System.Web.UI.HtmlControls;

using Profiles.Framework.Utilities;

namespace Profiles.Proxy
{
    public partial class Default : BrandedPage
    {
        Profiles.Framework.Template masterpage;
        protected void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;
            masterpage.Tab = "";

            string method = string.Empty;
            
            if (Request.QueryString["method"] != null)
            {
                method = Request.QueryString["method"];
            }
            else
            {
                method = "manage";
            }
            
            this.LoadPresentationXML(method);
            this.LoadAssets();
            BaseModule bm = new BaseModule();

            //the subject id should be passed in by query string var.
            XmlNamespaceManager xnm;
            Framework.Utilities.Namespace name = new Namespace();
            bm.GetSubjectProfile();
            xnm = name.LoadNamespaces(bm.BaseData);
            masterpage.RDFData = bm.BaseData;
            masterpage.RDFNamespaces = xnm;
            bm = null;
            masterpage.PresentationXML = this.PresentationXML;
        }


        public void LoadPresentationXML(string method)
        {
            string presentationxml = string.Empty;

            switch (method.ToLower().Trim())
            {
                case "search":
                    presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "SearchProxies.xml");
                    break;
                case "manage":
                    presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "ManageProxies.xml");
                    break;
            }
            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);

            Framework.Utilities.DebugLogging.Log(presentationxml);

        }
        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "orng");

            HtmlLink Editcss = new HtmlLink();
            Editcss.Href = Brand.GetThemedDomain() + "/Edit/CSS/edit.css";
            Editcss.Attributes["rel"] = "stylesheet";
            Editcss.Attributes["type"] = "text/css";
            Editcss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Editcss);
        }

        public XmlDocument PresentationXML { get; set; }

    }
}
