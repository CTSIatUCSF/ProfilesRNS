/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/


using System;
using System.Web;
using System.Web.UI;
using System.Xml;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

using Profiles.Framework.Utilities;
using Profiles.Search.Utilities;

namespace Profiles.Search
{
    public partial class Default : BrandedPage
    {
        Profiles.Framework.Template masterpage;



        //public void Page_Load(object sender, EventArgs e)
        override protected void OnInit(EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;

            if (Request.UrlReferrer == null || !Request.UrlReferrer.ToString().ToLower().Contains("/search"))
            {
                Session["DIRECTSEARCHTYPE"] = null;
                Session["SEARCHREQUEST"] = null;
                masterpage.SearchRequest = null;
            }

            string tab = string.Empty;


            if (Request.QueryString["searchtype"] == null && Request.Form["searchtype"] == null && Session["DIRECTSEARCHTYPE"] != null)
                this.SearchType = Session["DIRECTSEARCHTYPE"].ToString();
            else if (Request.QueryString["searchtype"] == null && Request.Form["searchtype"] != null && Session["DIRECTSEARCHTYPE"] == null)
                this.SearchType = Request.Form["searchtype"];
            else if (Request.QueryString["searchtype"] != null && Request.Form["searchtype"] == null && Session["DIRECTSEARCHTYPE"] == null)
                this.SearchType = Request.QueryString["searchtype"];


            if (Session["DIRECTSEARCHREQUEST"] != null)
            {
                masterpage.SearchRequest = Session["DIRECTSEARCHREQUEST"].ToString();
                string searchrequest = masterpage.SearchRequest;
                
                Session["DIRECTKEYWORD"] = null;
                Session["DIRECTSEARCHREQUEST"] = null;
                Session["DIRECTSEARCHTYPE"] = null;

                Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();

                data.SearchRequest("", "", "", "", "", "", "", "", "", "", "", "15", "0", "", "", "", "", true, ref searchrequest);

                Response.Redirect(Brand.GetThemedDomain() + "/search/default.aspx?searchtype=" + this.SearchType + "&searchrequest=" + searchrequest, true);

            }

            if (this.SearchType.IsNullOrEmpty())
            {
                this.LoadPresentationXML("searchform");
                if (Request.QueryString["tab"] != null)
                    masterpage.Tab = Request.QueryString["tab"];
                else
                    masterpage.Tab = "";



                masterpage.RDFData = null;
                masterpage.RDFNamespaces = null;
            }
            // added by UCSF.  A hack THAT NEEDS TO BE TESTED (try not doing the UrlEncode)
            else if (Request.QueryString["tab"] == "concept")
            {
                Response.Redirect(Brand.GetThemedDomain() + "/search/default.aspx?searchtype=everything&searchfor=" + HttpUtility.UrlEncode(Request.Form["txtSearchFor"]) +
                    "&ClassGroupURI=" + HttpUtility.UrlEncode("http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupConcepts") + "&perpage=15&offset=");
            }
            else
            {
                if (Request.QueryString["tab"] != null)
                    masterpage.Tab = Request.QueryString["tab"];
                else
                    masterpage.Tab = "";

                this.LoadPresentationXML(this.SearchType);

                this.LoadRDFSearchResults();
            }

            this.LoadAssets(this.SearchType);
            masterpage.PresentationXML = this.PresentationXML;





        }

