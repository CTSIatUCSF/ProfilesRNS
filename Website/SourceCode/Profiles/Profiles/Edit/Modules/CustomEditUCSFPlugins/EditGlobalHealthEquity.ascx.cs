using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Xml;
using Newtonsoft.Json;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Profiles.Profile.Modules;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class GlobalHealthEquity : BaseUCSFModule
    {
        private string PlugInName = "GlobalHealthEquity";
        private string data = string.Empty;
        private GlobalHealthEquityData ghData = new GlobalHealthEquityData();

        public GlobalHealthEquity() : base() { }
        public GlobalHealthEquity(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            foreach (string s in this.GetRemainingIntersests())
            {
                ddlInterests.Items.Add(s);
            }
            base.InitUpDownArrows(ref GridViewGlobalHealthInterests);
            upnlEditSection.Update();
            if (!Page.IsPostBack)
            {
            }
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
            if (Session["pnlGlobalHealthInterests.Visible"] == null)
            {
                pnlGlobalHealthInterests.Visible = true;
                imbAddArrow.ImageUrl = "~/Framework/Images/icon_squareDownArrow.gif";


                phSecuritySettings.Visible = false;
                Session["pnlGlobalHealthInterests.Visible"] = true;
            }
            else
            {
                pnlGlobalHealthInterests.Visible = false;
                imbAddArrow.ImageUrl = "~/Framework/Images/icon_squareArrow.gif";
                Session["pnlGlobalHealthInterests.Visible"] = null;
                phSecuritySettings.Visible = true;
            }

        }      

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            if (ddlInterests.SelectedValue != string.Empty)
            {
                string search = string.Empty;

                string id = hdnURL.Value.Trim();

                if (ghData.interests == null) { ghData.interests = new List<string>(); }


                ghData.interests.Add(ddlInterests.SelectedValue);

                foreach (string v in ghData.interests)
                {
                    search += " " + v;
                }


                Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);
            }
            ResetDisplay();
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
            pnlAddEdit.Visible = true;
            Session["pnlGlobalHealthInterests.Visible"] = null;
            ddlInterests.SelectedIndex = 0;
            this.data = string.Empty;
            this.ghData = null;


            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            
            ReadJson();            
            upnlEditSection.Update();

        }
        private void ReadJson()
        {
            this.ghData = JsonConvert.DeserializeObject<GlobalHealthEquityData>(this.data);
            if (ghData.interests == null)
            {
                divNoInterests.Visible = true;
                GridViewGlobalHealthInterests.Visible = false;
            }
            else
            {
                divNoInterests.Visible = false;
                GridViewGlobalHealthInterests.Visible = true;
                GridViewGlobalHealthInterests.DataSource = ghData.interests;
                GridViewGlobalHealthInterests.DataBind();
                base.InitUpDownArrows(ref GridViewGlobalHealthInterests);
            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.ghData);
        }

        private string GetSearchData()
        {
            string search = string.Empty;
            foreach (string v in this.ghData.interests)
            {
                search += " " + v;
            }
            foreach (string v in this.ghData.locations)
            {
                search += " " + v;
            }
            return search;
        }

        private List<string> GetRemainingIntersests()
        {
            List<string> retval = new List<string>();
            retval.AddRange(GetAllInterests());
            foreach (string interest in this.ghData.interests)
            {
                retval.Remove(interest);
            }
            return retval;
        }

        private List<string> GetAllInterests()
        {
            List<string> retval = new List<string>();
            retval.Add("Child and adolescent");
            retval.Add("COVID");
            retval.Add("Emergency and Critical Care");
            retval.Add("Diarrheal disease");
            retval.Add("Disaster relief");
            retval.Add("Epidemiology");
            retval.Add("Family Planning");
            retval.Add("Global health economics");
            retval.Add("Global health education");
            retval.Add("Global ophthalmology");
            retval.Add("Global oral health");
            retval.Add("Global surgery & anesthesia");
            retval.Add("Guideline development");
            retval.Add("HIV / AIDS");
            retval.Add("Immunization");
            retval.Add("Implementation science");
            retval.Add("Infectious disease");
            retval.Add("Injury");
            retval.Add("Malaria");
            retval.Add("Memory and aging");
            retval.Add("Mental health");
            retval.Add("mHealth");
            retval.Add("Neglected Tropical Diseases");
            retval.Add("Newborn and infant");
            retval.Add("Nutrition and food security");
            retval.Add("Oncology");
            retval.Add("Pandemics");
            retval.Add("Refugee health");
            retval.Add("Smoking and Tobacco");
            retval.Add("Substance abuse");
            retval.Add("Tuberculosis");
            retval.Add("Viral hemorrhagic fever");
            return retval;
        }

        #region "Grid"
        protected void GridViewGlobalHealthInterests_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            TextBox txtGlobalHealthInterests = null;
            ImageButton lnkDelete = null;

            string interest = (string)e.Row.DataItem;

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                lnkDelete = (ImageButton)e.Row.Cells[1].FindControl("lnkDelete");
            }

            if (e.Row.RowType == DataControlRowType.DataRow && (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
            {
                txtGlobalHealthInterests = (TextBox)e.Row.Cells[0].FindControl("txtGlobalHealthInterests");
                txtGlobalHealthInterests.Text = interest;
            }
        }

        /**
        protected void GridViewGlobalHealthInterests_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewGlobalHealthInterests.EditIndex = e.NewEditIndex;
            ReadJson();
            upnlEditSection.Update();
        }
        protected void GridViewGlobalHealthInterests_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
            ResetDisplay();
            base.InitUpDownArrows(ref GridViewGlobalHealthInterests);
            upnlEditSection.Update();
        }

        protected void GridViewGlobalHealthInterests_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            TextBox txtGlobalHealthInterests = (TextBox)GridViewGlobalHealthInterests.Rows[e.RowIndex].FindControl("txtGlobalHealthInterests");

            //this needs to be the json desz'd
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
            ResetDisplay();

            GridViewGlobalHealthInterests.EditIndex = -1;
            ResetDisplay();
            upnlEditSection.Update();
        }
        protected void GridViewGlobalHealthInterests_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewGlobalHealthInterests.EditIndex = -1;

            ResetDisplay();
            upnlEditSection.Update();
        }
    **/
        protected void GridViewGlobalHealthInterests_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            this.ghData.interests.RemoveAt(e.RowIndex);

            //this needs to be the json desz'd
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
            if (GridViewGlobalHealthInterests.Rows.Count == 1) //they just deleted their last row
                Profiles.Framework.Utilities.GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);

            ResetDisplay();
            base.InitUpDownArrows(ref GridViewGlobalHealthInterests);
            upnlEditSection.Update();
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;

            GridViewGlobalHealthInterests.EditIndex = -1;
            int newIndex = row.RowIndex - 1;
            int oldIndex = row.RowIndex;

            var item = this.ghData.interests[oldIndex];

            this.ghData.interests.RemoveAt(oldIndex);
            this.ghData.interests.Insert(newIndex, item);

            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            SerializeJson();
            ResetDisplay();

        }
        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;
            GridViewGlobalHealthInterests.EditIndex = -1;

            int newIndex = row.RowIndex+1;
            int oldIndex = row.RowIndex;

            var item = this.ghData.interests[oldIndex];

            this.ghData.interests.RemoveAt(oldIndex);            
            this.ghData.interests.Insert(newIndex, item);

            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            ResetDisplay();
        }
        #endregion
    }

    public class GlobalHealthEquityData
    {
        public List<string> interests { get; set; }
        public List<string> locations { get; set; }
    }
}