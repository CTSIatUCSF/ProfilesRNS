using System;
using System.Collections.Generic;
using System.Web.UI.HtmlControls;
using System.Xml;

using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.CustomViewUCSFPlugins
{
    public partial class GlobalHealthEquity : BaseUCSFModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public GlobalHealthEquity() : base() { }
        public GlobalHealthEquity(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/GlobalHealthEquity.js");
            Page.Header.Controls.Add(jsscript1);

            //litjs.Text = base.jsStart + "var globalHealthData = " + Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "GlobalHealth") + "; GlobalHealth.init(globalHealthData);" + base.jsEnd;

            litjs.Text = base.jsStart + "GlobalHealthEquity.init('" + Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "GlobalHealthEquity") + "'); " + base.jsEnd;
        }
    }
}