        public void LoadPresentationXML(string type)
        {
            string presentationxml = string.Empty;
            switch (type.ToLower())
            {
                case "searchform":
                    presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "SearchFormPresentation.xml");
                    break;
                case "everything":
                    presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "SearchResultsEverythingPresentation.xml");
                    break;
                case "people":
                    presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "SearchResultsPersonPresentation.xml");
                    break;
                case "whyeverything":
                case "whypeople":
                    presentationxml = XslHelper.GetThemedOrDefaultPresentationXML(Page, "SearchResultsConnectionPresentation.xml");
                    break;
            }

            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);
            Framework.Utilities.DebugLogging.Log(presentationxml);

        }

        private void LoadAssets(string type)
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            //body.Attributes.Add("class", "search"); Commented out 2/3/2021
            if (type == null || "searchform".Equals(type.ToLower()))
            {
                body.Attributes.Add("class", "researcherprofiles--home-page");
            }
            else
            {
                body.Attributes.Add("class", "researcherprofiles--search-results-page");
            }

            // Commented out 2/2/2021
            //PlaceHolder pageColumnLeft = (PlaceHolder)Page.Master.FindControl("PageColumnLeft");
            //pageColumnLeft.Visible = true;

            HtmlLink Searchcss = new HtmlLink();
            Searchcss.Href = Brand.GetThemedDomain() + "/Search/CSS/search.css";
            Searchcss.Attributes["rel"] = "stylesheet";
            Searchcss.Attributes["type"] = "text/css";
            Searchcss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Searchcss);

            HtmlLink Activitycss = new HtmlLink();
            Activitycss.Href = Brand.GetThemedDomain() + "/Activity/CSS/activity.css";
            Activitycss.Attributes["rel"] = "stylesheet";
            Activitycss.Attributes["type"] = "text/css";
            Activitycss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Activitycss);

            HtmlLink Checkboxcss = new HtmlLink();
            Checkboxcss.Href = Brand.GetThemedDomain() + "/Search/CSS/comboTreeCheck.css";
            Checkboxcss.Attributes["rel"] = "stylesheet";
            Checkboxcss.Attributes["type"] = "text/css";
            Checkboxcss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Checkboxcss);

            HtmlGenericControl jsscript = new HtmlGenericControl("script");
            jsscript.Attributes.Add("type", "text/javascript");
            jsscript.Attributes.Add("src", Brand.GetThemedDomain() + "/Search/JavaScript/comboTreeCheck.js");
            Page.Header.Controls.Add(jsscript);

            // Inject script into HEADER
            Literal script = new Literal();
            script.Text = "<script>var _path = \"" + Brand.GetThemedDomain() + "\";</script>";
            Page.Header.Controls.Add(script);

            // UCSF. More testing! Need to think of framework to include for some themese but not others.
            if (Page.Theme != "Default")
            {
                HtmlGenericControl UCSFjs = new HtmlGenericControl("script");
                UCSFjs.Attributes.Add("type", "text/javascript");
                UCSFjs.Attributes.Add("src", Brand.GetThemedDomain() + "/Search/JavaScript/UCSF.js");
                Page.Header.Controls.Add(UCSFjs);
            }
            // Women in Science
            Page.Master.FindControl("WomenInScienceBanner").Visible = Brand.ShowWomenInScience();
        }

        //Need to process this at the page level for the framework data
        //to process the presentation XML
        public void LoadRDFSearchResults()
        {
           
            XmlDocument xml = new XmlDocument();
            Namespace rdfnamespaces = new Namespace();
            Utilities.DataIO data = new Utilities.DataIO();

            string searchtype = string.Empty;
            string lname = string.Empty;
            string fname = string.Empty;
            string institution = string.Empty;
            string department = string.Empty;
            string division = string.Empty;

            string searchfor = string.Empty;
            string classgroupuri = string.Empty;
            string classuri = string.Empty;
            string perpage = string.Empty;
            string offset = string.Empty;
            string sortby = string.Empty;
            string sortdirection = string.Empty;
            string searchrequest = string.Empty;
            string otherfilters = string.Empty;
            string institutionallexcept = string.Empty;
            string departmentallexcept = string.Empty;
            string divisionallexcept = string.Empty;
            string exactphrase = string.Empty;
            string nodeuri = string.Empty;
            string nodeid = string.Empty;


            if (Request.QueryString["new"] == "true")
            {
                Session["searchrequest"] = null;
                masterpage.SearchRequest = null;
            }

            if (this.SearchType.IsNullOrEmpty() == false)
                searchtype = this.SearchType;

            //else if (Request.Form["searchtype"] != null)
            //{
            //    searchtype = Request.Form["searchtype"];
            //}

            if (Request.QueryString["searchfor"].IsNullOrEmpty() == false)
                searchfor = Request.QueryString["searchfor"];

            if (Request.Form["txtSearchFor"].IsNullOrEmpty() == false)
                searchfor = Request.Form["txtSearchFor"];

            if (Request.QueryString["lname"].IsNullOrEmpty() == false)
                lname = Request.QueryString["lname"];

            if (Request.QueryString["institution"].IsNullOrEmpty() == false)
                institution = Request.QueryString["institution"];

            if (Request.QueryString["department"].IsNullOrEmpty() == false)
                department = Request.QueryString["department"];

            if (Request.QueryString["division"].IsNullOrEmpty() == false)
                division = Request.QueryString["division"];
            
            if (Request.QueryString["fname"].IsNullOrEmpty() == false)
                fname = Request.QueryString["fname"];

            if (Request.QueryString["classgroupuri"].IsNullOrEmpty() == false)
                classgroupuri = HttpUtility.UrlDecode(Request.QueryString["classgroupuri"]);
            else
                classgroupuri = HttpUtility.UrlDecode(Request.Form["classgroupuri"]);

            if (classgroupuri != null)
            {
                if (classgroupuri.Contains("!"))
                    classgroupuri = classgroupuri.Replace('!', '#');
            }

            if (Request.QueryString["classuri"].IsNullOrEmpty() == false)
                classuri = HttpUtility.UrlDecode(Request.QueryString["classuri"]);
            else
                classuri = HttpUtility.UrlDecode(Request.Form["classuri"]);

            if (classuri != null)
            {
                if (classuri.Contains("!"))
                    classuri = classuri.Replace('!', '#');
            }
            else
            {
                classuri = "";
            }

            if (Request.QueryString["perpage"].IsNullOrEmpty() == false)
                perpage = Request.QueryString["perpage"];
            else
                perpage = Request.Form["perpage"];

            //if (perpage == string.Empty || perpage == null)
            //{
            //    perpage = Request.QueryString["perpage"];
            //}

            if (perpage.IsNullOrEmpty())
                perpage = "15";

            if (Request.QueryString["offset"].IsNullOrEmpty() == false)
                offset = Request.QueryString["offset"];
            else
                offset = Request.Form["offset"];

            if (offset.IsNullOrEmpty())
                offset = "0";

            //if (offset == null)
            //    offset = "0";

            if (Request.QueryString["sortby"].IsNullOrEmpty() == false)
                sortby = Request.QueryString["sortby"];

            if (Request.QueryString["sortdirection"].IsNullOrEmpty() == false)
                sortdirection = Request.QueryString["sortdirection"];



            if (Request.QueryString["searchrequest"].IsNullOrEmpty() == false)
                searchrequest = Request.QueryString["searchrequest"];
            else if (Session["searchrequest"] != null)
                searchrequest = data.EncryptRequest(Session["searchrequest"].ToString());
            else if (masterpage.SearchRequest.IsNullOrEmpty() == false)
                searchrequest = masterpage.SearchRequest;

            if (Request.QueryString["otherfilters"].IsNullOrEmpty() == false)
                otherfilters = Request.QueryString["otherfilters"];

            if (Request.QueryString["institutionallexcept"].IsNullOrEmpty() == false)
                institutionallexcept = Request.QueryString["institutionallexcept"];

            if (Request.QueryString["departmentallexcept"].IsNullOrEmpty() == false)
                departmentallexcept = Request.QueryString["departmentallexcept"];

            if (Request.QueryString["divisionallexcept"].IsNullOrEmpty() == false)
                divisionallexcept = Request.QueryString["divisionallexcept"];

            if (Request.QueryString["exactphrase"].IsNullOrEmpty() == false)
                exactphrase = Request.QueryString["exactphrase"];

            if (Request.QueryString["nodeuri"].IsNullOrEmpty() == false)
            {
                nodeuri = Request.QueryString["nodeuri"];
                nodeid = nodeuri.Substring(nodeuri.LastIndexOf("/") + 1);
            }

            switch (searchtype.ToLower())
            {
                case "everything":

                    if (searchrequest != string.Empty)
                        xml.LoadXml(data.DecryptRequest(searchrequest));
                    else
                        xml = data.SearchRequest(searchfor, exactphrase, classgroupuri, classuri, perpage, offset);

                    break;
                default:                //Person is the default
                    if (searchrequest != string.Empty)
                        xml.LoadXml(data.DecryptRequest(searchrequest));
                    else
                        xml = data.SearchRequest(searchfor, exactphrase, fname, lname, institution, institutionallexcept, department, departmentallexcept, division, divisionallexcept, classuri, perpage, offset, sortby, sortdirection, otherfilters, "", true, ref searchrequest);
                    break;
            }

            searchrequest = xml.OuterXml;
            Session["SearchRequest"] = searchrequest;

            if (nodeuri != string.Empty && nodeid != string.Empty)
                masterpage.RDFData = data.WhySearch(xml, nodeuri, Convert.ToInt64(nodeid));
            else
                masterpage.RDFData = data.Search(xml, false);

            Framework.Utilities.DebugLogging.Log(masterpage.RDFData.OuterXml);
            masterpage.RDFNamespaces = rdfnamespaces.LoadNamespaces(masterpage.RDFData);
            masterpage.SearchRequest = searchrequest;

        }

        public XmlDocument PresentationXML { get; set; }

        public string SearchType { get; set; }        

    }
}
