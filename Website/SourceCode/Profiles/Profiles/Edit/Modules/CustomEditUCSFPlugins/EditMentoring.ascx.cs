using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Xml;
using Newtonsoft.Json;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Profiles.Profile.Modules;
using System.Linq;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class Mentoring : BaseUCSFModule
    {
        private string PlugInName = "Mentoring";
        private string data = string.Empty;
        private MentoringData mData = new MentoringData();

        public Mentoring() : base() { }
        public Mentoring(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            string[] mentees = null;
            string[] types = null; ;
            if ("UC Davis".Equals(UCSFIDSet.ByNodeId[this.SubjectID].Institution.GetAbbreviation()))
            {
                mentees = new string[] {"Undergraduate Students",
                                                       "Graduate and Professional Students",
                                                       "Postdoctoral Scholars and Research Scientists",
                                                       "Residents, Fellows, and House Officers",
                                                       "Faculty"};
                types = new string[] {"Research",
                                                       "Career Development Path",
                                                       "Work/life balance"};
            }
            else if ("UCSF".Equals(UCSFIDSet.ByNodeId[this.SubjectID].Institution.GetAbbreviation()))
            {
                mentees = new string[] {"UCSF Students",
                                                       "Faculty",
                                                       "Staff",
                                                       "Residents and Fellows"};
                types = new string[] {"Clinical Practice",
                                                       "Education Career",
                                                       "Research",
                                                       "Research Projects",
                                                       "Career Development",
                                                       "Work/Life Balance",
                                                       "Diversity, Equity, Inclusion and Belonging"};
            }

            foreach (string s in mentees)
            {
                ddlMentee.Items.Add(s);
            }
            foreach (string s in types)
            {
                ddlType.Items.Add(s);
            }
            base.InitUpDownArrows(ref GridViewMentoringInterests);
            upnlEditSection.Update();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {

            if (Session["pnlSecurityOptions.Visible"] == null)
            {
                pnlAddEditMentoring.Visible = true;
            }
            else
            {
                pnlAddEditMentoring.Visible = false;
            }

            upnlEditSection.Update();
        }

        protected void btnAddEdit_OnClick(object sender, EventArgs e)
        {
            string sessionKey = "pnlMentoring.Visible";

            if (Session[sessionKey] == null)
            {
                imbAddArrowInterest.ImageUrl = "~/Framework/Images/icon_squareDownArrow.gif";

                phSecuritySettings.Visible = false;
                pnlAddEditMentoring.Visible = false;
                pnlMentoringInterests.Visible = true;
                Session[sessionKey] = true;
            }
            else
            {
                phSecuritySettings.Visible = true;
                pnlAddEditMentoring.Visible = true;
                pnlMentoringInterests.Visible = false;
                imbAddArrowInterest.ImageUrl = "~/Framework/Images/icon_squareArrow.gif";
                Session[sessionKey] = null;
            }
            lblRedundantEntry.Visible = false;
        }

        protected void btnInsert_OnClick(object sender, EventArgs e)
        {
            btnSaveAndClose_OnClick(sender, e);

            phSecuritySettings.Visible = false;
            pnlAddEditMentoring.Visible = false;
            pnlMentoringInterests.Visible = true;
        }

        protected void btnSaveNarrative_OnClick(object sender, EventArgs e)
        {
            mData.narrative = txtNarrative.Text.Trim();
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
            ResetDisplay();
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            if (ddlMentee.SelectedValue != string.Empty && (ddlType.SelectedValue != string.Empty))
            {
                MentoringInterest interest = new MentoringInterest();
                interest.mentee = ddlMentee.SelectedValue;
                interest.type = ddlType.SelectedValue;

                if (mData.mentoringInterests.Contains(interest))
                {
                    lblRedundantEntry.Visible = true;
                    phSecuritySettings.Visible = false;
                    pnlAddEditMentoring.Visible = false;
                    pnlMentoringInterests.Visible = true;
                }
                else
                {
                    mData.mentoringInterests.Add(interest);
                    Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
                    ResetDisplay();
                }
            }
        }

        protected void btnDeleteCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }
        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;

            pnlAddEditMentoring.Visible = true;

            Session["pnlMentoring.Visible"] = null;

            txtNarrative.Text = string.Empty;
            ddlMentee.SelectedIndex = -1;
            ddlType.SelectedIndex = -1;

            this.data = string.Empty;
            this.mData = null;

            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            
            ReadJson();            
            upnlEditSection.Update();
        }

        private bool HasNoMentoringyData()
        {
            return mData == null || (String.IsNullOrEmpty(mData.narrative) && mData.mentoringInterests.Count == 0);
        }

        private void ReadJson()
        {
            this.mData = JsonConvert.DeserializeObject<MentoringData>(this.data);
            if (this.mData == null)
            {
                this.mData = new MentoringData();
            }

            if (HasNoMentoringyData())
            {
                divNoMentoring.Visible = true;
                GridViewMentoringInterests.Visible = false;
            }
            else
            {
                divNoMentoring.Visible = false;
                GridViewMentoringInterests.Visible = true;

                txtNarrative.Text = mData.narrative;

                GridViewMentoringInterests.DataSource = mData.mentoringInterests;
                GridViewMentoringInterests.DataBind();
                base.InitUpDownArrows(ref GridViewMentoringInterests);

            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.mData);
        }

        private string GetSearchData()
        {
            string search = "Mentoring " + mData.narrative;
            foreach (MentoringInterest v in this.mData.mentoringInterests)
            {
                search += " " + v.mentee + " " + v.type;
            }
            return search;
        }
        protected void GridViewMentoring_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            this.mData.mentoringInterests.RemoveAt(e.RowIndex);

            //this needs to be the json desz'd
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            if (HasNoMentoringyData()) //they just deleted their last row
            {
                Profiles.Framework.Utilities.GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            }

            ResetDisplay();
            base.InitUpDownArrows(ref GridViewMentoringInterests);
            upnlEditSection.Update();
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;

            GridViewMentoringInterests.EditIndex = -1;
            int newIndex = row.RowIndex - 1;
            int oldIndex = row.RowIndex;

            var item = this.mData.mentoringInterests[oldIndex];

            this.mData.mentoringInterests.RemoveAt(oldIndex);
            this.mData.mentoringInterests.Insert(newIndex, item);

            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            SerializeJson();
            ResetDisplay();

        }
        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;

            GridViewMentoringInterests.EditIndex = -1;

            int newIndex = row.RowIndex + 1;
            int oldIndex = row.RowIndex;

            var item = this.mData.mentoringInterests[oldIndex];

            this.mData.mentoringInterests.RemoveAt(oldIndex);
            this.mData.mentoringInterests.Insert(newIndex, item);
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            ResetDisplay();
        }
    }

    public class MentoringInterest : IEquatable<MentoringInterest>
    {
        public MentoringInterest()
        {
            mentee = "";
            type = "";
        }
        public string mentee { get; set; }
        public string type { get; set; }

        public bool Equals(MentoringInterest other)
        {
            return mentee.Equals(other.mentee) && type.Equals(other.type);
        }
        public override bool Equals(object obj) => Equals(obj as MentoringInterest);
        public override int GetHashCode()
        {
            return (mentee + type).GetHashCode();
        }
    }

    public class MentoringData
    {
        public MentoringData()
        {
            narrative = "";
            mentoringInterests = new List<MentoringInterest>();
        }
        public string narrative { get; set; }
        public List<MentoringInterest> mentoringInterests { get; set; }
    }
}