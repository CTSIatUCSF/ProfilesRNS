/*  
 
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
using System.Web.UI.WebControls;

namespace Profiles.ORNG
{
    public partial class GadgetDetails : BrandedPage
    {
        Profiles.Framework.Template masterpage;

        public void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;

            LoadPresentationXML();

            if (!String.IsNullOrEmpty(Request["owner"]))
            {
                // go ahead and swap in the pretty URL
                Literal backlink = (Literal)masterpage.FindControl("litBackLink");
                backlink.Text = "<a href='" + Brand.GetThemedDomain() + "/" +
                    UCSFIDSet.ByNodeId[Convert.ToInt64(Request["owner"].Substring(Request["owner"].LastIndexOf("/") + 1))].PrettyURL + 
                    "'>Back to Profile</a>";
            }

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

            presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "GadgetDetailsPresentation.xml");
            
            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);
            Framework.Utilities.DebugLogging.Log(presentationxml);

        }
        public XmlDocument PresentationXML { get; set; }

      
    }



}
