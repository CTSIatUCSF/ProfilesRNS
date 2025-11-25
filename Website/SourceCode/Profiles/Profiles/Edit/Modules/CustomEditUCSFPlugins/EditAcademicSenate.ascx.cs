using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Profiles.Edit.Utilities;
using Profiles.Framework.Utilities;
using Profiles.Profile.Modules;
using System;
using System.Collections.Generic;
using System.Web.UI.HtmlControls;
using System.Xml;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class AcademicSenate : BaseUCSFModule
    {
        private string PlugInName = "AcademicSenate";
        private string data = string.Empty;

        public AcademicSenate() : base() { }
        public AcademicSenate(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {

            SessionManagement sm = new SessionManagement();
            securityOptions.Subject = base.SubjectID;
            securityOptions.PredicateURI = base.PredicateURI.Replace("!", "#");
            securityOptions.PrivacyCode = Convert.ToInt32(base.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);
            securityOptions.BubbleClick += SecurityDisplayed;

            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);

            litBackLink.Text = "<a href='" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + this.SubjectID + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            ReadJson();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {

            if (Session["pnlSecurityOptions.Visible"] == null)
            {
                pnlAddEditAcademicSenate.Visible = true;
            }
            else
            {
                pnlAddEditAcademicSenate.Visible = false;
            }

            upnlEditSection.Update();
        }

        private void ReadJson()
        {
            String pluginData = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "AcademicSenate");
            if (String.IsNullOrEmpty(pluginData))
            {
                phSecuritySettings.Visible = false;
                pnlAddEditAcademicSenate.Visible = false;
            }
            else
            {
                pnlNoData.Visible = false;
                HtmlGenericControl jsscript1 = new HtmlGenericControl("script");
                jsscript1.Attributes.Add("type", "text/javascript");
                jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/AcademicSenate.js");
                Page.Header.Controls.Add(jsscript1);
                litjs.Text = base.jsStart + "AcademicSenate.init('" + pluginData.Replace("'", "\\'").Replace("\\\"", "\\\\\"") + "'); " + base.jsEnd;
            }
        }
    }
}