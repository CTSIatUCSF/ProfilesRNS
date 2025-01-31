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
    public partial class Identity : BaseUCSFModule
    {
        private string PlugInName = "Identity";
        private string data = string.Empty;
        private IdentityData iData = new IdentityData();

        public Identity() : base() { }
        public Identity(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            string[] race = null;
            string[] sexualOrientation = null;
            string[] genderIdentity = null; 
            string[] other;

            race = new string[] { "Asian", "Black or African-American", "Latinx", "Multi-Race/Ethnicity​", "Native American or Alaska Native",
                                  "Something Else", "Native Hawaiian or Pacific Islander", "Southwest Asian and North African", "Unknown", "White" };
            sexualOrientation = new string[] {"Asexual", "Bisexual", "Gay", "Lesbian", "Straight", "Something Else"};
            genderIdentity = new string[] { "Female", "Male", "Non-Binary/Gender Queer", "Transgender Female", "Transgender Male", "Something Else" };
            other = new string[] { "Differently-abled", "Veteran" };

            foreach (string s in race)
            {
                cblRace.Items.Add(s);
            }
            foreach (string s in sexualOrientation)
            {
                cblSexualOrientation.Items.Add(s);
            }
            foreach (string s in genderIdentity)
            {
                cblGenderIdentity.Items.Add(s);
            }
            foreach (string s in other)
            {
                cblOther.Items.Add(s);
            }
            ReadJson();
            upnlEditSection.Update();
            upnlEditIdentity.Update();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {
            upnlEditSection.Update();
        }


        protected void btnSave_OnClick(object sender, EventArgs e)
        {
            iData.narrative = txtNarrative.Text.Trim();
            iData.race = GetCheckBoxListSelectedItems(cblRace);
            iData.sexualOrientation = GetCheckBoxListSelectedItems(cblSexualOrientation);
            iData.genderIdentity = GetCheckBoxListSelectedItems(cblGenderIdentity);
            iData.other = GetCheckBoxListSelectedItems(cblOther);

            GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
            ResetDisplay();
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        protected void btnDelete_OnClick(object sender, EventArgs e)
        {
            GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            ResetDisplay();
        }

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;

            Session["pnlIdentity.Visible"] = null;

            txtNarrative.Text = string.Empty;

            this.data = string.Empty;
            this.iData = null;

            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            
            ReadJson();            
            upnlEditSection.Update();
            upnlEditIdentity.Update();
        }

        private bool HasNoIdentityData()
        {
            return iData == null || (String.IsNullOrEmpty(iData.narrative) && iData.race.Count == 0 && iData.sexualOrientation.Count == 0 &&
                                     iData.genderIdentity.Count == 0 && iData.other.Count == 0);
        }

        private void ReadJson()
        {
            this.iData = JsonConvert.DeserializeObject<IdentityData>(this.data);
            if (this.iData == null)
            {
                this.iData = new IdentityData();
            }
            if (!HasNoIdentityData())
            {
                txtNarrative.Text = iData.narrative;
                SetCheckBoxListSelectedItems(iData.race, cblRace);
                SetCheckBoxListSelectedItems(iData.sexualOrientation, cblSexualOrientation);
                SetCheckBoxListSelectedItems(iData.genderIdentity, cblGenderIdentity);
                SetCheckBoxListSelectedItems(iData.other, cblOther);
            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.iData);
        }

        private string GetSearchData()
        {
            string search = "Identity " + iData.narrative;
            foreach (String s in this.iData.race)
            {
                search += " " + s;
            }
            foreach (String s in this.iData.sexualOrientation)
            {
                search += " " + s;
            }
            foreach (String s in this.iData.genderIdentity)
            {
                search += " " + s;
            }
            foreach (String s in this.iData.other)
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


    public class IdentityData
    {
        public string narrative { get; set; }
        public List<string> race { get; set; } 
        public List<string> sexualOrientation { get; set; } 
        public List<string> genderIdentity { get; set; } 
        public List<string> other { get; set; } 
        public IdentityData()
        {
            narrative = "";
            race = new List<string>();
            sexualOrientation = new List<string>();
            genderIdentity = new List<string>();
            other = new List<string>();
        }
    }
}