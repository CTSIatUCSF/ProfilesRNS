﻿using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Xml;
using Newtonsoft.Json;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Profiles.Profile.Modules;
using System.Web.UI.HtmlControls;
using System.Web.UI;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class UCSFFeaturedVideos : BaseUCSFModule
    {
        private string PlugInName = "UCSFFeaturedVideos";
        private string data = string.Empty;
        private List<Video> Videos { get; set; }


        public UCSFFeaturedVideos() : base() { }
        public UCSFFeaturedVideos(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
            base.InitUpDownArrows(ref GridViewVideos);
            upnlEditSection.Update();
            LoadAssets();
        }

        private void LoadAssets()
        {
            HtmlGenericControl jsscript1 = new HtmlGenericControl("script");
            jsscript1.Attributes.Add("type", "text/javascript");
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/jquery.validate.min.js");
            Page.Header.Controls.Add(jsscript1);

            HtmlGenericControl jsscript2 = new HtmlGenericControl("script");
            jsscript2.Attributes.Add("type", "text/javascript");
            jsscript2.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/UCSFFeaturedVideos.js");
            Page.Header.Controls.Add(jsscript2);

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
            if (Session["pnlImportVideo.Visible"] == null)
            {
                pnlImportVideo.Visible = true;
                imbAddArrow.ImageUrl = "~/Framework/Images/icon_squareDownArrow.gif";


                phSecuritySettings.Visible = false;
                Session["pnlImportVideo.Visible"] = true;
            }
            else
            {
                pnlImportVideo.Visible = false;
                imbAddArrow.ImageUrl = "~/Framework/Images/icon_squareArrow.gif";
                Session["pnlImportVideo.Visible"] = null;
                phSecuritySettings.Visible = true;
            }

        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            try
            {
                if (txtURL.Text.Trim() != string.Empty)
                {
                    string url = txtURL.Text.Trim();

                    string search = string.Empty;

                    //string youTubeId = hdnYouTubeId.Value.Trim();

                    if (this.Videos == null) { this.Videos = new List<Video>(); }

                    Video video = new Video { title = txtTitle.Text, url = url };
                    video.completeVideoMetadata();

                    // put at the top because it's newest
                    this.Videos.Insert(0, video);

                    foreach (Video v in this.Videos)
                    {
                        search += " " + v.title;
                    }

                    Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);
                }
                ResetDisplay();
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " " + ex.StackTrace);
                divVideoError.Visible = true;
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
            pnlAddEdit.Visible = true;
            Session["pnlImportVideo.Visible"] = null;
            txtTitle.Text = string.Empty;
            txtURL.Text = string.Empty;
            this.data = string.Empty;
            this.Videos = null;

            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);

            ReadJson();
            upnlEditSection.Update();
            divVideoError.Visible = false;
        }
        private void ReadJson()
        {
            List<Video> videos = JsonConvert.DeserializeObject<List<Video>>(this.data);
            if (videos == null)
            {
                divNoVideos.Visible = true;
                GridViewVideos.Visible = false;
            }
            else
            {
                // ensure that each one has the needed metadata
                foreach (Video v in videos)
                {
                    // the old school vidoes might be missing this
                    if (String.IsNullOrEmpty(v.html) ||  String.IsNullOrEmpty(v.thumbnail_url))
                    {
                        v.completeVideoMetadata();
                    }
                }
                divNoVideos.Visible = false;
                GridViewVideos.Visible = true;
                GridViewVideos.DataSource = videos;
                GridViewVideos.DataBind();
                base.InitUpDownArrows(ref GridViewVideos);
                this.Videos = videos;
            }
        }

        private string SerializeJson()
        {
            string rtn = "";
            //the first video was just added so the videos list is empty
            if (this.Videos.Count == 0 && txtURL.Text.Trim() != string.Empty)
            {
                this.data = "[{\"url\":\"" + "\"}]";
                this.ReadJson();
            }

            rtn = Regex.Replace(JsonConvert.SerializeObject(this.Videos, Newtonsoft.Json.Formatting.Indented), @"\t|\n|\r", "");

            return rtn.Replace("[]", "");  // make it empty if its empty json
        }

        #region "Grid"
        protected void GridViewVideos_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            //e.Row.Cells[1].Attributes.Add("style", "width:200px;text-align:center;padding-top:7px;");
        }

        protected void GridViewVideos_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewVideos.EditIndex = e.NewEditIndex;
            ReadJson();
            upnlEditSection.Update();
        }
        protected void GridViewVideos_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
            ResetDisplay();
            base.InitUpDownArrows(ref GridViewVideos);
            upnlEditSection.Update();
        }
        protected void GridViewVideos_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            TextBox txtURL = (TextBox)GridViewVideos.Rows[e.RowIndex].FindControl("txtURL");
            TextBox txtVideoDescription = (TextBox)GridViewVideos.Rows[e.RowIndex].FindControl("txtVideoDescription");

            string data = GridViewVideos.DataKeys[e.RowIndex].Values[1].ToString();
            var found = this.Videos.Find(f => f.url == data);

            // if they changed the URL or blanked out the title, grab new metadata
            if (!found.url.Equals(txtURL.Text.Trim()) || String.IsNullOrEmpty(txtVideoDescription.Text.Trim()))
            {
                // new video
                found.html = null;
                found.title = null;
                found.url = txtURL.Text.Trim();
                try
                {
                    found.completeVideoMetadata();
                }
                catch (Exception ex)
                {
                    Framework.Utilities.DebugLogging.Log(ex.Message + " " + ex.StackTrace);
                    divVideoError.Visible = true;
                    return;
                }
            }

            // if the user entered a title, use it
            if (!String.IsNullOrEmpty(txtVideoDescription.Text.Trim()))
            {
                found.title = txtVideoDescription.Text.Trim();
            }

            string search = string.Empty;
            foreach (Video v in this.Videos)
            {
                search += " " + v.title;
            }
            //this needs to be the json desz'd
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);
            ResetDisplay();

            GridViewVideos.EditIndex = -1;
            ResetDisplay();
            upnlEditSection.Update();
        }
        protected void GridViewVideos_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewVideos.EditIndex = -1;

            ResetDisplay();
            upnlEditSection.Update();
        }
        protected void GridViewVideos_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            string name = GridViewVideos.DataKeys[e.RowIndex].Values[0].ToString();
            string url = GridViewVideos.DataKeys[e.RowIndex].Values[1].ToString();

            var found = this.Videos.Find(x => x.url == url);
            if (found != null) this.Videos.Remove(found);

            string search = string.Empty;
            foreach (Video v in this.Videos)
            {
                search += " " + v.title;
            }
            //this needs to be the json desz'd
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);
            if (GridViewVideos.Rows.Count == 1) //they just deleted their last row
                Profiles.Framework.Utilities.GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);

            ResetDisplay();
            base.InitUpDownArrows(ref GridViewVideos);
            upnlEditSection.Update();
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;

            GridViewVideos.EditIndex = -1;
            int newIndex = row.RowIndex - 1;
            int oldIndex = row.RowIndex;

            var item = this.Videos[oldIndex];

            this.Videos.RemoveAt(oldIndex);
            this.Videos.Insert(newIndex, item);
            string search = string.Empty;
            foreach (Video v in this.Videos)
            {
                search += " " + v.title;
            }
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);

            SerializeJson();
            ResetDisplay();

        }
        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;
            GridViewVideos.EditIndex = -1;

            int newIndex = row.RowIndex + 1;
            int oldIndex = row.RowIndex;

            var item = this.Videos[oldIndex];

            this.Videos.RemoveAt(oldIndex);
            this.Videos.Insert(newIndex, item);

            string search = string.Empty;
            foreach (Video v in this.Videos)
            {
                search += " " + v.title;
            }
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), search);

            ResetDisplay();
        }
        #endregion
    }

}