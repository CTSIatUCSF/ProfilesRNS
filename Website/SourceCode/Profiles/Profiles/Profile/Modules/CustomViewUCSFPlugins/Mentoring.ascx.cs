using System;
using System.Collections.Generic;
using System.Web.UI.HtmlControls;
using System.Xml;

using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.CustomViewUCSFPlugins
{
    public partial class Mentoring : BaseUCSFModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public Mentoring() : base() { }
        public Mentoring(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/Mentoring.js");
            Page.Header.Controls.Add(jsscript1);

            //litjs.Text = base.jsStart + "var globalHealthData = " + Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "GlobalHealth") + "; GlobalHealth.init(globalHealthData);" + base.jsEnd;

            litjs.Text = base.jsStart + "Mentoring.init('" + Brand.GetCurrentBrand().GetInstitution().GetAbbreviation() + "', '" + Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "Mentoring").Replace("'", "\\'").Replace("\\\"", "\\\\\"") + "'); " + base.jsEnd;
        }
    }
}