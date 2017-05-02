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
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using System.Web.Script.Serialization;

using Profiles.Login.Utilities;
using Profiles.Framework.Utilities;
using Profiles.ORNG.Utilities;

namespace Profiles.ORNG.Modules.Gadgets
{
    public partial class Gadgets : BaseModule
    {
        private OpenSocialManager om;

        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }

        public Gadgets() { }
        public Gadgets(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            string uri = null;
            // code to convert from numeric node ID to URI
            if (base.Namespaces.HasNamespace("rdf"))
            {
                XmlNode node = this.BaseData.SelectSingleNode("rdf:RDF/rdf:Description/@rdf:about", base.Namespaces);
                uri = node != null ? node.Value : null;
                // we know the structure of the URI and need to take advantage of that
                if (uri != null && uri.StartsWith(Brand.GetDomain() + "/profile/"))
                {
                    string suffix = uri.Substring((Brand.GetDomain() + "/profile/").Length);
                    uri = Brand.GetDomain() + "/profile/" + suffix.Split('/')[0];
                }
            }
            else if ("True".Equals(base.GetModuleParamString("AllowSetOwnerFromRequest")))
            {
                uri = Page.Request["owner"];
            }
            om = OpenSocialManager.GetOpenSocialManager(uri, Page);
        }

        protected void DrawProfilesModule()
        {
            if (om.IsVisible())
            {
                String txt = "";
                String chromeIdBase = base.GetModuleParamString("GadgetDiv");
                foreach (PreparedGadget gadget in om.GetGadgetsAttachingTo(chromeIdBase))
                {
                    if (!string.Empty.Equals(base.GetModuleParamString("TitleHTML")))
                    {
                        // note that the swapped in value for GADGET_TITLE_CHROME_ID must match what orng.js expects!!!!!
                        txt += base.GetModuleParamXml("TitleHTML").InnerXml.Replace("GADGET_TITLE_CHROME_ID", "gadget-title-" + gadget.GetAppId());
                    }
                    txt += "<div id=\"" + gadget.GetChromeId() + "\"";
                    if (!string.Empty.Equals(base.GetModuleParamString("GadgetClass")))
                    {
                        txt += " class=\"" + base.GetModuleParamString("GadgetClass") + "\"";
                    }
                    txt += "></div>";
                }
                litGadget.Text = txt;
                om.LoadAssets();
            }
        }

    }
}