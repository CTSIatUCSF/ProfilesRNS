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
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Xsl;
using System.Configuration;

using Profiles.Profile.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.Framework.Modules.MainMenu
{
    public partial class MainMenu : BaseModule
    {

        protected void Page_Init(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                DrawProfilesModule();
            }
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

            if (Request.QueryString["subject"] != null)
                subject = Convert.ToInt64(Request.QueryString["subject"]);

            Utilities.DataIO data = new Profiles.Framework.Utilities.DataIO();
            menulist.Append("<ul>");

            menulist.Append("<li><a href='" + Brand.GetDomain() + "/search'>Find People</a></li>");
            menulist.Append("<li><a href='" + Brand.GetDomain() + "/search/all'>Find Everything</a></li>");

            //-50 is the profiles Admin
            if (data.GetSessionSecurityGroup() == -50)
                menulist.Append("<li><a href='" + Brand.GetDomain() + "/SPARQL/default.aspx'>SPARQL Query</a></li>");

            menulist.Append("<li><a href='" + Brand.GetDomain() + "/about/default.aspx'>About This Site</a></li>");

            Brand userBrand = Brand.GetCurrentBrand();
            // logged in Person
            if (sm.Session().NodeID > 0)
            {
                userBrand = Brand.GetForSubject(sm.Session().NodeID);
                menulist.Append("<li><img src='" + userBrand.BasePath + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=" + sm.Session().NodeID + "&Thumbnail=True&Width=20' width='20' height='40'></li>");
                menulist.Append("<li><a href='" + UCSFIDSet.ByNodeId[sm.Session().NodeID].PrettyURL + "'>" + sm.Session().ShortDisplayName + "</a></li>");
            }
            else if (!String.IsNullOrEmpty(sm.Session().ShortDisplayName)) // logged in person
            {
                menulist.Append("<li>" + sm.Session().ShortDisplayName + "</li>");
            }
            else if (!String.IsNullOrEmpty(Request.Headers.Get(ConfigurationManager.AppSettings["Shibboleth.UserNameHeader"].ToString())))
            {
                // they are logged into shibboleth but not profiles. Redirect them through shibboleth
                DebugLogging.Log("Redirecting user logged into Shibboleth but not profiles :" + Request.Headers.Get(ConfigurationManager.AppSettings["Shibboleth.UserNameHeader"].ToString()));
                Response.Redirect(Brand.GetDomain() + "/login/default.aspx?method=shibboleth&redirectto=" + Brand.GetDomain() + Root.AbsolutePath, false);
            }
            
            if (sm.Session().NodeID > 0)
            {
                menulist.Append("<li><a href='" + userBrand.BasePath + "/login/default.aspx?method=login&edit=true'>Edit My Profile</a></li>");
            }


            if (base.MasterPage.CanEdit)
            {
                menulist.Append("<li><a href='" + userBrand.BasePath + "/edit/" + subject.ToString() + "'>Edit This Profile</a></li>");
            }


            // ORNG 
            if (sm.Session().NodeID > 0)
            {
                menulist.Append("<li><a href='" + userBrand.BasePath + "/ORNG/Dashboard.aspx?owner=" + sm.Session().PersonURI + "'>See My Dashboard</a></li>");
            }

            if (sm.Session().NodeID > 0)
            {
                menulist.Append("<li><a href='" + userBrand.BasePath + "/proxy/default.aspx?subject=" + sm.Session().NodeID.ToString() + "'>Manage Proxies</a></li>");
            }

            if (base.BaseData.SelectSingleNode(".").OuterXml != string.Empty && !Root.AbsolutePath.ToLower().Contains("/search"))
            {
                if (base.BaseData.SelectSingleNode("//rdf:RDF/rdf:Description/@rdf:about", base.Namespaces) != null && !Root.AbsolutePath.ToLower().Contains("proxy"))
                {
                    string uri = this.BaseData.SelectSingleNode("//rdf:RDF/rdf:Description/@rdf:about", base.Namespaces).Value;

                    //IF the URI is in our system then we build the link. If not then we do not build the link for the data.
                    if (uri.Contains(Brand.GetDomain()))
                    {
                        string file = string.Empty;
                        string spostring = string.Empty;
                        string[] spoarray;

                        spostring = uri.ToLower().Replace(Brand.GetDomain().ToLower() + "/profile/", "");
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
                        }

                    }
                }
            }


            if (sm.Session().UserID == 0 && String.IsNullOrEmpty(sm.Session().ShortDisplayName))
            {
                if (!Root.AbsolutePath.Contains("login"))
                {
                    menulist.Append("<li><a href='" + Brand.GetDomain() + "/login/default.aspx?pin=send&method=login&redirectto=" + Brand.GetDomain() + Root.AbsolutePath + "'>Login to Profiles</a></li>");
                }
            }
            else
            {
                menulist.Append("<li><a href='" + Brand.GetDomain() + "/login/default.aspx?method=logout&redirectto=" + Brand.GetDomain() + "/About/CloseBrowser.aspx" + "'>Sign out</a></li>");
            }

            menulist.Append("</ul>");

            // hide active networks DIV if not logged in
            /** UCSF
            if (sm.Session().UserID > 0)
            {
                ActiveNetworkRelationshipTypes.Visible = true;
            }
            else
            {
                ActiveNetworkRelationshipTypes.Visible = false;
            }
             **/

            UserHistory uh = new UserHistory();

            ProfileHistory.RDFData = base.BaseData;
            ProfileHistory.PresentationXML = base.MasterPage.PresentationXML;
            ProfileHistory.Namespaces = base.Namespaces;


            if (uh.GetItems() != null)
            {
                ProfileHistory.Visible = true;
            }
            else
            {
                ProfileHistory.Visible = false;
            }



            panelMenu.InnerHtml = menulist.ToString();
            DrawSearchBar();
        }


        // For megasearch items
        public string GetURLDomain()
        {
            return Brand.GetDomain();
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
            string theme = Brand.GetSystemTheme(); 

            Brand brand = Brand.GetByTheme(searchTypeDropDownValue);
            if (brand != null)
            {
                searchType = "people";

                if (!brand.IsMultiInstitutional())
                {
                    Profiles.Search.Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();
                    institution = data.GetConvertedListItem(data.GetInstitutions(), brand.InstitutionName);
                    theme = brand.Theme;
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

            Response.Redirect(Brand.GetDomain() + "/search/default.aspx?searchtype=" + searchType +
                                "&searchfor=" + HttpUtility.UrlEncode(searchFor) +
                                "&classgroupuri=" + HttpUtility.UrlEncode(classGroupURI) +
                                "&institution=" + HttpUtility.UrlEncode(institution) +
                                "&otherfilters=" + HttpUtility.UrlEncode(otherFilters) +
                                "&Theme=" + theme + 
                                "&exactphrase=false", false);
            HttpContext.Current.ApplicationInstance.CompleteRequest(); 
        }

        protected void Submit_Click(object sender, EventArgs e)
        {
            ProcessSearch();
        }

    }
}