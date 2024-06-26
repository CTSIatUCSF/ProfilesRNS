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
using System.Configuration;

using Profiles.Framework.Utilities;

namespace Profiles.Login
{
    public partial class Default : BrandedPage
    {
        Profiles.Framework.Template masterpage;

        public void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;

            LoadPresentationXML();
            this.LoadAssets();
            masterpage.PresentationXML = this.PresentationXML;

        }

        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "login");
        }

        public void LoadPresentationXML()
        {
            string presentationxml = string.Empty;

            string presentationXMLfile = ConfigurationManager.AppSettings["Login.PresentationXML"].ToString().Trim();
            presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, presentationXMLfile + ".xml");

            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);
            Framework.Utilities.DebugLogging.Log(presentationxml);

        }
        public XmlDocument PresentationXML { get; set; }

      
    }



}
