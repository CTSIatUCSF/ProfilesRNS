using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Xml;
using Newtonsoft.Json;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Profiles.Profile.Modules;
using Profiles.Edit.Utilities;
using Newtonsoft.Json.Linq;
using Profiles.ORCID.Utilities.ProfilesRNSDLL.DevelopmentBase.Helpers;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class CommunityAndPublicService : BaseUCSFModule
    {
        private string PlugInName = "CommunityAndPublicService";
        private List<CommunityAndPublicServiceEntry> entries { get; set; }


        public CommunityAndPublicService() : base() { }
        public CommunityAndPublicService(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {

            SessionManagement sm = new SessionManagement();
            securityOptions.Subject = SubjectID;
            securityOptions.PredicateURI = PredicateURI.Replace("!", "#");
            securityOptions.PrivacyCode = Convert.ToInt32(PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDocument();
            securityOptions.SecurityGroups.LoadXml(PresentationXML.DocumentElement.LastChild.OuterXml);
            securityOptions.BubbleClick += SecurityDisplayed;

            litBackLink.Text = "<a href='" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + SubjectID + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            ReadJson();
            InitUpDownArrows(ref GridViewPlugin);
            upnlEditSection.Update();
            LoadAssets();
            // this will turn it off for UCSF if it is disabled;
            pnlCopyFromAdvance.Visible &= Advance.IsAdvanceEnabled();
            imbAdvanceArrow.Visible = Advance.IsAdvanceEnabledFor(UCSFIDSet.ByNodeId[SubjectID].Institution);
        }

        private void LoadAssets()
        {
            /* Is this needed?
            HtmlGenericControl jsscript1 = new HtmlGenericControl("script");
            jsscript1.Attributes.Add("type", "text/javascript");
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/jquery.validate.min.js");
            Page.Header.Controls.Add(jsscript1);
            */
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {
            if (Session["pnlSecurityOptions.Visible"] == null)
            {

                pnlAddEdit.Visible = true;
            }
            else
            {
                pnlAddEdit.Visible = false;
            }

            upnlEditSection.Update();
        }

        protected void btnAddEdit_OnClick(object sender, EventArgs e)
        {
            string SessionKey = "pnlImport" + this.PlugInName + ".Visible";
            if (Session[SessionKey] == null)
            {
                pnlInsert.Visible = true;
                imbAddArrow.ImageUrl = "~/Framework/Images/icon_squareDownArrow.gif";


                phSecuritySettings.Visible = false;
                Session[SessionKey] = true;
            }
            else
            {
                pnlInsert.Visible = false;
                imbAddArrow.ImageUrl = "~/Framework/Images/icon_squareArrow.gif";
                Session[SessionKey] = null;
                phSecuritySettings.Visible = true;
            }

        }

        protected void btnSaveAndAdd_OnClick(object sender, EventArgs e)
        {
            if (txtInstitution.Text != "" || txtStartYear.Text != "" || txtEndYear.Text != "" || txtRole.Text != "")
            {
                string search = string.Empty;

                if (this.entries == null) { this.entries = new List<CommunityAndPublicServiceEntry>(); }

                CommunityAndPublicServiceEntry entry = new CommunityAndPublicServiceEntry(txtInstitution.Text, txtStartYear.Text, txtEndYear.Text, txtRole.Text);
                this.entries.Insert(0, entry);

                SaveData();
            }
            ResetDisplay();
            pnlInsert.Visible = true;
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            if (txtInstitution.Text != "" || txtStartYear.Text != "" || txtEndYear.Text != "" || txtRole.Text != "")
            {
                string search = string.Empty;

                if (this.entries == null) { this.entries = new List<CommunityAndPublicServiceEntry>(); }

                CommunityAndPublicServiceEntry entry = new CommunityAndPublicServiceEntry(txtInstitution.Text, txtStartYear.Text, txtEndYear.Text, txtRole.Text);
                this.entries.Insert(0, entry);

                SaveData();
            }
            ResetDisplay();
        }

        protected void btnDeleteCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }
        protected void btnSaveCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        protected void btnCopyFromAdvance_OnClick(object sender, EventArgs e)
        {
            try
            {
                JToken itemsToken = Advance.getPublicServiceFor(this.SubjectID);
                List<CommunityAndPublicServiceEntry> newEntries = new List<CommunityAndPublicServiceEntry>();
                int existing = GridViewPlugin.Rows.Count;
                if (itemsToken != null)
                {
                    foreach (JToken item in itemsToken)
                    {
                        newEntries.Add(new CommunityAndPublicServiceEntry((string)item["orgOrProg"], (string)item["startDate"], (string)item["endDate"], (string)item["role"]));
                    }
                    // swap in if we have any
                    if (newEntries.Count > 0)
                    {
                        entries = newEntries;
                        SaveData();
                    }
                    else
                    {
                        litAdvanceMessage.Text = "No Community or Public Service items found for your profile.";
                    }
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + ex.StackTrace);
                litAdvanceMessage.Text = ex.Message;
            }
            upnlEditSection.Update();
        }

        protected void btnSort_OnClick(object sender, EventArgs e)
        {
            //sort
            entries.Sort((a, b) => b.CompareTo(a));
            SaveData();
            ResetDisplay();
        }

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;
            Session["pnlImportVideo.Visible"] = null;
            pnlAddEdit.Visible = true;
            txtInstitution.Text = string.Empty;
            txtStartYear.Text = string.Empty;
            txtEndYear.Text = string.Empty;
            txtRole.Text = string.Empty;

            this.entries = null;

            ReadJson();
            upnlEditSection.Update();
        }
        private void ReadJson()
        {
            string data = GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            entries = JsonConvert.DeserializeObject<List<CommunityAndPublicServiceEntry>>(data);
            if (entries == null || entries.Count == 0)
            {
                divNoEntries.Visible = true;
                GridViewPlugin.Visible = false;
            }
            else
            {

                divNoEntries.Visible = false;
                GridViewPlugin.Visible = true;
                GridViewPlugin.DataSource = entries;
                GridViewPlugin.DataBind();
                InitUpDownArrows(ref GridViewPlugin);
            }
        }

        private string SerializeJson()
        {
            string rtn = Regex.Replace(JsonConvert.SerializeObject(this.entries, Newtonsoft.Json.Formatting.Indented), @"\t|\n|\r", "");

            return rtn.Replace("[]", "");  // make it empty if its empty json
        }

        #region "Grid"
        protected void GridViewPlugin_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //e.Row.Cells[1].Attributes.Add("style", "width:200px;text-align:center;padding-top:7px;");
        }

        protected void GridViewPlugin_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewPlugin.EditIndex = e.NewEditIndex;
            ReadJson();
            upnlEditSection.Update();
        }
        protected void GridViewPlugin_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
            ResetDisplay();
            InitUpDownArrows(ref GridViewPlugin);
            upnlEditSection.Update();
        }
        protected void GridViewPlugin_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            HiddenField hdID = (HiddenField)GridViewPlugin.Rows[e.RowIndex].FindControl("hdID");

            TextBox txtInstitution = (TextBox)GridViewPlugin.Rows[e.RowIndex].FindControl("txtInstitution");
            TextBox txtStartDate = (TextBox)GridViewPlugin.Rows[e.RowIndex].FindControl("txtStartDate");
            TextBox txtEndDate = (TextBox)GridViewPlugin.Rows[e.RowIndex].FindControl("txtEndDate");
            TextBox txtRole = (TextBox)GridViewPlugin.Rows[e.RowIndex].FindControl("txtRole");

            CommunityAndPublicServiceEntry found = this.entries[e.RowIndex];

            found.institution = txtInstitution.Text;
            found.startDate = txtStartDate.Text;
            found.endDate = txtEndDate.Text;
            found.role = txtRole.Text;

            SaveData();
            ResetDisplay();

            GridViewPlugin.EditIndex = -1;
            ResetDisplay();
            upnlEditSection.Update();
        }
        protected void GridViewPlugin_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewPlugin.EditIndex = -1;

            ResetDisplay();
            upnlEditSection.Update();
        }
        protected void GridViewPlugin_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            CommunityAndPublicServiceEntry found = this.entries[e.RowIndex];
            if (found != null) this.entries.Remove(found);

            if (GridViewPlugin.Rows.Count == 1) //they just deleted their last row
            {
                GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            }
            else
            {
                SaveData();
            }

            ResetDisplay();
            InitUpDownArrows(ref GridViewPlugin);
            upnlEditSection.Update();
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;

            GridViewPlugin.EditIndex = -1;
            int newIndex = row.RowIndex - 1;
            int oldIndex = row.RowIndex;

            var item = this.entries[oldIndex];

            this.entries.RemoveAt(oldIndex);
            this.entries.Insert(newIndex, item);

            SaveData();
            ResetDisplay();

        }
        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;
            GridViewPlugin.EditIndex = -1;

            int newIndex = row.RowIndex + 1;
            int oldIndex = row.RowIndex;

            var item = this.entries[oldIndex];

            this.entries.RemoveAt(oldIndex);
            this.entries.Insert(newIndex, item);

            SaveData();
            ResetDisplay();
        }

        private void SaveData()
        {
            string search = "Community and Public Service";
            foreach (CommunityAndPublicServiceEntry v in this.entries)
            {
                search += " " + v.GetSearchTerm();
            }
            GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);
        }

        #endregion

        public class CommunityAndPublicServiceEntry : IComparable<CommunityAndPublicServiceEntry>
        {
            public string institution { get; set; }
            public string startDate { get; set; }
            public string endDate { get; set; }
            public string role { get; set; }

            public CommunityAndPublicServiceEntry(string institution, string startingYear, string endingYear, string role)
            {
                this.institution = institution;
                this.startDate = String.IsNullOrEmpty(startingYear) ? "" : startingYear.Trim();
                this.endDate = String.IsNullOrEmpty(endingYear) ? "" : endingYear.Trim();
                this.role = role;
            }

            public string GetSearchTerm()
            {
                return institution + " " + startDate + " " + endDate + " " + role;
            }

            public int CompareTo(CommunityAndPublicServiceEntry other)
            {
                return this.startDate.Equals(other.startDate) ? this.endDate.CompareTo(other.endDate) : this.startDate.CompareTo(other.startDate);
            }
        }

    }

}