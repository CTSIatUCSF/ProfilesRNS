using System;
using System.Collections.Generic;
using System.Web.UI.HtmlControls;
using System.Xml;

using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.CustomViewUCSFPlugins
{
    public partial class RequiredScholarlyProjectMentor : BaseUCSFModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        public RequiredScholarlyProjectMentor() : base() { }
        public RequiredScholarlyProjectMentor(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
        }
    }
}