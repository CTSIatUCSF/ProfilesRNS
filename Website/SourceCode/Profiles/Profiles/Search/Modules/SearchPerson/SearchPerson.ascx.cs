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
using System.Configuration;

using Profiles.Framework.Utilities;
using Profiles.Search.Utilities;


namespace Profiles.Search.Modules.SearchPerson
{
    public partial class SearchPerson : BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // hate to hard code this, but not sure how else to do it now
            if (!Request.Form[this.hdnSearch.UniqueID].IsNullOrEmpty() && "true".Equals(Request.Form[this.hdnSearch.UniqueID]))
            {
                this.Search();
            }
        }


        public SearchPerson() { }
        public SearchPerson(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
            txtSearchFor.Attributes.Add("onkeypress", "JavaScript:runScript(event);");
            txtFname.Attributes.Add("onkeypress", "JavaScript:runScript(event);");
            txtLname.Attributes.Add("onkeypress", "JavaScript:runScript(event);");
            


            if (Request.QueryString["action"] == "modify")
            {
                
                this.ModifySearch();
            }
            else
            {
                //Profiles.Search.Utilities.DataIO dropdowns = new Profiles.Search.Utilities.DataIO();
                if (Convert.ToBoolean(ConfigurationSettings.AppSettings["ShowInstitutions"]) == true)
                {
                    litInstitution.Text = SearchDropDowns.BuildDropdown("institution", "249", Brand.GetCurrentBrand().IsMultiInstitutional() ? "" : Brand.GetCurrentBrand().GetInstitution().GetName(), Brand.GetCurrentBrand());
                }
                trInstitution.Visible = Brand.GetCurrentBrand().IsMultiInstitutional();

                if (Convert.ToBoolean(ConfigurationSettings.AppSettings["ShowDepartments"]) == true && !Brand.GetCurrentBrand().IsMultiInstitutional())
                {
                    litDepartment.Text = SearchDropDowns.BuildDropdown("department", "249", "", Brand.GetCurrentBrand());
                }
                else
                {
                    trDepartment.Visible = false;
                }

                if (Convert.ToBoolean(ConfigurationSettings.AppSettings["ShowDivisions"]) == true && !Brand.GetCurrentBrand().IsMultiInstitutional())
                {
                    litDivision.Text = SearchDropDowns.BuildDropdown("division", "249", "", Brand.GetCurrentBrand());
                }
                else
                {
                    trDivision.Visible = false;
                }
                if (Convert.ToBoolean(ConfigurationSettings.AppSettings["ShowOtherOptions"]) == false)// || !String.IsNullOrEmpty(Brand.GetCurrentBrand().PersonFilter))
                {
                    trOtherOptions.Visible = false;
                }

            }
    
            BuildFacultyType();
            BuildFilters();
        }

        private void ModifySearch()
        {
            Search.Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

            bool institutiondropdown = false;
            bool departmentdropdown = false;
            bool divisiondropdown = false;
            string searchrequest = string.Empty;


            if (base.MasterPage !=null)
            {
                if(base.MasterPage.SearchRequest.IsNullOrEmpty() ==false)
                searchrequest = base.MasterPage.SearchRequest;
            }
            else if (Request.QueryString["searchrequest"].IsNullOrEmpty() == false)
            {
                searchrequest = Request.QueryString["searchrequest"];
            }

            SearchRequest = new XmlDocument();

            ctcFirst.SearchRequest = new XmlDocument();

            SearchRequest.LoadXml(data.DecryptRequest(searchrequest));

            ctcFirst.SearchRequest = this.SearchRequest;
            


            if (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString") != null)
            {
                txtSearchFor.Text = SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString").InnerText;
            }

            if (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString/@ExactMatch") != null)
            {
                switch (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString/@ExactMatch").Value)
                {
                    case "true":
                        chkExactphrase.Checked = true;
                        break;
                    case "false":
                        chkExactphrase.Checked = false;
                        break;
                }
            }

            if (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchFiltersList") != null)
            {

                foreach (XmlNode x in SearchRequest.SelectNodes("SearchOptions/MatchOptions/SearchFiltersList/SearchFilter"))
                {
                    if (x.SelectSingleNode("@Property").Value == "http://vivoweb.org/ontology/core#personInPosition" && x.SelectSingleNode("@Property2").Value == "http://vivoweb.org/ontology/core#positionInOrganization")
                    {


                        litInstitution.Text = SearchDropDowns.BuildDropdown("institution", "249", x.InnerText, Brand.GetCurrentBrand());
                        institutiondropdown = true;

                        if (x.SelectSingleNode("@IsExclude").Value == "1")
                            institutionallexcept.Checked = true;
                        else
                            institutionallexcept.Checked = false;
                    }

                    if (x.SelectSingleNode("@Property").Value == "http://vivoweb.org/ontology/core#personInPosition" && x.SelectSingleNode("@Property2").Value == "http://profiles.catalyst.harvard.edu/ontology/prns#positionInDepartment")
                    {
                        litDepartment.Text = SearchDropDowns.BuildDropdown("department", "249", x.InnerText, Brand.GetCurrentBrand());
                        departmentdropdown = true;

                        if (x.SelectSingleNode("@IsExclude").Value == "1")
                            departmentallexcept.Checked = true;
                        else
                            departmentallexcept.Checked = false;
                    }


                    if (x.SelectSingleNode("@Property").Value == "http://vivoweb.org/ontology/core#personInPosition" && x.SelectSingleNode("@Property2").Value == "http://profiles.catalyst.harvard.edu/ontology/prns#positionInDivision")
                    {
                        litDivision.Text = SearchDropDowns.BuildDropdown("division", "249", x.InnerText, Brand.GetCurrentBrand());
                        divisiondropdown = true;

                        if (x.SelectSingleNode("@IsExclude").Value == "1")
                            divisionallexcept.Checked = true;
                        else
                            divisionallexcept.Checked = false;
                    }

                    if (x.SelectSingleNode("@Property").Value == "http://profiles.catalyst.harvard.edu/ontology/prns#hasPersonFilter")
                    {

                    }

                    if (x.SelectSingleNode("@Property").Value == "http://xmlns.com/foaf/0.1/firstName")
                    {
                        txtFname.Text = x.InnerText;
                    }

                    if (x.SelectSingleNode("@Property").Value == "http://xmlns.com/foaf/0.1/lastName")
                    {
                        txtLname.Text = x.InnerText;
                    }
                }
            }

            if (!institutiondropdown)
                litInstitution.Text = SearchDropDowns.BuildDropdown("institution", "249", "", Brand.GetCurrentBrand());

            if (!Brand.GetCurrentBrand().IsMultiInstitutional())
            {
                if (!departmentdropdown)
                    litDepartment.Text = SearchDropDowns.BuildDropdown("department", "249", "", Brand.GetCurrentBrand());

                if (!divisiondropdown)
                    litDivision.Text = SearchDropDowns.BuildDropdown("division", "249", "", Brand.GetCurrentBrand());
            }
            else
            {
                trDepartment.Visible = false;
                trDivision.Visible = false;
            }
        }

        public string GetThemedDomain()
        {
            return Brand.GetThemedDomain();
        }


        private void BuildFacultyType()
        {
            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

            DropDownList ddl = new DropDownList();
            ddl.ID = "ddlChkList";
            ListItem lstItem = new ListItem();
            ddl.Items.Insert(0, lstItem);
            ddl.Attributes.Add("title", "faculty type");
            ddl.Width = new Unit(250);
            ddl.Height = new Unit(20);
            ddl.Attributes.Add("onclick", "showdivonClick()");
            ddl.Attributes.Add("onkeypress", "showdivonClick()");
            CheckBoxList chkBxLst = new CheckBoxList();
            chkBxLst.ID = "chkLstItem";
            chkBxLst.Attributes.Add("onmouseover", "showdiv()");
            chkBxLst.Attributes.Add("onfocus", "if ( event.keyCode == 13) showdiv()");
            List<GenericListItem> dtListItem = data.GetFacultyRanks();
            int rowNo = dtListItem.Count;
            string lstValue = string.Empty;
            string lstID = string.Empty;
            string javascript = string.Empty;


            litFacRankScript.Text = "<script>";
            for (int i = 0; i < rowNo; i++)
            {
                lstValue = dtListItem[i].Text;
                lstID = dtListItem[i].Value;
                lstItem = new ListItem("<a href=\"javascript:void(0)\" id=\"alst\" style=\"text-decoration:none;color:Black; \" onclick=\"getSelectedItem(' " + lstValue + "','" + i + "','" + lstID + "','anchor');\">" + lstValue + "</a>", lstID);
                lstItem.Attributes.Add("onclick", "getSelectedItem('" + lstValue + "','" + i + "','" + lstID + "','listItem');");

                if (SearchRequest != null && !lstID.IsNullOrEmpty())
                {
                    if (SearchRequest.OuterXml.Contains(lstID))
                    {                                        
                        javascript += " javascript:getSelectedItem('" + lstValue + "','" + i + "','" + lstID + "','anchor');";
                    }
                }

                chkBxLst.Items.Add(lstItem);
            }


            litFacRankScript.Text += javascript + "</script>";



            System.Web.UI.HtmlControls.HtmlGenericControl div = new System.Web.UI.HtmlControls.HtmlGenericControl("div");
            div.ID = "divChkList";
            div.Controls.Add(chkBxLst);
            div.Style.Add("background-color", "#ffffff");
            div.Style.Add("position", "absolute");
            div.Style.Add("fload", "left");
            div.Style.Add("border", "black 1px solid");
            div.Style.Add("width", "248px");
            div.Style.Add("height", "180px");
            div.Style.Add("overflow", "AUTO");
            div.Style.Add("display", "none");
            div.Style.Add("padding-top", "25px");
            phDDLCHK.Controls.Add(ddl);
            phDDLList.Controls.Add(div);

        }

        private void BuildFilters()
        {

            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

            System.Data.DataSet ds = data.GetPersonTypes();

            ctcFirst.DataMasterName = "DataMasterName";
            ctcFirst.DataDetailName = "DataDetailName";

            ctcFirst.DataMasterIDField = "personTypeGroupId";
            ctcFirst.DataMasterTextField = "personTypeGroup";

            ctcFirst.DataDetailIDField = "personTypeFlagId";
            ctcFirst.DataDetailTextField = "personTypeFlag";

            ctcFirst.DataSource = ds;
            ctcFirst.DataBind();

        }

        private void Search()
        {
            string lname = Request.Form[this.txtLname.UniqueID];
            string fname = Request.Form[this.txtFname.UniqueID];
            string searchfor = Request.Form[this.txtSearchFor.UniqueID];
            string exactphrase = Request.Form[this.chkExactphrase.UniqueID];
            string facrank = Request.Form[this.hidList.UniqueID];

            if (exactphrase == "on")
                exactphrase = "true";
            else
                exactphrase = "false";

            string institution = "";
            string institutionallexcept = "";

            string department = "";
            string departmentallexcept = "";

            string division = "";
            string divisionallexcept = "";


            if (!Brand.GetCurrentBrand().IsMultiInstitutional())
            {
                institution = SearchDropDowns.GetDefaultItemValue("institution", Brand.GetCurrentBrand().GetInstitution().GetName(), Brand.GetCurrentBrand());
            }
            else if (Request.Form["institution"] != null)
            {
                institution = Request.Form["institution"];
                institutionallexcept = Request.Form[this.institutionallexcept.UniqueID];//Request.Form["institutionallexcept"];
            }

            if (!Request.Form["department"].IsNullOrEmpty())
            {
                department = Request.Form["department"];
                departmentallexcept = Request.Form[this.departmentallexcept.UniqueID];
            }

            if (!Request.Form["division"].IsNullOrEmpty())
            {
                division = Request.Form["division"];
                divisionallexcept = Request.Form[this.divisionallexcept.UniqueID];
            }

            string otherfilters = Request.Form["hdnSelectedText"];
            if (!String.IsNullOrEmpty(Brand.GetCurrentBrand().PersonFilter))
            {
                otherfilters += "," + Brand.GetCurrentBrand().PersonFilter;
            }

            string classuri = "http://xmlns.com/foaf/0.1/Person";

            string searchrequest = string.Empty;

            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();



            data.SearchRequest(searchfor, exactphrase, fname, lname, institution, institutionallexcept,
                department, departmentallexcept, division, divisionallexcept, classuri, "15", "0", "", "", otherfilters, facrank, true, ref searchrequest);

            Response.Redirect(Brand.GetThemedDomain() + "/search/default.aspx?showcolumns=" + (Brand.GetCurrentBrand().IsMultiInstitutional() ? "9" : "10") +  "&searchtype=people&otherfilters=" + otherfilters + "&searchrequest=" + searchrequest, true);



        }

        private XmlDocument SearchRequest { get; set; }
    }
}
