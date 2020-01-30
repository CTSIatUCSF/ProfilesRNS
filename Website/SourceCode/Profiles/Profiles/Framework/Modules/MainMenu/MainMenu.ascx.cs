
using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Xml;
using System.Linq;
using Profiles.Framework.Utilities;
using System.Web.UI.WebControls;
using System.Web;

namespace Profiles.Framework.Modules.MainMenu
{
    public partial class MainMenu : BaseModule
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            menulist = new System.Text.StringBuilder();
            sm = new SessionManagement();

                DrawProfilesModule();

        }
        protected void Page_Init(object sender, EventArgs e)
        {

            }
        protected override void OnInit(EventArgs e)
        {


        }
        public MainMenu() : base() { }

        public MainMenu(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            //ActiveNetworkRelationshipTypes.ClassURI = "";
        }

        private void DrawProfilesModule()
        {
            System.Text.StringBuilder menulist = new System.Text.StringBuilder();
            SessionManagement sm = new SessionManagement();
            Int64 subject = 0;

            HttpContext.Current.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            HttpContext.Current.Response.Cache.SetExpires(DateTime.Now);
            HttpContext.Current.Response.Cache.SetNoServerCaching();
            HttpContext.Current.Response.Cache.SetNoStore();

            if (Request.QueryString["subject"] != null)
                subject = Convert.ToInt64(Request.QueryString["subject"]);

            Utilities.DataIO data = new Profiles.Framework.Utilities.DataIO();
                menulist.Append("<li><a href='" + Brand.GetThemedDomain() + "/SPARQL/default.aspx'>SPARQL Query</a></li>");

            Brand userBrand = Brand.GetCurrentBrand();
            Session session = sm.Session();
            // logged in Person
            if (UCSFIDSet.IsPerson(session.NodeID))
            {
                userBrand = Brand.GetForSubject(session.NodeID);
                menulist.Append("<li id='myprofile'><a href='" + UCSFIDSet.ByNodeId[session.NodeID].PrettyURL
                    + "'><div id='menuthumb'><img src='" + userBrand.BasePath + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID="
                    + session.NodeID + "&Thumbnail=True&Width=20' width='20' alt=''></div>"
                    + session.DisplayName + "</a></li>");
            }
            else if (!String.IsNullOrEmpty(session.DisplayName)) // logged in person
            {
                menulist.Append("<li>" + session.DisplayName + "</li>");
            }

            if (UCSFIDSet.IsPerson(session.NodeID))
            {
                menulist.Append("<li id='editmy'><a href='" + userBrand.BasePath + "/edit/" + session.NodeID.ToString() + "'>Edit Your Profile</a></li>");
            }

            litEditThisProfile.Text = "<li><a href='" + Root.Domain + "/login/default.aspx?pin=send&method=login&edit=true'>Edit My Profile</a></li>";

            if (base.MasterPage.CanEdit)
                litEditThisProfile.Text += "<li><div class=\"divider\"></div></li><li><a href='" + Root.Domain + "/edit/default.aspx?subject=" + subject.ToString() + "'>Edit This Profile</a></li>";
                menulist.Append("<li><a href='" + Brand.GetForSubject(subject).BasePath + "/edit/" + subject.ToString() + "'>Edit This " + (UCSFIDSet.IsPerson(subject) ? "Profile" : "Group") + "</a></li>");

            // ORNG Dashboard (only show for UCSF adn UCSD for now)
            string[] dashboardInstitutions = {"UCSF", "UCSD"};
            if (UCSFIDSet.IsPerson(session.NodeID) && userBrand.GetInstitution() != null && dashboardInstitutions.Contains(userBrand.GetInstitution().GetAbbreviation()))
            {
                menulist.Append("<li id='dashboard'><a href='" + userBrand.BasePath + "/ORNG/Dashboard.aspx?owner=" + session.PersonURI + "'>Dashboard</a></li>");
            }

            if (UCSFIDSet.IsPerson(session.NodeID))
            {
                menulist.Append("<li><a href='" + userBrand.BasePath + "/proxy/default.aspx?subject=" + session.NodeID.ToString() + "'>Proxies</a></li>");
            }
            if (base.BaseData.SelectSingleNode(".").OuterXml != string.Empty && !Root.AbsolutePath.ToLower().Contains("/search"))
            {
                if (base.BaseData.SelectSingleNode("//rdf:RDF/rdf:Description/@rdf:about", base.Namespaces) != null && !Root.AbsolutePath.ToLower().Contains("proxy"))
                {
                    string uri = this.BaseData.SelectSingleNode("//rdf:RDF/rdf:Description/@rdf:about", base.Namespaces).Value;

                    string file = string.Empty;
                    string spostring = string.Empty;
                    string[] spoarray;

                    spostring = uri.ToLower().Replace(Root.Domain.ToLower() + "/profile/", "");
                    spoarray = spostring.Split('/');

                    for (int i = 0; i < spoarray.Length; i++)
                    {
                        file = file + spoarray[i] + "_";
                    }

                    file = file.Substring(0, file.Length - 1);

                        //menulist.Append("<li><a href=\"" + uri + "/" + file + ".rdf\" target=\"_blank\">" + "Export RDF" + "</a>&nbsp;<a style='border: none;' href='" + Brand.GetDomain() + "/about/default.aspx?tab=data'><img style='border-style: none' src='" + Brand.GetDomain() + "/Framework/Images/info.png' width='11' height='11' border='0'></a></li>");
                    if (base.MasterPage != null)
                    {
                        System.Web.UI.HtmlControls.HtmlContainerControl Head1;
                        Head1 = (System.Web.UI.HtmlControls.HtmlContainerControl)base.MasterPage.FindControl("Head1");
                        //If a masterpage exists, you need to to create an ASP.Net Literal object and pass it to the masterpage so it can process the link in the Head block.
                        string link = "<link rel=\"alternate\" type=\"application/rdf+xml\" href=\"" + uri + "/" + file + ".rdf\" />";
                        Head1.Controls.Add(new LiteralControl(link));
                        litJs.Text += "<script type='text/javascript'>$('#useourdata').css('border-bottom','');</script>";
                    }
                }
            }
            //else
            //  litExportRDF.Visible = false;

            if (sm.Session().UserID > 0)
            {
                if (data.IsGroupAdmin(sm.Session().UserID))
                {
                    litGroups.Text = "<li><a href='" + Root.Domain + "/groupAdmin/default.aspx'>Manage Groups</a></li>";
                    groupListDivider.Visible = true;
                }
            }

            if (!session.IsLoggedIn())
            {
                if (!Root.AbsolutePath.Contains("login"))
                {
                    menulist.Append("<li id='signin'><a href='" + Brand.GetThemedDomain() + "/login/default.aspx?method=login&redirectto=edit'>SIGN IN TO EDIT</a></li>");
                    loginclass = "pub";
                }
            }
            else
            {
                if (session.UserID > 0)
                {
                    if (data.IsGroupAdmin(session.UserID))
                        menulist.Append("<li><a href='" + Root.Domain + "/groupAdmin/default.aspx'>Manage Groups</a></li>");
                }
                menulist.Append("<li><a href='" + Brand.GetThemedDomain() + "/login/default.aspx?method=logout&redirectto=" + Brand.GetThemedDomain() + "/About/CloseBrowser.aspx" + "'>Sign Out</a></li>");
            }

            if (sm.Session().UserID > 0)
            {
                // litDashboard.Text = "<a href ='" + ResolveUrl("~/dashboard/default.aspx?subject=" + sm.Session().NodeID.ToString()) + "'>My Dashboard </a>";
            }

            litJs.Text += "<script type='text/javascript'> var NAME = document.getElementById('prns-usrnav'); NAME.className = '" + loginclass + "';";
            /** UCSF
            if (session.UserID > 0)
            {                
              
                //Change this to show two drop down items based on the count.
                MyLists.Visible = true;
            }
            else if (sm.Session().UserID == 0)
            {
                MyLists.Visible = false;
                litJs.Text += " $('#navMyLists').remove(); $('#ListDivider').remove();";
            }
             **/

            litJs.Text += "</script>";
            UserHistory uh = new UserHistory();

            ProfileHistory.RDFData = base.BaseData;
            ProfileHistory.PresentationXML = base.MasterPage.PresentationXML;
            ProfileHistory.Namespaces = base.Namespaces;

        }
            DrawSearchBar();
        }

        // For megasearch items
        public string GetThemedDomain()
        {
            return Brand.GetThemedDomain();
        }

        public string GetDomainFor(String theme)
        {
            return Brand.GetByTheme(theme).BasePath;

        }

        protected void DrawSearchBar()
        {
            /** Dynamic controls SUCK in .net
            int ndx = searchTypeDropDown.Items.Count;
            foreach (Brand brand in Brand.GetAll())
            {
                if (!String.IsNullOrEmpty(brand.PersonFilter))
                {
                    searchTypeDropDown.Items.Insert(ndx, new ListItem(HttpUtility.HtmlDecode("&nbsp;&nbsp;&nbsp;") + brand.PersonFilter + " People", brand.Theme));
                }
                else if (!String.IsNullOrEmpty(brand.InstitutionAbbreviation))
                {
                    searchTypeDropDown.Items.Add(new ListItem(HttpUtility.HtmlDecode("&nbsp;&nbsp;&nbsp;") + brand.InstitutionAbbreviation + " People", brand.Theme));
                }
            }
            **********/

            // add Title to the dropdownlist items
            foreach (ListItem item in searchTypeDropDown.Items)
            {
                item.Attributes.Add("Title", item.Text.Trim());
            }

            // pick one to select
            ListItem selected = null;
            if (!String.IsNullOrEmpty(Request.Params["classgroupuri"]))
            {
                selected = searchTypeDropDown.Items.FindByValue(Request.Params["classgroupuri"]);
            }
            else if (!Request.Path.ToLower().Contains("/search/") || Request.QueryString["searchtype"] != null || Request.Form["searchtype"] != null) //if (!Request.Path.ToLower().Contains("/search/"))
            {
                selected = searchTypeDropDown.Items.FindByValue(Brand.GetCurrentBrand().Theme);
            }

            if (selected != null)
            {
                searchTypeDropDown.SelectedIndex = searchTypeDropDown.Items.IndexOf(selected);
            }
        }


        protected void ProcessSearch()
        {
            string searchTypeDropDownValue = this.searchTypeDropDown.SelectedItem.Value;
            string searchType = "everything";
            string classGroupURI = "";
            string institution = "";
            string otherFilters = "";
            string searchFor = Request.Form["mainMenuSearchFor"];

            Brand brand = Brand.GetByTheme(searchTypeDropDownValue);
            if (brand != null)
            {
                searchType = "people";

                if (!brand.IsMultiInstitutional())
                {
                    institution = brand.GetInstitution().GetURI();
                }
                else if (brand.PersonFilter != null)
                {
                    otherFilters = brand.PersonFilter;
                }
            }
            else if ("People".Equals(searchTypeDropDownValue))
            {
                searchType = "people";
            }
            else if (searchTypeDropDownValue.StartsWith("http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroup"))
            {
                classGroupURI = searchTypeDropDownValue;
            }

            Response.Redirect(Brand.GetThemedDomain() + "/search/default.aspx?searchtype=" + searchType +
                                "&searchfor=" + HttpUtility.UrlEncode(searchFor) +
                                "&classgroupuri=" + HttpUtility.UrlEncode(classGroupURI) +
                                "&institution=" + HttpUtility.UrlEncode(institution) +
                                "&otherfilters=" + HttpUtility.UrlEncode(otherFilters) +
                                "&exactphrase=false", false);
            HttpContext.Current.ApplicationInstance.CompleteRequest(); 
        }

        protected void Submit_Click(object sender, EventArgs e)
        {
            ProcessSearch();
    }
}