using Newtonsoft.Json;
using Profiles.Framework.Utilities;
using Profiles.Profile.Modules;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using System.Xml;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class EditUCDStudentProjects : BaseUCSFModule
    {
        private UCDStudentProjectsData spData = new UCDStudentProjectsData();
        private List<CheckBox> typeOfResearch = new List<CheckBox>();

        public EditUCDStudentProjects() : base() { }
        public EditUCDStudentProjects(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            typeOfResearch.Add(cbClinicalResearch);
            typeOfResearch.Add(cbBasicScience);
            typeOfResearch.Add(cbHealthDeliverPolicy);
        }
        protected override string GetPluginName()
        {
            return "UCDStudentProjects";
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            //if (IsPostBack)
            //{
                ReadData();
                ResetDisplay("");
            //}
        }


        private void ResetDisplay(String message)
        {

            if (HasNoStudentProjectData())
            {
                pnlAdd.Visible = true;
                pnlEdit.Visible = false;
                pnlDeleteAll.Visible = false;
            }
            else
            {
                pnlAdd.Visible = false;
                pnlEdit.Visible = true;
                pnlDeleteAll.Visible = true;

                litLastUpdated.Text = HasNoStudentProjectData() ? "" : spData.lastUpdated;

                // set the checkboxes
                foreach (CheckBox cb in typeOfResearch)
                {
                    cb.Checked = HasNoStudentProjectData() ? false : spData.typeOfResearch.Contains(cb.Text);
                }
                txtOther.Text = spData.typeOfResearchOther;

                // clear the project details, but check if this is necessary
                txtProjectName.Text = "";
                txtProjectLocation.Text = "";
                txtProjectObjectives.Text = "";
                txtStudentResponsibilities.Text = "";
                txtLink.Text = "";
                txtStartDate.Text = "";
                txtEndDate.Text = "";
                txtContactInfo.Text = "";
                hdnProjectKey.Value = "";

                // set the gridview
                GridViewPlugin.Visible = true;
                GridViewPlugin.DataSource = spData.currentProjects;
                GridViewPlugin.DataBind();
                if (spData.currentProjects.Count > 1)
                {
                    InitUpDownArrows(ref GridViewPlugin);
                }

                upnlEditSection.Update();
                upnlEditUCDStudentProjects.Update();

                phSecuritySettings.Visible = true;
            }

            lblMessage.Text = message;
        }
        private void SecurityDisplayed(object sender, EventArgs e)
        {
            upnlEditSection.Update();
        }

        protected void btnAdd_OnClick(object sender, EventArgs e)
        {
            pnlAdd.Visible = false;
            pnlEdit.Visible = true;
            pnlDeleteAll.Visible = true;
        }
        protected void btnDeleteAll_OnClick(object sender, EventArgs e)
        {
            ClearData();
            // create a new empty data object?
            spData = new UCDStudentProjectsData();
            ResetDisplay("Student Projects has been removed from your profile.");
        }
        protected void btnSaveResearchType_OnClick(object sender, EventArgs e)
        {
            CBsToStrings(typeOfResearch, spData.typeOfResearch);
            spData.typeOfResearchOther = txtOther.Text.Trim();
            SaveData();
            // is it OK not to reset the display here?  It will be reset when the page is reloaded anyway
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

        // called when a checkbox is clicked or Other is typed in
        protected void itmChanged(object sender, EventArgs e)
        {
            //ResetDisplay("");
        }


        protected void btnAddProject_OnClick(object sender, EventArgs e)
        {
            StudentProject sp = new StudentProject(txtProjectName.Text, txtProjectLocation.Text, txtProjectObjectives.Text, txtStudentResponsibilities.Text,
                txtLink.Text, txtStartDate.Text, txtEndDate.Text, txtContactInfo.Text);
            if (String.IsNullOrEmpty(sp.name))
            {
                lblMessage.Text = "Please provide a project name";
                return;
            }

            if (String.IsNullOrEmpty(hdnProjectKey.Value))
            {
                spData.currentProjects.Add(sp);

            }
            else
            {
                int index = spData.currentProjects.FindIndex(o => o.GetKey() == hdnProjectKey.Value);
                spData.currentProjects[index] = sp;
            }
            SaveData();
            ResetDisplay("");
        }

        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay("");
        }

        protected void GridViewPlugin_RowDataBound(object sender, GridViewRowEventArgs e)
        {
        }
        protected void GridViewPlugin_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
        }
        protected void GridViewPlugin_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            if (GridViewPlugin.Rows.Count > 1)
            {
                StudentProject sp = spData.currentProjects[e.RowIndex];
                spData.currentProjects.RemoveAt(e.RowIndex);
            }
            SaveData();
            ResetDisplay("");
        }
        protected void GridViewPlugin_RowEditing(object sender, GridViewEditEventArgs e)
        {
            //GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;

            //maybe grey out the up down buttons?
            if (GridViewPlugin.Rows.Count > 1)
            {
                StudentProject sp = spData.currentProjects[e.NewEditIndex];
                txtProjectName.Text = sp.name;
                txtProjectLocation.Text = sp.location;
                txtProjectObjectives.Text = sp.objectives;
                txtStudentResponsibilities.Text = sp.responsibilities;
                txtLink.Text = sp.url;
                txtStartDate.Text = sp.startDate;
                txtEndDate.Text = sp.endDate;
                txtContactInfo.Text = sp.contactinfo;
                hdnProjectKey.Value = sp.GetKey();
                btnAddProject.Text = "Save Edited Student Project";
            }
            //ResetDisplay(false, "Remember to click Save before leaving this section");
        }
        protected void GridViewPlugin_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
        }
        protected void GridViewPlugin_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;

            if (GridViewPlugin.Rows.Count > 1)
            {
                StudentProject sp = spData.currentProjects[row.RowIndex];
                spData.currentProjects.RemoveAt(row.RowIndex);
                spData.currentProjects.Insert(row.RowIndex-1, sp);
            }
            SaveData();
            ResetDisplay("");
        }
        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;

            if (GridViewPlugin.Rows.Count > 1)
            {
                StudentProject sp = spData.currentProjects[row.RowIndex];
                spData.currentProjects.RemoveAt(row.RowIndex);
                spData.currentProjects.Insert(row.RowIndex + 1, sp);
            }
            SaveData();
            ResetDisplay("");
        }

        private bool HasNoStudentProjectData()
        {
            // if these are blank then blank them all
            return spData == null || (spData.typeOfResearch.Count == 0 && spData.currentProjects.Count == 0);
        }

        private void ReadData()
        {
            string data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, GetPluginName());
            this.spData = JsonConvert.DeserializeObject<UCDStudentProjectsData>(data);
            if (this.spData == null)
            {
                this.spData = new UCDStudentProjectsData();
            }
        }

        private void SaveData()
        {
            GenericRDFDataIO.AddEditPluginData(GetPluginName(), this.SubjectID, this.SerializeJson(), spData.GetSearchData(GetBaseSearchData()));
        }
        private void ClearData()
        {
            GenericRDFDataIO.AddEditPluginData(GetPluginName(), this.SubjectID, "", "");
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.spData);
        }

    }

    public class StudentProject
    {
        public string name { get; set; }
        public string location { get; set; }
        public string objectives { get; set; }
        public string responsibilities { get; set; }
        public string url { get; set; }
        public string startDate { get; set; }
        public string endDate { get; set; }
        public string contactinfo { get; set; }
        public StudentProject(string name, string location, string objectives, string responsibilities, string url, string startDate, string endDate, string contactinfo)
        {
            this.name = name;
            this.location = location;
            this.objectives = objectives;
            this.responsibilities = responsibilities;
            this.url = url;
            this.startDate = startDate;
            this.endDate = endDate;
            this.contactinfo = contactinfo;
        }

        public string GetSearchData()
        {
            return name + ", " + location + ", " + url + ", " + startDate + ", " + endDate;
        }

        public string GetKey()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public class UCDStudentProjectsData
    {
        public List<string> typeOfResearch { get; set; }
        public string typeOfResearchOther { get; set; }
        public List<StudentProject> currentProjects { get; set; }
        public string lastUpdated { get; set; }

        public UCDStudentProjectsData()
        {
            typeOfResearch = new List<string>();
            currentProjects = new List<StudentProject>();
            lastUpdated = DateTime.Today.ToString("D");
        }

        public string GetSearchData(string baseData)
        {
            return string.Join(", ", new List<string> { baseData, "Student Projects", string.Join(", ", typeOfResearch), typeOfResearchOther, string.Join(", ", currentProjects.Select(sp => sp.GetSearchData())) });
            //return baseData + ", Student Projects, " + string.Join(", ", typeOfResearch) + string.Join(", ", typeOfResearchOther) + string.Join(", ", currentProjects.Select(sp => sp.GetSearchData()));
        }
    }
}