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

namespace Profiles.WomenInScience
{
    public partial class Default : BrandedPage
    {
        Profiles.Framework.Template masterpage;

        public void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;
            this.LoadAssets();

            masterpage.Tab = "";
            masterpage.RDFData = null;
            XmlDocument presentationxml = new XmlDocument();
            presentationxml.LoadXml(XslHelper.GetThemedOrDefaultPresentationXML(Page, "WomenInScience.xml"));
            masterpage.PresentationXML = presentationxml;

        }

        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "about");

            HtmlLink Aboutcss = new HtmlLink();
            Aboutcss.Href = Brand.GetThemedDomain() + "/About/CSS/about.css";
            Aboutcss.Attributes["rel"] = "stylesheet";
            Aboutcss.Attributes["type"] = "text/css";
            Aboutcss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Aboutcss);

            HtmlLink BricklayerCSS = new HtmlLink();
            BricklayerCSS.Href = "https://cdnjs.cloudflare.com/ajax/libs/bricklayer/0.4.2/bricklayer.min.css";
            BricklayerCSS.Attributes["rel"] = "stylesheet";
            Page.Header.Controls.Add(BricklayerCSS);

            HtmlLink BootstrapCSS = new HtmlLink();
            BootstrapCSS.Href = "https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css";
            BootstrapCSS.Attributes["rel"] = "stylesheet";
            BootstrapCSS.Attributes["crossorigin"] = "anonymous";
            BootstrapCSS.Attributes["integrity"] = "sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T";
            Page.Header.Controls.Add(BootstrapCSS);

            HtmlGenericControl Bricklayerjs = new HtmlGenericControl("script");
            Bricklayerjs.Attributes.Add("type", "text/javascript");
            Bricklayerjs.Attributes.Add("src", "https://cdnjs.cloudflare.com/ajax/libs/bricklayer/0.4.2/bricklayer.min.js");
            Page.Header.Controls.Add(Bricklayerjs);
        }
    }
}
