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
    public partial class EditUCSDFacultyMentoring : BaseUCSFModule
    {
        private static string PlugInName = "UCSDFacultyMentoring";
        private UCSDFacultyMentoringData ciData = new UCSDFacultyMentoringData();
        private List<CheckBox> availableToMentor = new List<CheckBox>();
        private List<CheckBox> contactPreferences = new List<CheckBox>();

        public EditUCSDFacultyMentoring() : base() { }
        public EditUCSDFacultyMentoring(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            availableToMentor.Add(cbJuniorFaculty);
            availableToMentor.Add(cbMedicalFellows);
            availableToMentor.Add(cbPostdoctoralTrainees);
            availableToMentor.Add(cbGraduateStudents);
            availableToMentor.Add(cbMecicalAndPharmacyStudents);
            availableToMentor.Add(cbUndergraduateStudents);

            // clean this up
            contactPreferences.Add(cbEmail);
            contactPreferences.Add(cbPhone);
            contactPreferences.Add(cbAssistant);
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            ReadJson(Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, PlugInName));
            upnlEditSection.Update();
            upnlEditUCSDFacultyMentoring.Update();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {
            upnlEditSection.Update();
        }

        protected void btnSave_OnClick(object sender, EventArgs e)
        {
            CBsToStrings(availableToMentor, ciData.availableToMentor);
            CBsToStrings(contactPreferences, ciData.contactPreferences);
            ciData.assistantName = txtAssistantName.Text.Trim();
            ciData.assistantEmail = txtAssistantEmail.Text.Trim();
            ciData.assistantPhone = txtAssistantPhone.Text.Trim();
            ciData.narrative = txtNarrative.Text.Trim();

            if (!String.IsNullOrEmpty(ciData.assistantName + ciData.assistantEmail + ciData.assistantPhone) && !ciData.contactPreferences.Contains("Assistant"))
            {
                ciData.contactPreferences.Add("Assistant");
            }
            else if (String.IsNullOrEmpty(ciData.assistantName + ciData.assistantEmail + ciData.assistantPhone) && ciData.contactPreferences.Contains("Assistant"))
            {
                ResetDisplay("Please provide assistant contant information.");
            }
            else
            {
                GenericRDFDataIO.AddEditPluginData(PlugInName, this.SubjectID, this.SerializeJson(), ciData.GetSearchData());
                ResetDisplay(HasNoFacultyMentoringData() ? "" : "Faculty Mentoring has been added to your profile.");
            }
        }

        private void CBsToStrings(List<CheckBox> cbs, List<string> strs)
        {
            foreach (CheckBox cb in cbs)
            {
                if (cb.Checked)
                {
                    if (!strs.Contains(cb.Text))
                    {
                        strs.Add(cb.Text);
                    }
                }
                else
                {
                    strs.Remove(cb.Text);
                }
            }
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay("");
        }

        protected void btnDelete_OnClick(object sender, EventArgs e)
        {
            //GenericRDFDataIO.RemovePluginData(PlugInName, this.SubjectID);
            GenericRDFDataIO.AddEditPluginData(PlugInName, this.SubjectID, "", "");
            ResetDisplay("Faculty Mentoring has been removed from your profile.");
        }

        private void ResetDisplay(String message)
        {
            phSecuritySettings.Visible = true;

            // is this necessary?
            txtNarrative.Text = string.Empty;

            this.ciData = null;

            string data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, PlugInName);
            lblMessage.Text = message;

            ReadJson(data);            
            upnlEditSection.Update();
            upnlEditUCSDFacultyMentoring.Update();
        }

        private bool HasNoFacultyMentoringData()
        {
            // if these are blank then blank them all
            return ciData == null || (String.IsNullOrEmpty(ciData.narrative) && ciData.availableToMentor.Count == 0);
        }

        private void ReadJson(string data)
        {
            this.ciData = JsonConvert.DeserializeObject<UCSDFacultyMentoringData>(data);
            if (this.ciData == null)
            {
                this.ciData = new UCSDFacultyMentoringData();
            }
            txtAssistantName.Text = HasNoFacultyMentoringData() ? "" : ciData.assistantName;
            txtAssistantEmail.Text = HasNoFacultyMentoringData() ? "" : ciData.assistantEmail;
            txtAssistantPhone.Text = HasNoFacultyMentoringData() ? "" : ciData.assistantPhone;
            txtNarrative.Text = HasNoFacultyMentoringData() ? "" : ciData.narrative;
            litLastUpdated.Text = HasNoFacultyMentoringData() ? "" : ciData.lastUpdated;
            foreach(CheckBox cb in availableToMentor)
            {
                cb.Checked = HasNoFacultyMentoringData() ? false : ciData.availableToMentor.Contains(cb.Text);
            }
            foreach (CheckBox cb in contactPreferences)
            {
                cb.Checked = HasNoFacultyMentoringData() ? false : ciData.contactPreferences.Contains(cb.Text);
            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.ciData);
        }

        protected void itmChanged(object sender, EventArgs e)
        {
            lblMessage.Text = "";
        }

    }


    public class UCSDFacultyMentoringData
    {
        public List<string> availableToMentor { get; set; }
        public List<string> contactPreferences { get; set; }
        public string assistantName { get; set; }
        public string assistantEmail { get; set; }
        public string assistantPhone { get; set; }
        public string narrative { get; set; }
        public string lastUpdated { get; set; }
        public UCSDFacultyMentoringData()
        {
            availableToMentor = new List<string>();
            contactPreferences = new List<string>();
            assistantName = "";
            assistantEmail = "";
            assistantPhone = "";
            narrative = "";
            lastUpdated = DateTime.Today.ToString("D");
        }

        public string GetSearchData()
        {
            return "Faculty Mentoring, " + string.Join(", ", availableToMentor) + string.Join(", ", contactPreferences) + 
                ", " + narrative;
        }
    }
}