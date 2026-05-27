using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Xml;
using Newtonsoft.Json;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Profiles.Profile.Modules;
using System.Linq;
using Newtonsoft.Json.Linq;
using Profiles.Edit.Utilities;
using System.CodeDom;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class RequiredScholarlyProjectMentor : BaseUCSFModule
    {
        private string PlugInName = "RequiredScholarlyProjectMentor";
        private string data = string.Empty;
        private static string CONTENT = "Required Scholarly Project Mentor";

        public RequiredScholarlyProjectMentor() : base() { }
        public RequiredScholarlyProjectMentor(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {

            SessionManagement sm = new SessionManagement();
            securityOptions.Subject = base.SubjectID;
            securityOptions.PredicateURI = base.PredicateURI.Replace("!", "#");
            securityOptions.PrivacyCode = Convert.ToInt32(base.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);
            securityOptions.BubbleClick += SecurityDisplayed;

            //this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);

            litBackLink.Text = "<a href='" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + this.SubjectID + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            upnlEditSection.Update();
            // do I need to call this here?
            ResetDisplay(true);
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {
            upnlEditSection.Update();
        }


        protected void btnAdd_OnClick(object sender, EventArgs e)
        {
            GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, CONTENT, CONTENT);
            ResetDisplay(false);
        }

        protected void btnDelete_OnClick(object sender, EventArgs e)
        {
            GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            // should we also need to reset the data to blank strings? Above seems to just orphan the data
            ResetDisplay(false);
        }

        private void ResetDisplay(bool pageLoad)
        {
            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            if (CONTENT.Equals(data))
            {
                // they have it
                btnAdd.Visible = false;
                btnDelete.Visible = true;
                litStatus.Text = CONTENT + " has been added to your profile page";
            }
            else
            {
                btnAdd.Visible = true;
                btnDelete.Visible = false;
                litStatus.Text = CONTENT + (pageLoad ? " is not on your profile page" : " has been removed from your profile page");
            }
        }
    }
}