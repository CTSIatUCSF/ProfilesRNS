﻿/*  
 
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
using Connects.Profiles.Service.DataContracts;
using static Profiles.Edit.Modules.CustomEditAwardOrHonor.CustomEditAwardOrHonor;


namespace Profiles.Edit.Modules.CustomEditAwardOrHonor
{
    public partial class CustomEditAwardOrHonor : BaseModule
    {

        Edit.Utilities.DataIO data;
        protected void Page_Load(object sender, EventArgs e)
        {
            this.FillAwardGrid(false);
            
            if (!IsPostBack)
                Session["pnlInsertAward.Visible"] = null;

            // this will turn it off for UCSF if it is disabled;
            pnlCopyAdvanceAwards.Visible &= Advance.IsAdvanceEnabled();

        }

        public CustomEditAwardOrHonor() : base() { }
        public CustomEditAwardOrHonor(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
                Session["pnlInsertAward.Visible"] = null;
                Session["new"] = null;

                if (Session["newclose"] != null)
                {
                    Session["newclose"] = null;
                    btnInsertCancel_OnClick(this,new EventArgs());

                }
                else
                {
                    btnEditAwards_OnClick(this, new EventArgs());
                }

            }

            securityOptions.BubbleClick += SecurityDisplayed;

        }

        #region Awards

        private void SecurityDisplayed(object sender, EventArgs e)
        {

            
            if (Session["pnlSecurityOptions.Visible"] == null)
            {
                pnlEditAwards.Visible = true;
                
            }
            else
            {
                pnlEditAwards.Visible = false;
                
            }
        }

        protected void btnEditAwards_OnClick(object sender, EventArgs e)
        {
            if (Session["pnlInsertAward.Visible"] == null)
            {
                btnInsertCancel_OnClick(sender, e);
                pnlSecurityOptions.Visible = false;
                pnlInsertAward.Visible = true;
                Session["pnlInsertAward.Visible"] = true;
            }
            else
            {
                Session["pnlInsertAward.Visible"] = null;
                pnlSecurityOptions.Visible = true;
                pnlInsertAward.Visible = false;
            }
            upnlEditSection.Update();
        }

        protected void btnSortAwards_OnClick(object sender, EventArgs e)
        {
            List<Award> awards = new List<Award>();
            int existing = GridViewAwards.Rows.Count;
            for (int i = 0; i < existing; i++)
            {
                // add existing award to list
                awards.Add(new Award(((Label)GridViewAwards.Rows[i].FindControl("lblAwardName")).Text,
                                     ((Label)GridViewAwards.Rows[i].FindControl("lblAwardInst")).Text,
                                     ((Label)GridViewAwards.Rows[i].FindControl("lblYr1")).Text,
                                     ((Label)GridViewAwards.Rows[i].FindControl("lblYr2")).Text));
                // delete from DB
                Int64 _object = Convert.ToInt64(GridViewAwards.DataKeys[i].Values[2].ToString());
                data.DeleteTriple(this.SubjectID, this.PredicateID, _object);
            }
            //sort
            awards.Sort((a, b) => b.CompareTo(a));
            // add in sorted order
            foreach (Award award in awards)
            {
                data.AddAward(this.SubjectID, award.honorName, award.honoringOrganization, award.startingYear, award.endingYear, this.PropertyListXML);
            }
            this.FillAwardGrid(true);
            upnlEditSection.Update();
        }

        protected void btnCopyAdvanceAwards_OnClick(object sender, EventArgs e)
        {
            try
            {
                JToken itemsToken = Advance.getHonorsAndAwards(this.SubjectID);
                List<Award> awards = new List<Award>();
                int existing = GridViewAwards.Rows.Count;
                if (itemsToken != null)
                {
                    foreach (JToken item in itemsToken)
                    {
                        awards.Add(new Award((string)item["honorName"], (string)item["honoringOrganization"], (string)item["year"], (string)item["year"]));
                    }
                    awards.Sort((a, b) => b.CompareTo(a));
                    foreach (Award award in awards)
                    { 
                        data.AddAward(this.SubjectID, award.honorName, award.honoringOrganization, award.startingYear, award.endingYear, this.PropertyListXML);
                    }
                }
                if (awards.Count > 0)
                {
                    // delete existing ones but only if some were added
                    for (int i = 0; i < existing; i++)
                    {
                        Int64 _object = Convert.ToInt64(GridViewAwards.DataKeys[i].Values[2].ToString());
                        data.DeleteTriple(this.SubjectID, this.PredicateID, _object);
                    }
                    litAdvanceMessage.Text = "Added " + awards.Count + " item" + (awards.Count > 1 ? "s" : "") + " from Advance.";
                    GridViewAwards.Visible = true;
                }
                else
                {
                    litAdvanceMessage.Text = "No Advance award and honor items found for your profile.";
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + ex.StackTrace);
                litAdvanceMessage.Text = "Error accessing Advance for your profile.";
            }
            this.FillAwardGrid(true);
            upnlEditSection.Update();
        }


        protected void GridViewAwards_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            TextBox txtYr1 = null;
            TextBox txtYr2 = null;
            TextBox txtAwardName = null;
            TextBox txtAwardInst = null;
            ImageButton lnkEdit = null;
            ImageButton lnkDelete = null;
            HiddenField hdURI = null;

            AwardState awardstate = null;

            try
            {
                e.Row.Cells[4].Attributes.Add("style", "border-left:0px;");
            }
            catch (Exception ex) { }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {

                txtYr1 = (TextBox)e.Row.Cells[0].FindControl("txtYr1");
                txtYr2 = (TextBox)e.Row.Cells[1].FindControl("txtYr2");
                txtAwardName = (TextBox)e.Row.Cells[2].FindControl("txtAwardName");
                txtAwardInst = (TextBox)e.Row.Cells[3].FindControl("txtAwardInst");
                hdURI = (HiddenField)e.Row.Cells[3].FindControl("hdURI");

                lnkEdit = (ImageButton)e.Row.Cells[4].FindControl("lnkEdit");
                lnkDelete = (ImageButton)e.Row.Cells[4].FindControl("lnkDelete");

                awardstate = (AwardState)e.Row.DataItem;
                hdURI.Value = awardstate.SubjectURI;

                if (awardstate.EditDelete == false)
                    lnkDelete.Visible = false;

                if (awardstate.EditExisting == false)
                    lnkEdit.Visible = false;

            }

            if (e.Row.RowType == DataControlRowType.DataRow && (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit)
            {
                txtYr1.Text = Server.HtmlDecode((string)txtYr1.Text);
                txtYr2.Text = Server.HtmlDecode((string)txtYr2.Text);
                txtAwardName.Text = Server.HtmlDecode((string)txtAwardName.Text);
                txtAwardInst.Text = Server.HtmlDecode((string)txtAwardInst.Text);
            }

        }

        protected void GridViewAwards_RowEditing(object sender, GridViewEditEventArgs e)
        {
            GridViewAwards.EditIndex = e.NewEditIndex;
            this.FillAwardGrid(false);

            upnlEditSection.Update();
        }

        protected void GridViewAwards_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {

            TextBox txtYr1 = (TextBox)GridViewAwards.Rows[e.RowIndex].FindControl("txtYr1");
            TextBox txtYr2 = (TextBox)GridViewAwards.Rows[e.RowIndex].FindControl("txtYr2");
            TextBox txtAwardName = (TextBox)GridViewAwards.Rows[e.RowIndex].FindControl("txtAwardName");
            TextBox txtAwardInst = (TextBox)GridViewAwards.Rows[e.RowIndex].FindControl("txtAwardInst");
            HiddenField hdURI = (HiddenField)GridViewAwards.Rows[e.RowIndex].FindControl("hdURI");


            data.UpdateAward(hdURI.Value, txtAwardName.Text, txtAwardInst.Text, txtYr1.Text, txtYr2.Text, this.PropertyListXML);
            GridViewAwards.EditIndex = -1;
            Session["pnlInsertAward.Visible"] = null;
            this.FillAwardGrid(true);
            upnlEditSection.Update();
        }

        protected void GridViewAwards_RowUpdated(object sender, GridViewUpdatedEventArgs e)
        {
            this.FillAwardGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewAwards_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            GridViewAwards.EditIndex = -1;

            this.FillAwardGrid(false);
            upnlEditSection.Update();
        }

        protected void GridViewAwards_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {

            Int64 predicate = Convert.ToInt64(GridViewAwards.DataKeys[e.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewAwards.DataKeys[e.RowIndex].Values[2].ToString());

            data.DeleteTriple(this.SubjectID, predicate, _object);
            this.FillAwardGrid(true);

            upnlEditSection.Update();
        }

        protected void btnInsertCancel_OnClick(object sender, EventArgs e)
        {
            Session["pnlInsertAward.Visible"] = null;
            txtStartYear.Text = "";
            txtEndYear.Text = "";
            txtInstitution.Text = "";
            txtAwardName.Text = "";
            pnlInsertAward.Visible = false;
            upnlEditSection.Update();
        }

        protected void btnInsert_OnClick(object sender, EventArgs e)
        {
            if (txtStartYear.Text != "" || txtEndYear.Text != "" || txtInstitution.Text != "" || txtAwardName.Text != "")
            {
                data.AddAward(this.SubjectID, txtAwardName.Text, txtInstitution.Text, txtStartYear.Text, txtEndYear.Text, this.PropertyListXML);


                txtStartYear.Text = "";
                txtEndYear.Text = "";
                txtInstitution.Text = "";
                txtAwardName.Text = "";
                Session["pnlInsertAward.Visible"] = null;
                btnEditAwards_OnClick(sender, e);
                this.FillAwardGrid(true);
                if (GridViewAwards.Rows.Count == 1)
                {
                    Session["new"] = true;
                    //stupid update panel bug we cant figure out.
                    Response.Redirect(Request.Url.ToString() + "&new=true");
                }
                else
                {
                    this.FillAwardGrid(true);
                    upnlEditSection.Update();
                }

            }

        }

        protected void btnInsertClose_OnClick(object sender, EventArgs e)
        {
            if (txtStartYear.Text != "" || txtEndYear.Text != "" || txtInstitution.Text != "" || txtAwardName.Text != "")
            {
                Session["pnlInsertAward.Visible"] = null;
                data.AddAward(this.SubjectID, txtAwardName.Text, txtInstitution.Text, txtStartYear.Text, txtEndYear.Text, this.PropertyListXML);

                this.FillAwardGrid(true);


                if (GridViewAwards.Rows.Count == 1)
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

            GridViewAwards.EditIndex = -1;
            Int64 predicate = Convert.ToInt64(GridViewAwards.DataKeys[row.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewAwards.DataKeys[row.RowIndex].Values[2].ToString());

            data.MoveTripleDown(this.SubjectID, predicate, _object);

            this.FillAwardGrid(true);

            upnlEditSection.Update();

        }

        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).Parent.Parent as GridViewRow;
            GridViewAwards.EditIndex = -1;

            Int64 predicate = Convert.ToInt64(GridViewAwards.DataKeys[row.RowIndex].Values[1].ToString());
            Int64 _object = Convert.ToInt64(GridViewAwards.DataKeys[row.RowIndex].Values[2].ToString());

            data.MoveTripleUp(this.SubjectID, predicate, _object);

            this.FillAwardGrid(true);

            upnlEditSection.Update();

        }
        protected void FillAwardGrid(bool refresh)
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
                btnEditAwards.Visible = false;

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


                GridViewAwards.DataSource = awardstate;
                GridViewAwards.DataBind();
            }
            else
            {

                lblNoAwards.Visible = true;
                GridViewAwards.Visible = false;

            }

        }
        #endregion

        public class Award : IComparable<Award>
        {
            public string honorName;
            public string honoringOrganization;
            public string startingYear;
            public string endingYear;

            public Award(String honorName, string honoringOrganization, string startingYear, string endingYear)            
            {
                this.honorName = honorName;
                this.honoringOrganization = honoringOrganization;
                this.startingYear = String.IsNullOrEmpty(startingYear) ? "" : startingYear.Trim();
                this.endingYear = String.IsNullOrEmpty(endingYear) ? "" : endingYear.Trim();
            }

            public int CompareTo(Award other)
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