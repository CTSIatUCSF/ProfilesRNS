/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Xml;

using Profiles.Framework.Utilities;
using Profiles.Edit.Utilities;
using Newtonsoft.Json.Linq;
using Profiles.Profile.Modules;


namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class CommunityService : BaseUCSFModule
    {
        private string PlugInName = "CommunityAndPublicService";

        Edit.Utilities.DataIO data;
        protected void Page_Load(object sender, EventArgs e)
        {
            this.FillCommunityServiceGrid(false);
            
            if (!IsPostBack)
                Session["pnlInsertCommunityService.Visible"] = null;

            // this will turn it off for UCSF if it is disabled;
            pnlCopyAdvanceCommunityService.Visible &= Advance.IsAdvanceEnabled();

        }

        public CommunityService() : base() { }
        public CommunityService(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            SessionManagement sm = new SessionManagement();
            this.XMLData = pagedata;

            data = new Edit.Utilities.DataIO();
            Profiles.Profile.Utilities.DataIO propdata = new Profiles.Profile.Utilities.DataIO();

            if (Request.QueryString["subject"] != null)
                this.SubjectID = Convert.ToInt64(Request.QueryString["subject"]);
            else if (base.GetRawQueryStringItem("subject") != null)
                this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));
            else
                Response.Redirect("~/search");

            string predicateuri = Request.QueryString["predicateuri"].Replace("!", "#");
            this.PropertyListXML = propdata.GetPropertyList(this.BaseData, base.PresentationXML, predicateuri, false, true, false);

            this.PredicateID = data.GetStoreNode(predicateuri);

            base.GetNetworkProfile(this.SubjectID, this.PredicateID);

            litBackLink.Text = "<a href='" + Brand.GetThemedDomain() + "/edit/" + this.SubjectID.ToString() + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";


            securityOptions.Subject = this.SubjectID;
            securityOptions.PredicateURI = predicateuri;
            securityOptions.PrivacyCode = Convert.ToInt32(this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDataDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);

            if (Request.QueryString["new"] != null && Session["new"] != null)
            {
                Session["pnlInsertCommunityService.Visible"] = null;
                Session["new"] = null;

                if (Session["newclose"] != null)
                {
                    Session["newclose"] = null;
                    btnInsertCancel_OnClick(this,new EventArgs());

                }
                else
                {
                    btnEditCommunityService_OnClick(this, new EventArgs());
                }

            }

            securityOptions.BubbleClick += SecurityDisplayed;

        }

        #region CommunityService

        private void SecurityDisplayed(object sender, EventArgs e)
        {

            
            if (Session["pnlSecurityOptions.Visible"] == null)
            {
                pnlEditCommunityService.Visible = true;
                
            }
            else
            {
                pnlEditCommunityService.Visible = false;
                
            }
        }

        protected void btnEditCommunityService_OnClick(object sender, EventArgs e)
        {
            if (Session["pnlInsertCommunityService.Visible"] == null)
            {
                btnInsertCancel_OnClick(sender, e);
                pnlSecurityOptions.Visible = false;
                pnlInsertCommunityService.Visible = true;
                Session["pnlInsertCommunityService.Visible"] = true;
            }
            else
            {
                Session["pnlInsertCommunityService.Visible"] = null;
                pnlSecurityOptions.Visible = true;
                pnlInsertCommunityService.Visible = false;
            }
            upnlEditSection.Update();
        }

        protected void btnSortCommunityService_OnClick(object sender, EventArgs e)
        {
            List<Service> services = new List<Service>();
            int existing = GridViewCommunityService.Rows.Count;
            for (int i = 0; i < existing; i++)
            {
                // add existing service to list
                services.Add(new Service(((Label)GridViewCommunityService.Rows[i].FindControl("lblCommunityServiceRole")).Text,
                                     ((Label)GridViewCommunityService.Rows[i].FindControl("lblCommunityServiceInst")).Text,
                                     ((Label)GridViewCommunityService.Rows[i].FindControl("lblYr1")).Text,
                                     ((Label)GridViewCommunityService.Rows[i].FindControl("lblYr2")).Text));
                // delete from DB
                Int64 _object = Convert.ToInt64(GridViewCommunityService.DataKeys[i].Values[2].ToString());
                data.DeleteTriple(this.SubjectID, this.PredicateID, _object);
            }
            //sort
            services.Sort((a, b) => b.CompareTo(a));
            // add in sorted order
            foreach (Service service in services)
            {
                data.AddAward(this.SubjectID, service.role, service.honoringOrganization, service.startingYear, service.endingYear, this.PropertyListXML);
            }
            this.FillCommunityServiceGrid(true);
            upnlEditSection.Update();
        }

        protected void btnCopyAdvanceCommunityService_OnClick(object sender, EventArgs e)
        {
            try
            {
                JToken itemsToken = Advance.getHonorsAndAwards(this.SubjectID);
                List<Service> services = new List<Service>();
                int existing = GridViewCommunityService.Rows.Count;
                if (itemsToken != null)
                {
                    foreach (JToken item in itemsToken)
                    {
                        services.Add(new Service((string)item["role"], (string)item["honoringOrganization"], (string)item["year"], (string)item["year"]));
                    }
                    services.Sort((a, b) => b.CompareTo(a));
                    foreach (Service service in services)
                    { 
                        data.AddAward(this.SubjectID, service.role, service.honoringOrganization, service.startingYear, service.endingYear, this.PropertyListXML);
                    }
                }
                if (services.Count > 0)
                {
                    // delete existing ones but only if some were added
                    for (int i = 0; i < existing; i++)
                    {
                        Int64 _object = Convert.ToInt64(GridViewCommunityService.DataKeys[i].Values[2].ToString());
                        data.DeleteTriple(this.SubjectID, this.PredicateID, _object);
                    }
                    litAdvanceMessage.Text = "Added " + services.Count + " item" + (services.Count > 1 ? "s" : "") + " from Advance.";
                    GridViewCommunityService.Visible = true;
                }
                else
                {
                    litAdvanceMessage.Text = "No Community or Public Service items found for your profile.";
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + ex.StackTrace);
                litAdvanceMessage.Text = "Error accessing Advance for your profile.";
            }
            this.FillCommunityServiceGrid(true);
            upnlEditSection.Update();
        }


        protected void GridViewCommunityService_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            TextBox txtYr1 = null;
            TextBox txtYr2 = null;
            TextBox txtCommunityServiceRole = null;
            TextBox txtCommunityServiceInst = null;
            ImageButton lnkEdit = null;
            ImageButton lnkDelete = null;
            HiddenField hdURI = null;

            AwardState serviceState = null;

            try
            {
                e.Row.Cells[4].Attributes.Add("style", "border-left:0px;");
            }
            catch (Exception ex) { }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {

                txtYr1 = (TextBox)e.Row.Cells[0].FindControl("txtYr1");
                txtYr2 = (TextBox)e.Row.Cells[1].FindControl("txtYr2");
                txtCommunityServiceRole = (TextBox)e.Row.Cells[2].FindControl("txtCommunityServiceRole");
                txtCommunityServiceInst = (TextBox)e.Row.Cells[3].FindControl("txtCommunityServiceInst");
                hdURI = (HiddenField)e.Row.Cells[3].FindControl("hdURI");

                lnkEdit = (ImageButton)e.Row.Cells[4].FindControl("lnkEdit");
                lnkDelete = (ImageButton)e.Row.Cells[4].FindControl("lnkDelete");

                serviceState = (AwardState)e.Row.DataItem;
                hdURI.Value = serviceState.SubjectURI;

                if (serviceState.EditDelete == false)
                    lnkDelete.Visible = false;

                if (serviceState.EditExisting == false)
                    lnkEdit.Visible = false;

            }

            if (e.Row.RowType == DataControlRowType.DataRow && (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
            {
                txtYr1.Text = Server.HtmlDecode((string)txtYr1.Text);
                txtYr2.Text = Server.HtmlDecode((string)txtYr2.Text);
                txtCommunityServiceRole.Text = Server.HtmlDecode((string)txtCommunityServiceRole.Text);
                txtCommunityServiceInst.Text = Server.HtmlDecode((string)txtCommunityServiceInst.Text);
            }

        }

        protected void GridViewCommunityService_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewCommunityService.EditIndex = e.NewEditIndex;
            this.FillCommunityServiceGrid(false);

            upnlEditSection.Update();
        }

        protected void GridViewCommunityService_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

            TextBox txtYr1 = (TextBox)GridViewCommunityService.Rows[e.RowIndex].FindControl("txtYr1");
            TextBox txtYr2 = (TextBox)GridViewCommunityService.Rows[e.RowIndex].FindControl("txtYr2");
            TextBox txtCommunityServiceRole = (TextBox)GridViewCommunityService.Rows[e.RowIndex].FindControl("txtCommunityServiceRole");
            TextBox txtCommunityServiceInst = (TextBox)GridViewCommunityService.Rows[e.RowIndex].FindControl("txtCommunityServiceInst");
            HiddenField hdURI = (HiddenField)GridViewCommunityService.Rows[e.RowIndex].FindControl("hdURI");


            data.UpdateAward(hdURI.Value, txtCommunityServiceInst.Text, txtCommunityServiceInst.Text, txtYr1.Text, txtYr2.Text, this.PropertyListXML);
            GridViewCommunityService.EditIndex = -1;
            Session["pnlInsertCommunityService.Visible"] = null;
            this.FillCommunityServiceGrid(true);
            upnlEditSection.Update();
        }

        protected void GridViewCommunityService_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
            this.FillCommunityServiceGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewCommunityService_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewCommunityService.EditIndex = -1;

            this.FillCommunityServiceGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewCommunityService_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {

            Int64 predicate = Convert.ToInt64(GridViewCommunityService.DataKeys[e.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewCommunityService.DataKeys[e.RowIndex].Values[2].ToString());

            data.DeleteTriple(this.SubjectID, predicate, _object);
            this.FillCommunityServiceGrid(true);

            upnlEditSection.Update();
        }

        protected void btnInsertCancel_OnClick(object sender, EventArgs e)
        {
            Session["pnlInsertCommunityService.Visible"] = null;
            txtStartYear.Text = "";
            txtEndYear.Text = "";
            txtInstitution.Text = "";
            txtRole.Text = "";
            pnlInsertCommunityService.Visible = false;
            upnlEditSection.Update();
        }

        protected void btnInsert_OnClick(object sender, EventArgs e)
        {
            if (txtStartYear.Text != "" || txtEndYear.Text != "" || txtInstitution.Text != "" || txtRole.Text != "")
            {
                data.AddAward(this.SubjectID, txtRole.Text, txtInstitution.Text, txtStartYear.Text, txtEndYear.Text, this.PropertyListXML);


                txtStartYear.Text = "";
                txtEndYear.Text = "";
                txtInstitution.Text = "";
                txtRole.Text = "";
                Session["pnlInsertCommunityService.Visible"] = null;
                btnEditCommunityService_OnClick(sender, e);
                this.FillCommunityServiceGrid(true);
                if (GridViewCommunityService.Rows.Count == 1)
                {
                    Session["new"] = true;
                    //stupid update panel bug we cant figure out.
                    Response.Redirect(Request.Url.ToString() + "&new=true");
                }
                else
                {
                    this.FillCommunityServiceGrid(true);
                    upnlEditSection.Update();
                }

            }

        }

        protected void btnInsertClose_OnClick(object sender, EventArgs e)
        {
            if (txtStartYear.Text != "" || txtEndYear.Text != "" || txtInstitution.Text != "" || txtRole.Text != "")
            {
                Session["pnlInsertCommunityService.Visible"] = null;
                data.AddAward(this.SubjectID, txtRole.Text, txtInstitution.Text, txtStartYear.Text, txtEndYear.Text, this.PropertyListXML);

                this.FillCommunityServiceGrid(true);


                if (GridViewCommunityService.Rows.Count == 1)
                {
                    Session["new"] = true;
                    Session["newclose"] = true;
                    //stupid update panel bug we cant figure out.
                    Response.Redirect(Request.Url.ToString() + "&new=true");
                }
                else
                {
                    btnInsertCancel_OnClick(sender, e);
                    upnlEditSection.Update();
                }


              
            }

        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;

            GridViewCommunityService.EditIndex = -1;
            Int64 predicate = Convert.ToInt64(GridViewCommunityService.DataKeys[row.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewCommunityService.DataKeys[row.RowIndex].Values[2].ToString());

            data.MoveTripleDown(this.SubjectID, predicate, _object);

            this.FillCommunityServiceGrid(true);

            upnlEditSection.Update();

        }

        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;
            GridViewCommunityService.EditIndex = -1;

            Int64 predicate = Convert.ToInt64(GridViewCommunityService.DataKeys[row.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewCommunityService.DataKeys[row.RowIndex].Values[2].ToString());

            data.MoveTripleUp(this.SubjectID, predicate, _object);

            this.FillCommunityServiceGrid(true);

            upnlEditSection.Update();

        }
        protected void FillCommunityServiceGrid(bool refresh)
        {
            if (refresh)
                base.GetNetworkProfile(this.SubjectID, this.PredicateID);

            List<AwardState> awardstate = new List<AwardState>();

            Int64 predicate = 0;

            string awarduri = string.Empty;

            Int64 oldobjectid = 0;

            string oldstartdatevalue = string.Empty;
            string oldenddatevalue = string.Empty;
            string oldawardorhonorvalue = string.Empty;
            string oldinstitutionvalue = string.Empty;

            string predicateuri = string.Empty;
            string method = string.Empty;

            bool editexisting = false;
            bool editaddnew = false;
            bool editdelete = false;


            if (this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@EditExisting").Value.ToLower() == "true" ||
             this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@CustomEdit").Value.ToLower() == "true")
                editexisting = true;

            if (this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@EditAddNew").Value.ToLower() == "true" ||
                this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@CustomEdit").Value.ToLower() == "true")
                editaddnew = true;

            if (this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@EditDelete").Value.ToLower() == "true" ||
                this.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@CustomEdit").Value.ToLower() == "true")
                editdelete = true;

            if (!editaddnew)
                btnEditCommunityService.Visible = false;

            this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));
            predicate = Convert.ToInt64(data.GetStoreNode(Server.UrlDecode(base.GetRawQueryStringItem("predicateuri")).Replace("!", "#")));
            predicateuri = base.GetRawQueryStringItem("predicateuri").Replace("!", "#");

            foreach (XmlNode property in (base.BaseData).SelectNodes("rdf:RDF/rdf:Description/prns:hasConnection/@rdf:resource", base.Namespaces))
            {

                awarduri = base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + property.InnerText + "']/rdf:object/@rdf:resource", base.Namespaces).Value;
                oldobjectid = data.GetStoreNode(awarduri);

                if (base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/prns:startDate", base.Namespaces) != null)
                    oldstartdatevalue = base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/prns:startDate", base.Namespaces).InnerText;
                else
                    oldstartdatevalue = string.Empty;

                if (base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/prns:endDate", base.Namespaces) != null)
                    oldenddatevalue = base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/prns:endDate", base.Namespaces).InnerText;
                else
                    oldenddatevalue = string.Empty;

                if (base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/rdfs:label", base.Namespaces) != null)
                    oldawardorhonorvalue = base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/rdfs:label", base.Namespaces).InnerText;
                else
                    oldawardorhonorvalue = string.Empty;

                if (base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/prns:awardConferredBy", base.Namespaces) != null)
                    oldinstitutionvalue = base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about='" + awarduri + "']/prns:awardConferredBy", base.Namespaces).InnerText;
                else
                    oldinstitutionvalue = string.Empty;

                awardstate.Add(new AwardState(awarduri, predicate, oldobjectid, oldstartdatevalue, oldenddatevalue,
                    oldinstitutionvalue, oldawardorhonorvalue, editexisting, editdelete));

            }


            if (awardstate.Count > 0)
            {


                GridViewCommunityService.DataSource = awardstate;
                GridViewCommunityService.DataBind();
            }
            else
            {

                lblNoCommunityService.Visible = true;
                GridViewCommunityService.Visible = false;

            }

        }
        #endregion

        public class Service : IComparable<Service>
        {
            public string role;
            public string honoringOrganization;
            public string startingYear;
            public string endingYear;

            public Service(String role, string honoringOrganization, string startingYear, string endingYear)            
            {
                this.role = role;
                this.honoringOrganization = honoringOrganization;
                this.startingYear = String.IsNullOrEmpty(startingYear) ? "" : startingYear.Trim();
                this.endingYear = String.IsNullOrEmpty(endingYear) ? "" : endingYear.Trim();
            }

            public int CompareTo(Service other)
            {
                return this.startingYear.Equals(other.startingYear) ? this.endingYear.CompareTo(other.endingYear) : this.startingYear.CompareTo(other.startingYear);
            }
        }

            private Int64 SubjectID { get; set; }
        private Int64 PredicateID { get; set; }
        private XmlDocument XMLData { get; set; }
        private XmlDocument PropertyListXML { get; set; }




    }
}