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

namespace Profiles.Login
{
    public partial class MultiShibbolethLogin : BrandedPage
    {
        Profiles.Framework.Template masterpage;

        public void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;
            this.LoadAssets();

            masterpage.Tab = "";
            masterpage.RDFData = null;
            XmlDocument presentationxml = new XmlDocument();
            presentationxml.LoadXml(XslHelper.GetThemedOrDefaultPresentationXML(Page, "MultiShibbolethLogin.xml"));
            masterpage.PresentationXML = presentationxml;

        }

        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "login");

        }
    }
}
