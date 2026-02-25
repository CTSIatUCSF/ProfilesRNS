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
using Profiles.CustomAPI.Utilities;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class EditCollaborationInterests : BaseUCSFModule
    {
        private static string PlugInName = "CollaborationInterests";
        private CollaborationInterestsData ciData = new CollaborationInterestsData();
        private List<CheckBox> collaborationInterestsOptions = new List<CheckBox>();

        public EditCollaborationInterests() : base() { }
        public EditCollaborationInterests(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {

            SessionManagement sm = new SessionManagement();
            securityOptions.Subject = base.SubjectID;
            securityOptions.PredicateURI = base.PredicateURI.Replace("!", "#");
            securityOptions.PrivacyCode = Convert.ToInt32(base.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);
            securityOptions.BubbleClick += SecurityDisplayed;

            litBackLink.Text = "<a href='" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + this.SubjectID + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";

            // add each one
            collaborationInterestsOptions.Add(cbAcademicCollaboration);
            collaborationInterestsOptions.Add(cbAcademicSenateCommitteeService);
            collaborationInterestsOptions.Add(cbMultiyearClinicalResearch);
            collaborationInterestsOptions.Add(cbCommunityandPartnerOrganizations);
            collaborationInterestsOptions.Add(cbCompainesandEntrepreuners);
            collaborationInterestsOptions.Add(cbPolicyChange);
            collaborationInterestsOptions.Add(cbPress);
            collaborationInterestsOptions.Add(cbProspectiveDonors);
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            ReadJson(Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, PlugInName));
            upnlEditSection.Update();
            upnlEditCollaborationInterests.Update();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {
            upnlEditSection.Update();
        }
        protected void btnAddEdit_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        protected void btnSave_OnClick(object sender, EventArgs e)
        {
            ciData.narrative = txtNarrative.Text.Trim();
            foreach (CheckBox cb in collaborationInterestsOptions)
            {
                if (cb.Checked)
                {
                    if (!ciData.collaborationInterests.Contains(cb.Text))
                    {
                        ciData.collaborationInterests.Add(cb.Text);
                    }
                }
                else
                {
                    ciData.collaborationInterests.Remove(cb.Text);
                }
            }

            GenericRDFDataIO.AddEditPluginData(PlugInName, this.SubjectID, this.SerializeJson(), ciData.GetSearchData());
            ResetDisplay();
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        protected void btnDelete_OnClick(object sender, EventArgs e)
        {
            //GenericRDFDataIO.RemovePluginData(PlugInName, this.SubjectID);
            GenericRDFDataIO.AddEditPluginData(PlugInName, this.SubjectID, "", "");
            ResetDisplay();
        }

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;

            Session["pnlIdentity.Visible"] = null;

            // is this necessary?
            txtNarrative.Text = string.Empty;

            this.ciData = null;

            string data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, PlugInName);
            
            ReadJson(data);            
            upnlEditSection.Update();
            upnlEditCollaborationInterests.Update();
        }

        private bool HasNoCollaborationInterestsData()
        {
            return ciData == null || (String.IsNullOrEmpty(ciData.narrative) && ciData.collaborationInterests.Count == 0);
        }

        private void ReadJson(string data)
        {
            this.ciData = JsonConvert.DeserializeObject<CollaborationInterestsData>(data);
            if (this.ciData == null)
            {
                this.ciData = new CollaborationInterestsData();
            }
            txtNarrative.Text = HasNoCollaborationInterestsData() ? "" : ciData.narrative;
            litLastUpdated.Text = HasNoCollaborationInterestsData() ? "" : ciData.lastUpdated;
            foreach(CheckBox cb in collaborationInterestsOptions)
            {
                cb.Checked = HasNoCollaborationInterestsData() ? false : ciData.collaborationInterests.Contains(cb.Text);
            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.ciData);
        }
    }


    public class CollaborationInterestsData
    {
        public List<string> collaborationInterests { get; set; }
        public string narrative { get; set; }
        public string lastUpdated { get; set; }
        public CollaborationInterestsData()
        {
            narrative = "";
            collaborationInterests = new List<string>();
            lastUpdated = DateTime.Today.ToString("D");
        }

        public string GetSearchData()
        {
            return "Collaboration Interest, " + string.Join(", ", collaborationInterests) + ", " + narrative;
        }
    }
}