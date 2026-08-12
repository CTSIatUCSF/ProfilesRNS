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

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class USCMentoring : BaseUCSFModule
    {
        private string PlugInName = "USCMentoring";
        private USCMentoringData mData = new USCMentoringData();

        public USCMentoring() : base() { }
        public USCMentoring(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            string[] availableFor = null;
            string[] contactPreferences = null;

            availableFor = new string[] { "Career Mentor", "Co-Mentor", "Lead Research / Scholarly Mentor ", "Project Mentor" };
            contactPreferences = new string[] {"Email", "Phone"};

            foreach (string s in availableFor)
            {
                cblAvailableFor.Items.Add(s);
            }
            foreach (string s in contactPreferences)
            {
                cblContactPreferences.Items.Add(s);
            }
            ReadJson(Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, PlugInName));
            upnlEditSection.Update();
            upnlEditMentoring.Update();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {
            upnlEditSection.Update();
        }


        protected void btnSave_OnClick(object sender, EventArgs e)
        {
            mData.availableFor = GetCheckBoxListSelectedItems(cblAvailableFor);
            mData.contactPreferences = GetCheckBoxListSelectedItems(cblContactPreferences);

            GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
            ResetDisplay();
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        protected void btnDelete_OnClick(object sender, EventArgs e)
        {
            // maybe remove this button?
            GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            ResetDisplay();
        }

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;

            this.mData = null;

            ReadJson(Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, PlugInName));            
            upnlEditSection.Update();
            upnlEditMentoring.Update();
        }

        private bool HasMentoringData()
        {
            return mData != null && "true".Equals(mData.hasUSCMentoring.ToLower()) ;
        }

        private void ReadJson(string data)
        {
            this.mData = JsonConvert.DeserializeObject<USCMentoringData>(data);
            if (HasMentoringData())
            {
                pnlNoData.Visible = false;
                upnlEditMentoring.Visible = true;
                SetCheckBoxListSelectedItems(mData.availableFor, cblAvailableFor);
                SetCheckBoxListSelectedItems(mData.contactPreferences, cblContactPreferences);
            }
            else
            {
                pnlNoData.Visible = true;
                upnlEditMentoring.Visible = false;
            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.mData);
        }

        private string GetSearchData()
        {
            string search = "USCMentoring Mentoring ";
            foreach (String s in this.mData.availableFor)
            {
                search += " " + s;
            }
            return search;
        }

        private List<string> GetCheckBoxListSelectedItems(CheckBoxList cbl)
        {
            List<string> retval = new List<string>(); ;
            foreach (ListItem item in cbl.Items)
            {
                if (item.Selected)
                {
                    retval.Add(item.Text);
                }
            }
            return retval;
        }

        private void SetCheckBoxListSelectedItems(List<string> values, CheckBoxList cbl)
        {
            foreach (ListItem item in cbl.Items)
            {
                item.Selected = values.Contains(item.Text); 
            }
        }
    }


    public class USCMentoringData
    {
        public string hasUSCMentoring { get; set; }
        public List<string> availableFor { get; set; } 
        public List<string> contactPreferences { get; set; }
        public string lastUpdated { get; set; }

        public USCMentoringData()
        {
            hasUSCMentoring = "";
            availableFor = new List<string>();
            contactPreferences = new List<string>();
            lastUpdated = DateTime.Today.ToString("D");
        }
    }
}