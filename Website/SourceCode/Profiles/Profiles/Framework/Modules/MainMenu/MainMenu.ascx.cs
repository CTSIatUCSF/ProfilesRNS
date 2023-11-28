
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;

using Profiles.Framework.Utilities;
namespace Profiles.Framework.Modules.MainMenu
{
    public partial class MainMenu : BaseModule
    {

        System.Text.StringBuilder menulist;
        SessionManagement sm;
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
          

        }

        private void DrawProfilesModule()
        {
            Int64 subject = 0;

            HttpContext.Current.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            HttpContext.Current.Response.Cache.SetExpires(DateTime.Now);
            HttpContext.Current.Response.Cache.SetNoServerCaching();
            HttpContext.Current.Response.Cache.SetNoStore();

            if (Request.QueryString["subject"] != null)
                subject = Convert.ToInt64(Request.QueryString["subject"]);

            Brand userBrand = Brand.GetCurrentBrand();

            Utilities.DataIO data = new Profiles.Framework.Utilities.DataIO();

            litSearchOptions.Text = "<li class='first'><a class='search-drop' href='" + Brand.GetThemedDomain() + "/search'>Find People</a></li><li class='last'><a class='search-drop' style='border-bottom:1px solid #383737;' href='" + Brand.GetThemedDomain() + "/search/all'>Find Everything</a></li>";
            litJs.Text = "";
            /*** 
            if (sm.Session().NodeID > 0)
            {
                litViewMyProfile.Text = "<li><a href='" + sm.Session().PersonURI + "'>View My Profile</a></li>";
            }**/
            // logged in Person
            if (UCSFIDSet.IsPerson(sm.Session().NodeID))
            {
                userBrand = Brand.GetForSubject(sm.Session().NodeID);
                litViewMyProfile.Text = "<li id='myprofile'><a href='" + UCSFIDSet.ByNodeId[sm.Session().NodeID].PrettyURL
                    + "'><div id='menuthumb'><img src='" + userBrand.BasePath + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID="
                    + sm.Session().NodeID + "&Thumbnail=True&Width=20' width='20' alt=''></div>"
                    + sm.Session().DisplayName + "</a></li>";
            }
            else if (!String.IsNullOrEmpty(sm.Session().DisplayName)) // logged in person
            {
                litViewMyProfile.Text = "<li>" + sm.Session().DisplayName + "</li>";
            }


            litEditThisProfile.Text = "<li><a href='" + Brand.GetThemedDomain() + "/login/default.aspx?pin=send&method=login&edit=true'>Edit My Profile</a></li>";

            if (base.MasterPage.CanEdit)
                litEditThisProfile.Text += "<li><div class=\"divider\"></div></li><li><a href='" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + subject.ToString() + "'>Edit This Profile</a></li>";

            if (sm.Session().UserID > 0)
            {
                // litProxy.Text = "<li>Manage Proxies</li>"; This line of code makes on sense. Ask Nick about this.
                litProxy.Text = "<li><a href='" + Brand.GetThemedDomain() + "/proxy/default.aspx?subject=" + sm.Session().NodeID.ToString() + "'>Manage Proxies</a></li>";
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

                    //litExportRDF.Text = "<li ><a style='border-bottom:1px solid #383737;border-left:1px solid #383737;border-right:1px solid  #383737;width:200px !important' href=\"" + uri + "/" + file + ".rdf\" target=\"_blank\">" + "Export This Page as RDF" + "</a></li>";

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

            /**** Turned off by UCSF for now  
             * Back ON in DEV **/
            if (sm.Session().UserID > 0)
            {
                if (data.IsGroupAdmin(sm.Session().UserID))
                {
                    litGroups.Text = "<li><a href='" + Brand.GetThemedDomain() + "/groupAdmin/default.aspx'>Manage Groups</a></li>";
                    groupListDivider.Visible = true;
                }
            }

            string loginclass = string.Empty;
            if (sm.Session().UserID == 0)
            {
                if (!Root.AbsolutePath.Contains("login") && !System.Configuration.ConfigurationManager.AppSettings["Login.PresentationXML"].ToString().Trim().Equals("DisabledLoginPresentation"))
                {
                    litLogin.Text = "<a href='" + Brand.GetThemedDomain() + "/login/default.aspx?method=login&redirectto=" + Brand.GetThemedDomain() + Root.AbsolutePath + "'>Login</a> to edit your profile (add a photo, awards, links to other websites, etc.)";
                }
                loginclass = "pub";
            }
            else
            {
                litLogOut.Text = "<li><a href='" + Brand.GetThemedDomain() + "/login/default.aspx?method=logout&redirectto=" + Brand.GetThemedDomain() + "/search'>Logout</a></li>";
                loginclass = "user";
            }

            litJs.Text += "<script type='text/javascript'> var NAME = document.getElementById('prns-usrnav'); NAME.className = '" + loginclass + "';";

          
            if (sm.Session().UserID > 0 )
            {                
              
                //Change this to show two drop down items based on the count.
                MyLists.Visible = true;
                if(base.GetModuleParamString("pageType") != null)
                {
                    string pt = base.GetModuleParamString("PageType");
                    if (pt.Equals("Person")) MyLists.pageType = MyLists.pageTypes.Person;
                    else if (pt.Equals("SearchResults")) MyLists.pageType = MyLists.pageTypes.SearchResults;
                }

            }
            else if (sm.Session().UserID == 0)
            {
                MyLists.Visible = false;
                litJs.Text += " $('#navMyLists').remove(); $('#ListDivider').remove();";
            }


            litJs.Text += "</script>";
            UserHistory uh = new UserHistory();

            ProfileHistory.RDFData = base.BaseData;
            ProfileHistory.PresentationXML = base.MasterPage.PresentationXML;
            ProfileHistory.Namespaces = base.Namespaces;
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
            foreach (ListItem item in searchTypeDropDown.Items)
            {
                // default everything search
                item.Attributes.Add("searchtype", "everything");

                Brand brand = Brand.GetByTheme(item.Value);
                if (brand != null)
                {
                    item.Attributes.Add("searchtype", "people");
                    if (!brand.IsMultiInstitutional())
                    {
                        item.Attributes.Add("institution", brand.GetInstitution().GetURI());
                    }
                    else if (brand.PersonFilter != null)
                    {
                        item.Attributes.Add("otherfilters", brand.PersonFilter);
                    }
                }
                else if ("People".Equals(item.Value))
                {
                    item.Attributes.Add("searchtype", "people");
                }
                else if (item.Value.StartsWith("http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroup"))
                {
                    item.Attributes.Add("classgroupuri", item.Value);
                }
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

    }
}