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
using System.Xml;
using System.Web.UI.WebControls;
using System.IO;
using System.Web.UI.HtmlControls;

using Profiles.Framework.Utilities;


namespace Profiles.DIRECT
{
    public partial class Default : BrandedPage
    {     

        protected void Page_Load(object sender, EventArgs e)
        {

            Profiles.Framework.Template masterpage;
            masterpage = (Framework.Template)base.Master;
            LoadAssets();
            LoadPresentationXML();
            masterpage.PresentationXML = this.PresentationXML;
            masterpage.RDFData = null;
            
            if(Request.QueryString["searchrequest"]!=null)
                masterpage.SearchRequest = Request.QueryString["searchrequest"];

            masterpage.RDFNamespaces = null;

        }

        // Added by UCSF
        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "direct");

            HtmlGenericControl UCSFjs = new HtmlGenericControl("script");
            UCSFjs.Attributes.Add("type", "text/javascript");
            UCSFjs.Attributes.Add("src", Brand.GetThemedDomain() + "/DIRECT/JavaScript/UCSF.js");
            Page.Header.Controls.Add(UCSFjs);
        }

        public void LoadPresentationXML()
        {
            string presentationxml = string.Empty;

            presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "DirectPresentation.xml");


            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);
            Framework.Utilities.DebugLogging.Log(presentationxml);
        }
        public XmlDocument PresentationXML { get; set; }



    }
}
