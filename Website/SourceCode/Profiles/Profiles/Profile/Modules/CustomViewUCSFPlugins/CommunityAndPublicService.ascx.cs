﻿using System;
using System.Collections.Generic;
using System.Web.UI.HtmlControls;
using System.Xml;

using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.CustomViewUCSFPlugins
{
    public partial class CommunityAndPublicService : BaseUCSFModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public CommunityAndPublicService() : base() { }
        public CommunityAndPublicService(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            LoadAssets();

        }

        private void LoadAssets()
        {
            HtmlLink Displaycss = new HtmlLink();
            Displaycss.Href = Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/UCSFPluginStyle.css";
            Displaycss.Attributes["rel"] = "stylesheet";
            Displaycss.Attributes["type"] = "text/css";
            Displaycss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Displaycss);

            HtmlGenericControl jsscript1 = new HtmlGenericControl("script");
            jsscript1.Attributes.Add("type", "text/javascript");
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/CommunityAndPublicService.js");
            Page.Header.Controls.Add(jsscript1);

            litjs.Text = base.jsStart + "CommunityAndPublicService.init('" + Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "CommunityAndPublicService").Replace("'", "\\'") + "'); " + base.jsEnd;
        }
    }
}