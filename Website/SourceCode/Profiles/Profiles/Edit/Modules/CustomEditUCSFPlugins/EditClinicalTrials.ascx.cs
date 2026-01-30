using Newtonsoft.Json;
using Profiles.Framework.Utilities;
using Profiles.Profile.Modules;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web.UI.WebControls;
using System.Xml;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class ClinicalTrials : BaseUCSFModule
    {
        private string PlugInName = "ClinicalTrials";
        // actually store added and deleted
        private List<ClinicalTrial> entries { get; set; }
        private List<string> manualAdds;
        private List<string> manualRemoves;


        public ClinicalTrials() : base() { }
        public ClinicalTrials(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            ReadData();
            //InitUpDownArrows(ref GridViewPlugin);
            upnlEditSection.Update();
            LoadAssets();
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
            SaveManualAdd();
            pnlInsert.Visible = true;
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            SaveManualAdd();
        }

        private void SaveManualAdd()
        {
            if (txtNct.Text != "")
            {
                // if it was in the manual remove list, just take it away from that list
                if (!manualRemoves.Remove(txtNct.Text) && !manualAdds.Contains(txtNct.Text))
                {
                    manualAdds.Add(txtNct.Text);
                }
                // call API
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

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;
            Session["pnlImport" + this.PlugInName + ".Visible"] = null;
            pnlAddEdit.Visible = true;
            txtNct.Text = string.Empty;

            this.entries = null;

            ReadData();
            upnlEditSection.Update();
        }
        private void ReadData()
        {
            String[] manualEdits = (new Profiles.Edit.Utilities.DataIO()).GetManualClinicalTrialsEdits(this.SubjectID);
            this.manualAdds = String.IsNullOrEmpty(manualEdits[0]) ? new List<string>() : manualEdits[0].Split(',').ToList<string>();
            this.manualRemoves = String.IsNullOrEmpty(manualEdits[1]) ? new List<string>() : manualEdits[1].Split(',').ToList<string>();

            // EM STOP
            string data = GetClinicalTrialsFromAPI();
            //string data = GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            entries = JsonConvert.DeserializeObject<List<ClinicalTrial>>(data);
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
                //InitUpDownArrows(ref GridViewPlugin);
            }
        }

        /*********
        private string SerializeJson()
        {
            string rtn = Regex.Replace(JsonConvert.SerializeObject(this.entries, Newtonsoft.Json.Formatting.Indented), @"\t|\n|\r", "");

            return rtn.Replace("[]", "");  // make it empty if its empty json
        }
        ****************/

        #region "Grid"
        protected void GridViewPlugin_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //e.Row.Cells[1].Attributes.Add("style", "width:200px;text-align:center;padding-top:7px;");
        }

        protected void GridViewPlugin_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            ClinicalTrial found = this.entries[e.RowIndex];
            if (found != null)
            {
                // if it was a manual add just remove it from the manual add list
                if (!manualAdds.Remove(found.id) && !manualRemoves.Contains(found.id))
                {
                    manualRemoves.Add(found.id);
                }
                // TODO at this point hit the API, then save data afterwards
                this.entries.Remove(found);
            }

            if (GridViewPlugin.Rows.Count == 1) //they just deleted their last row
            {
                GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            }
            else
            {
                SaveData();
            }

            ResetDisplay();
            upnlEditSection.Update();
        }

        private void SaveData()
        {
            // first call the API to make sure the manually entered data works. If it throws an error it will skip the call to put the bad data 
            // in the DB
            String jsonFromApi = GetClinicalTrialsFromAPI();

            // add to custom DB table
            (new Profiles.Edit.Utilities.DataIO()).UpsertManualClinicalTrialsEdits(this.SubjectID, manualAdds, manualRemoves);

            // now add the plugin JSON
            string search = "Clinical Trials";
            
            foreach (ClinicalTrial v in this.entries)
            {
                search += ", " + v.GetSearchTerm();
            }
            GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, jsonFromApi, search);
        }

        #endregion

        // add json ClinicalTrial from EDIT to here
        private String GetClinicalTrialsFromAPI()
        {
            // from API and also get manual ones from DB and stitch together. Return a sorted list?
            String URL = "https://stage-api.researcherprofiles.org/ClinicalTrialsApi/api/clinicaltrial/?add=" + string.Join(",", manualAdds) +
                "&remove=" + string.Join(",", manualRemoves) + "&person_url=" + ConvertToProductionUrl(UCSFIDSet.ByNodeId[this.SubjectID].PrettyURL);
            HttpWebRequest myReq = (HttpWebRequest)WebRequest.Create(URL);
            myReq.Accept = "application/json"; // "application/ld+json";
            String jsonProfiles = "";
            using (StreamReader sr = new StreamReader(myReq.GetResponse().GetResponseStream()))
            {
                jsonProfiles = sr.ReadToEnd();
            }
            return jsonProfiles;
        }

        // maybe add this to UCSFIDSet?
        static String ConvertToProductionUrl(String url)
        {
            return url.Replace("dev-ucsf.researcherprofiles.org", "profiles.ucsf.edu").Replace("stage-ucsf.researcherprofiles.org", "profiles.ucsf.edu");
        }
        public class ClinicalTrial 
        {
            public string id { get; set; }
            public string title { get; set; }
            public string startDate { get; set; }
            public string completionDateLabel { get; set; }
            public string completionDateValue { get; set; }
            public string conditions { get; set; }
            public string status { get; set; }
            public string sourceUrl { get; set; }

            public ClinicalTrial(string id, string title, string startDate, string completionDate, string estimatedCompletionDate, 
                string conditions, string status, string sourceUrl)
            {
                this.id = id;
                this.title = title;
                this.startDate = String.IsNullOrEmpty(startDate) ? "" : startDate.Trim();
                if (!String.IsNullOrEmpty(completionDate) && completionDate.Trim().Length >= 10 )
                {
                    this.completionDateLabel = "Completion Date";
                    this.completionDateValue = completionDate.Substring(0, 10);
                }
                else if (!String.IsNullOrEmpty(estimatedCompletionDate) && estimatedCompletionDate.Trim().Length >= 10)
                {
                    this.completionDateLabel = "Estimated Completion Date";
                    this.completionDateValue = estimatedCompletionDate.Substring(0, 10);
                }
                this.conditions = conditions;
                this.status = status;
                this.sourceUrl = sourceUrl;
            }

            public string GetSearchTerm()
            {
                return id + ", " + title;
            }
        }

    }

}