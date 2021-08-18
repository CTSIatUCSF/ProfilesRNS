/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/


using System;
using System.Web.UI.HtmlControls;
using System.Xml;

using Profiles.Framework.Utilities;
using Profiles.ORNG.Utilities;

namespace Profiles.ORNG
{
    public partial class Default : BrandedPage
    {
        Profiles.Framework.Template masterpage;

        public void Page_Load(object sender, EventArgs e)
        {
            if (Request.RawUrl.ToLower().Contains("clearcache"))
            {
                Cache.Remove(OpenSocialManager.ORNG_GADGET_SPEC_KEY);
            }
            masterpage = (Framework.Template)base.Master;

            LoadPresentationXML();
            this.LoadAssets();
            masterpage.PresentationXML = this.PresentationXML;

        }

        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "orng");
        }

        public void LoadPresentationXML()
        {
            string presentationxml = string.Empty;

            presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "SandboxFormPresentation.xml");

            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);
            Framework.Utilities.DebugLogging.Log(presentationxml);

        }
        public XmlDocument PresentationXML { get; set; }

    }

}
