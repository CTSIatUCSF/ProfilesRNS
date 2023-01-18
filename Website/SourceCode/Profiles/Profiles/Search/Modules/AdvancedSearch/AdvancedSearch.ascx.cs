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
using System.Configuration;

using Profiles.Framework.Utilities;
using Profiles.Search.Utilities;
using System.Data;

namespace Profiles.Search.Modules.AdvancedSearch
{
    public partial class AdvancedSearch : BaseModule
    {

        private static Dictionary<string, List<string>> brandedSections = new Dictionary<string, List<string>>();


        static AdvancedSearch()
        {
            brandedSections.Add("Faculty Mentoring", new List<string>(new string[]{"UCSF", "UC Davis", "UCSD"}));
            brandedSections.Add("Clinical Trials", new List<string>(new string[] { "UCSF", "UC Davis", "UCSD", "UCLA", "UCI"}));
            brandedSections.Add("Student Projects", new List<string>(new string[] { "UCSF", "UC Davis"}));
            brandedSections.Add("Academic Senate Committees", new List<string>(new string[] { "UCSF"}));
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // hate to hard code this, but not sure how else to do it now
            if (!Request.Form[this.hdnSearch.UniqueID].IsNullOrEmpty() && "true".Equals(Request.Form[this.hdnSearch.UniqueID]))
            {
                this.Search();
            }
        }


        public AdvancedSearch() { }
        public AdvancedSearch(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
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
                    trSections.Visible = false;
                    trInterests.Visible = false;
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

            SearchRequest.LoadXml(data.DecryptRequest(searchrequest));

            if (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString") != null)
            {
                txtSearchFor.Text = SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString").InnerText;
            }

            if (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString/@ExactMatch") != null)
            {
                switch (SearchRequest.SelectSingleNode("SearchOptions/MatchOptions/SearchString/@ExactMatch").Value)
                {
                    case "true":
                        //chkExactphrase.Checked = true;
                        break;
                    case "false":
                        //chkExactphrase.Checked = false;
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
            foreach (GenericListItem dtListItem in data.GetFacultyRanks())
            {
                ListItem itmFacType = new ListItem();
                itmFacType.Text = dtListItem.Text;
                itmFacType.Value = dtListItem.Value;
                cblResearcherType.Items.Add(itmFacType);
            }
        }

        private void BuildFilters()
        {

            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

            System.Data.DataSet ds = data.GetPersonTypes();

            // new. Note that this is "hard coded: for personTypeGroupId[1]=sections, personTypeGroupId[2]=interests
            /***********  Uncomment if we want to NOT hard code one day
            DataTable l_dtMaster = ds.Tables["DataMasterName"];
            foreach (DataRow row in l_dtMaster.Rows)
            {
                string foo = row["personTypeGroupId"].ToString(); //1, 2
                string bar = row["personTypeGroup"].ToString(); // the label
            }
            **********/
            DataTable l_dtDetail = ds.Tables["DataDetailName"];
            foreach (DataRow row in l_dtDetail.Rows)
            {
                Int32 group = (Int32)row["personTypeGroupId"];
                string label = row["personTypeFlag"].ToString(); // Clinical Trials, etc.

                ListItem itmOption = new ListItem();
                itmOption.Text = label;
                itmOption.Value = label; 

                // ugly hard coded logic to skip certain sections for certain institutions
                if (brandedSections.ContainsKey(label) && !Brand.GetCurrentBrand().IsMultiInstitutional() && !brandedSections[label].Contains(Brand.GetCurrentBrand().GetInstitution().GetAbbreviation()))
                {
                    continue;
                }

                if (group == 1)
                {
                    cblSections.Items.Add(itmOption);
                }
                else if (group == 2)
                {
                    // only include gadgets that make sense for this brand
                    if (Brand.GetCurrentBrand().IsApplicableForFilter(label))
                    {
                        cblInterests.Items.Add(itmOption);
                    }
                }
            }

        }

        private void Search()
        {
            string lname = Request.Form[this.txtLname.UniqueID];
            string fname = Request.Form[this.txtFname.UniqueID];
            string searchfor = Request.Form[this.txtSearchFor.UniqueID];
            string exactphrase = "false";// Request.Form[this.chkExactphrase.UniqueID];

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

            // new stuff by Eric
            string facrankNew = GetCheckBoxListSelectedItems(Request, cblResearcherType);

            string otherfilters = GetCheckBoxListSelectedItems(Request, cblSections) + GetCheckBoxListSelectedItems(Request, cblInterests);
            if (!String.IsNullOrEmpty(Brand.GetCurrentBrand().PersonFilter))
            {
                otherfilters += "," + Brand.GetCurrentBrand().PersonFilter;
            }

            string classuri = "http://xmlns.com/foaf/0.1/Person";

            string searchrequest = string.Empty;

            Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();



            data.SearchRequest(searchfor, exactphrase, fname, lname, institution, institutionallexcept,
                department, departmentallexcept, division, divisionallexcept, classuri, "15", "0", "", "", otherfilters, facrankNew, true, ref searchrequest);

            Response.Redirect(Brand.GetThemedDomain() + "/search/default.aspx?showcolumns=" + (Brand.GetCurrentBrand().IsMultiInstitutional() ? "9" : "10") +  "&searchtype=people&otherfilters=" + otherfilters + "&searchrequest=" + searchrequest, true);

        }

        private string GetCheckBoxListSelectedItems(System.Web.HttpRequest req, CheckBoxList cbl)
        {
            string retval = "";
            int ndx = 0;
            foreach (ListItem item in cbl.Items)
            {
                if ("on".Equals(req.Form[cbl.UniqueID + "$" + ndx++]))
                {
                    retval += "," + item.Text;
                }
            }
            return retval;
        }

        private XmlDocument SearchRequest { get; set; }
    }
}
