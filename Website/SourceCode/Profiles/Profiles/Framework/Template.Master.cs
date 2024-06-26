﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using Profiles.Framework.Utilities;
using System.Configuration;
using System.ComponentModel;

namespace Profiles.Framework
{
    public partial class Template : System.Web.UI.MasterPage
    {

        public static readonly string VERSION_CACHE_KEY = "GitVersion";

        #region "Private Properties"

        private XmlDocument _presentationxml;
        private List<Framework.Utilities.Panel> _panels;
        private ModulesProcessing mp;

        private static Dictionary<String, String> googleVerifications = new Dictionary<string, string>();

        static Template()
        {
            googleVerifications.Add("UCSD", "p5OaN7GUMQcNoavqEkMHqFPRAWZcgI_SUvQhqXBP1u0");
            googleVerifications.Add("UCI", "AxJdyUfTWrJIZm5l8ag4WIyqjxhgN6x0oYXbHoPsig4");
            googleVerifications.Add("UCLA", "2rqsXhjXl5IXtjJ7cHh6E0q5S1_hQg4wvTRYw0YKA6I");
            googleVerifications.Add("UCD", "o-FxPIvxLIPd8ztO7wddaleF3PWjp7aYWTDE5rfViZg");
            googleVerifications.Add("USC", "HGTrtQw_hu2M8AF4aDTUW6c-cqUIQ9Gz6zuS_39z1UM");
            googleVerifications.Add("UCSF", "JXe923j97sTSgp-6yxsCdd25Muv0wMNfDR27ba3ER8M");
        }

        #endregion
        override protected void OnInit(EventArgs e)
        {

        }
        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                toolkitScriptMaster.AsyncPostBackTimeout = 3600;

                if (this.RDFData == null) { this.RDFData = new XmlDocument(); }
                if (this.RDFNamespaces == null) { this.RDFNamespaces = new XmlNamespaceManager(this.RDFData.NameTable); }
/*
                if (this.GetStringFromPresentationXML("Presentation/PageOptions/@CanEdit") == "true")
                    this.CanEdit = true;
                else
                    this.CanEdit = false;
*/
                this.LoadAssets();

                this.InitFrameworkPanels();

                this.BindRepeaterToPanel(ref rptHeader, GetPanelByType("header"));
                this.BindRepeaterToPanel(ref rptActive, GetPanelByType("active"));
                this.BindRepeaterToPanel(ref rptMain, GetPanelByType("main"));
                this.BindRepeaterToPanel(ref rptPassive, GetPanelByType("passive"));

                if (rptHeader.Items.Count == 0)
                {
                    divProfilesHeader.Visible = false;
                }

                this.DrawTabs();
                if (this.GetStringFromPresentationXML("Presentation/PanelList/Panel[@Type='left']") != string.Empty)
                {
                    this.BindRepeaterToPanel(ref rptLeft, GetPanelByType("left"));
                }
                else
                {
                    divContentLeft.Visible = false;
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ master page  protected void Page_Load(object sender, EventArgs e) " + ex.StackTrace);

                HttpContext.Current.Session["GLOBAL_ERROR"] = ex.Message + " ++ " + ex.StackTrace;
                Response.Redirect(Brand.GetThemedDomain() + "/error/default.aspx");
                Response.End();
            }
        }



        /// <summary>
        /// Used to set the link for css/js client Assets
        /// </summary>
        protected void LoadAssets()
        {
            // Moved up per Anirvans request
            HtmlLink PRNStheme = new HtmlLink();
            PRNStheme.Href = Brand.GetThemedDomain() + "/framework/css/prns-theme.css";
            PRNStheme.Attributes["rel"] = "stylesheet";
            PRNStheme.Attributes["type"] = "text/css";
            PRNStheme.Attributes["media"] = "all";
            head.Controls.Add(PRNStheme);


            HtmlLink PRNSthemeMenusTop = new HtmlLink();
            PRNSthemeMenusTop.Href = Brand.GetThemedDomain() + "/framework/css/prns-theme-menus-top.css";
            PRNSthemeMenusTop.Attributes["rel"] = "stylesheet";
            PRNSthemeMenusTop.Attributes["type"] = "text/css";
            PRNSthemeMenusTop.Attributes["media"] = "all";
            head.Controls.Add(PRNSthemeMenusTop);
            
            // UCSF Added Themes START
            HtmlLink Profilescss = new HtmlLink();
            Profilescss.Href = Brand.GetThemedDomain() + "/Framework/CSS/profiles.css";
            Profilescss.Attributes["rel"] = "stylesheet";
            Profilescss.Attributes["type"] = "text/css";
            Profilescss.Attributes["media"] = "all";
            //Page.Header.Controls.Add(Profilescss);
            head.Controls.Add(Profilescss);

            HtmlGenericControl jsscript = new HtmlGenericControl("script");
            jsscript.Attributes.Add("type", "text/javascript");
            jsscript.Attributes.Add("src", Brand.GetThemedDomain() + "/Framework/JavaScript/profiles.js");
            Page.Header.Controls.Add(jsscript);

            HtmlLink DEFAULTcss = new HtmlLink();
            DEFAULTcss.Href = Brand.GetThemedDomain() + "/App_Themes/DEFAULT.css";
            DEFAULTcss.Attributes["rel"] = "stylesheet";
            DEFAULTcss.Attributes["type"] = "text/css";
            DEFAULTcss.Attributes["media"] = "all";
            //Page.Header.Controls.Add(DEFAULTcss); 
            head.Controls.Add(DEFAULTcss);

            HtmlGenericControl UCSFjs = new HtmlGenericControl("script");
            UCSFjs.Attributes.Add("type", "text/javascript");
            UCSFjs.Attributes.Add("src", Brand.GetThemedDomain() + "/Framework/JavaScript/UCSF.js");
            Page.Header.Controls.Add(UCSFjs);

            // add one specific to the theme
            HtmlGenericControl ThemeJs = new HtmlGenericControl("script");
            ThemeJs.Attributes.Add("type", "text/javascript");
            ThemeJs.Attributes.Add("src", Brand.GetThemedDomain() + "/App_Themes/" + Page.Theme + "/" + Page.Theme + ".js");
            Page.Header.Controls.Add(ThemeJs);

            // UCSF. More themese testing stuff
            HtmlLink ThemeCss = new HtmlLink();
            //ThemeCss.Href = Root.GetThemedFile(Page, "Search/CSS/Theme.css");
            ThemeCss.Href = Brand.GetThemedDomain() + "/App_Themes/" + Page.Theme + "/" + Page.Theme + ".css";
            ThemeCss.Attributes["rel"] = "stylesheet";
            ThemeCss.Attributes["type"] = "text/css";
            ThemeCss.Attributes["media"] = "all";
            Page.Header.Controls.Add(ThemeCss);

            if (!String.IsNullOrEmpty(Brand.GetCelebrating()))
            {
                // Sort of odd that this is generic and the other section isn't, but oh well
                Control celebratingHeaderPanel = Page.Master.FindControl("Celebrating" + Brand.GetCelebrating());
                if (celebratingHeaderPanel != null)
                {
                    // no need to show on the search page
                    celebratingHeaderPanel.Visible = !Request.Path.ToLower().Contains("/search/");
                }
                CelebratingBanner.Visible = Request.Path.ToLower().Contains("/search/");

                if (CelebratingBanner.Visible)
                {
                    HtmlGenericControl FeaturedJs = new HtmlGenericControl("script");
                    FeaturedJs.Attributes.Add("type", "text/javascript");
                    FeaturedJs.Attributes.Add("src", Brand.GetThemedDomain() + "/App_Themes/" + Page.Theme + "/FEATURED.js");
                    Page.Header.Controls.Add(FeaturedJs);

                    List<UCSFFeaturedPeople> people = UCSFFeaturedPeople.GetGroupMembersForBanner(Brand.GetCelebrating(), Int32.Parse(hdnCelebratingNumberOfImages.Value));
                    string bannerImages = "";
                    foreach (UCSFFeaturedPeople person in people)
                    {
                        bannerImages += "<img src=\"" + Brand.GetThemedDomain() + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=" +
                            person.nodeId + "&Thumbnail=True \" alt=\"Photo of " + person.firstName + " " + person.lastName + "\">\r\n";
                    }
                    litCelebratingBannerPhotos.Text = bannerImages;
                }
            }

            // UCSF. To support lazy login
            String lazyShibLogin = Profiles.Login.ShibbolethSession.GetJavascriptSrc(Request);
            if (!String.IsNullOrEmpty(lazyShibLogin))
            {
                Framework.Utilities.DebugLogging.Log("lazyShibLogin :" + lazyShibLogin);
                HtmlGenericControl multiShibLogin = new HtmlGenericControl("script");
                multiShibLogin.Attributes.Add("type", "text/javascript");
                multiShibLogin.Attributes.Add("src", lazyShibLogin);
                Page.Header.Controls.Add(multiShibLogin);
            }

            // UCSF. These are handy to have in JavaScript form and are required for ORNG
            HtmlGenericControl inlineJs = new HtmlGenericControl("script");
            inlineJs.Attributes.Add("type", "text/javascript");
            inlineJs.InnerHtml = Environment.NewLine + "var _rootDomain = \"" + Brand.GetThemedDomain() + "\";" + Environment.NewLine;
            try
            {
                inlineJs.InnerHtml += "var _isGroup = " +
                    (!String.IsNullOrEmpty(this.RDFData.InnerText) && this.RDFData.SelectSingleNode("rdf:RDF/rdf:Description[1]/rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Group']", this.RDFNamespaces) != null).ToString().ToLower()
                    + ";" + Environment.NewLine;
            }
            catch (Exception ex)
            {
                inlineJs.InnerHtml = Environment.NewLine + "var _isGroup = \"false\";" + Environment.NewLine;
            }
            Page.Header.Controls.Add(inlineJs);

            //The below statement was adding inline styles to the left side navigation. Not needed anymore.
            //if (this.GetStringFromPresentationXML("Presentation/PageOptions/@Columns") == "3")
            //{
            //    divPageColumnRightCenter.Style["background-image"] = Brand.GetDomain() + "/Framework/Images/passive_back.gif";
            //    divPageColumnRightCenter.Style["background-repeat"] = "repeat";
            //}

            if (googleVerifications.ContainsKey(Page.Theme))
            {
                HtmlMeta meta = new HtmlMeta();
                meta.Name = "google-site-verification";
                meta.Content = googleVerifications[Page.Theme];
                Page.Header.Controls.Add(meta);
            }

            if (Brand.GetGATrackingID() != null)
            {
                HtmlGenericControl gaTrackingjs = new HtmlGenericControl("script");
                // UCSF Maybe it is OK to have this other stuff be site wide in Godzilla? NULL is certainly OK
                string domain = ConfigurationManager.AppSettings["GoogleAnalytics.Domain"] != null ? ConfigurationManager.AppSettings["GoogleAnalytics.Domain"].ToString().Trim() : null;
                string trackingID2 = ConfigurationManager.AppSettings["GoogleAnalytics.TrackingID2"] != null ? ConfigurationManager.AppSettings["GoogleAnalytics.TrackingID2"].ToString().Trim() : null;
                string domain2 = ConfigurationManager.AppSettings["GoogleAnalytics.Domain2"] != null ? ConfigurationManager.AppSettings["GoogleAnalytics.Domain2"].ToString().Trim() : null;

                gaTrackingjs.Attributes.Add("type", "text/javascript");
                gaTrackingjs.InnerHtml = GetUniversalAnalyticsJavascipt(Brand.GetGATrackingID(), domain, trackingID2, domain2);
                Page.Header.Controls.Add(gaTrackingjs);

                // adding Siteimprove to the page 
                if (Brand.GetThemeName().IndexOf("UC") > -1)
                {
                    HtmlGenericControl siTrackingjs = new HtmlGenericControl("script");
                    siTrackingjs.Attributes.Add("type", "text/javascript");
                    siTrackingjs.InnerHtml = "\r\n(function() {" + Environment.NewLine +
                        "var sz = document.createElement('script'); sz.type = 'text/javascript'; sz.async = true;" + Environment.NewLine +
                        "sz.src = '//siteimproveanalytics.com/js/siteanalyze_8343.js';" + Environment.NewLine +
                        "var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(sz, s);})();\r\n";
                    Page.Header.Controls.Add(siTrackingjs);
                }
            }


            // IE Only css files
            Literal ieCss = new Literal();
            ieCss.Text = String.Format(@"
				<!--[if IE]>
					<link rel='stylesheet' type='text/css' href='{0}/Framework/CSS/profiles-ie.css' />
				<![endif]-->
			",
            Brand.GetThemedDomain());
            Page.Header.Controls.Add(ieCss);

            // UCSF Added Themes END

            //This should loop the application table or be set based on the contest of the RESTFul URL to know
            //What application is currently being viewed then set the correct asset link.

            /*** UCSF Collision
            HtmlLink Profilescss = new HtmlLink();
            Profilescss.Href = Brand.GetThemedDomain() + "/framework/css/profiles.css";
            Profilescss.Attributes["rel"] = "stylesheet";
            Profilescss.Attributes["type"] = "text/css";
            Profilescss.Attributes["media"] = "all";
            head.Controls.Add(Profilescss);


            HtmlGenericControl jsscript = new HtmlGenericControl("script");
            jsscript.Attributes.Add("type", "text/javascript");
            jsscript.Attributes.Add("src", Brand.GetThemedDomain() + "/Framework/JavaScript/profiles.js");
            Page.Header.Controls.Add(jsscript);
            ***/



            Framework.Utilities.DataIO data = new DataIO();
/*
            if (data.CheckSystemMessage() != "")
            {
                ProfilesNotification.Visible = true;
                litSystemNotice.Visible = true;
                litSystemNotice.Text = data.CheckSystemMessage();
            }
            else
            {
 */               ProfilesNotification.Visible = false;
                litSystemNotice.Visible = false;
            //           }

            // Unfuddle 452. Turn off FeatuedItems unless we are on the Search page
            Control featuredItems = Page.Master.FindControl("FeaturedItems" + Brand.GetCurrentBrand().Theme);
            if (featuredItems != null) 
            {
                featuredItems.Visible = Request.Path.ToLower().Contains("/search/");
            }
        }


        /// <summary>
        /// Draws the Tabs dispaly based on the presentation xml and the restful URL pattern.
        /// </summary>
        protected void DrawTabs()
        {
            System.Text.StringBuilder tabs = new System.Text.StringBuilder();
            List<Tab> listtabs = new List<Tab>();
            bool currenttab = false;
            foreach (Framework.Utilities.Panel p in _panels)
            {
                if (p.Alias != string.Empty && this.Tab != string.Empty)
                    p.DefaultTab = false;
                else if (p.Alias != string.Empty && p.TabType == "Default" && this.Tab == string.Empty)
                    p.DefaultTab = true;

                if ((p.Alias == this.Tab) || (p.DefaultTab))
                    currenttab = true;
                else
                    currenttab = false;

                if (!p.Alias.IsNullOrEmpty())
                    listtabs.Add(new Tab(p.Name, p.Alias, currenttab, p.DefaultTab));

            }

            if (listtabs.Count > 0)
            {
                bool drawstart = true;

                foreach (Tab t in listtabs)
                {
                    if (t.URL != null)
                    {
                        if (drawstart)
                        {
                            tabs.Append(Framework.Utilities.Tabs.DrawTabsStart());
                            drawstart = false;
                        }

                        if (t.Active)
                        {
                            tabs.Append(Framework.Utilities.Tabs.DrawActiveTab(t.Name));
                        }
                        else if (Root.AbsolutePath.ToLower().Contains("display.aspx"))
                        {
                            string newtab = t.URL;

                            t.URL = Root.AbsolutePath;

                            t.URL = t.URL.ToLower().Replace("/display.aspx", "");

                            if (!HttpContext.Current.Request.QueryString["subject"].IsNullOrEmpty())
                                t.URL += "/" + HttpContext.Current.Request.QueryString["subject"].ToString();

                            if (!HttpContext.Current.Request.QueryString["predicate"].IsNullOrEmpty())
                                t.URL += "/" + HttpContext.Current.Request.QueryString["predicate"].ToString();

                            if (!HttpContext.Current.Request.QueryString["object"].IsNullOrEmpty())
                                t.URL += "/" + HttpContext.Current.Request.QueryString["object"].ToString();


                            if (this.Tab != string.Empty)
                            {
                                t.URL = Brand.GetThemedDomain() + t.URL + "/" + newtab;
                            }
                            else
                            {
                                t.URL = Brand.GetThemedDomain() + t.URL;
                            }


                            tabs.Append(Framework.Utilities.Tabs.DrawDisabledTab(t.Name, t.URL));

                        }
                        else
                        {
                            //Then its a disabled tab
                            if (this.Tab != string.Empty)
                            {
                                string[] url = Root.AbsolutePath.Split('/');
                                string buffer = string.Empty;

                                if (url.Length == 2)
                                {

                                    t.URL = Brand.GetThemedDomain() + Root.AbsolutePath + "/" + t.URL;
                                }
                                else
                                {
                                    for (int i = 0; i < url.Length - 1; i++)
                                        buffer = buffer + url[i] + "/";

                                    t.URL = Brand.GetThemedDomain() + buffer + t.URL;
                                }

                            }
                            else
                            {

                                t.URL = Brand.GetThemedDomain() + Root.AbsolutePath + "/" + t.URL;
                            }

                            tabs.Append(Framework.Utilities.Tabs.DrawDisabledTab(t.Name, t.URL));
                        }
                    }
                }

                if (!drawstart)
                    tabs.Append(Framework.Utilities.Tabs.DrawTabsEnd());

                litTabs.Text = tabs.ToString();
            }
            else
            {
                litTabs.Visible = false;
                litJS.Text += "$(document).ready(function () {$('.prns-screen-search').remove();});";
            }
        }

        /// <summary>
        /// Each repeater on the master page will fire this event when its bound with presentation xml data.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void DrawModule(object sender, RepeaterItemEventArgs e)
        {
            PlaceHolder placeholder = null;
            mp = new ModulesProcessing();
            Literal literal = null;

            if (e.Item.ItemType == ListItemType.Header)
            {
                literal = (Literal)e.Item.FindControl("litHeader");
                return;
            }
            if (e.Item.ItemType == ListItemType.Footer)
            {
                literal = (Literal)e.Item.FindControl("litFooter");
                return;
            }

            Utilities.Module module = (Utilities.Module)e.Item.DataItem;
            bool display = true;

            if (module == null) { return; }

            placeholder = (PlaceHolder)e.Item.FindControl("phHeader");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phActive");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phLeft");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phMain");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phPage");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phPassive");


            if (module.Path != "")
            {
                if (module.DisplayRule != string.Empty)
                    if (this.RDFData.SelectSingleNode(module.DisplayRule, this.RDFNamespaces).InnerText != "")
                    {
                        display = false;
                    }
                if (display == true)
                    placeholder.Controls.Add(mp.LoadControl(module.Path, this, this.RDFData, module.ParamList, this.RDFNamespaces));
            }


            display = true;
        }
        protected string GetStringFromPresentationXML(string XPath)
        {
            string buffer = string.Empty;

            XmlNode MyXMLNode = this.PresentationXML.SelectSingleNode(XPath);

            if (MyXMLNode != null)
            {
                buffer = CustomParse.Parse(MyXMLNode.InnerText, this.RDFData, this.RDFNamespaces);
            }

            return buffer.Trim();
        }

        protected void ProcessPresentationXML()
        {

            string js = string.Empty;
            string buffer = string.Empty;
            SessionManagement sm = new SessionManagement();

            // PageTitle
            buffer = GetStringFromPresentationXML("Presentation/PageTitle");
            if (buffer != String.Empty)
                litPageTitle.Text = " <div class=\"pageTitle\"><h2 style='margin-bottom:0px;'>" + buffer + "</h2></div>";
            else
            {
                divTopMainRow.Visible = false;
                litPageTitle.Visible = false;
                js += "$(document).ready(function () {$('#divTopMainRow').remove();});";
            }

            // PageSubTitle
            buffer = GetStringFromPresentationXML("Presentation/PageSubTitle");
            if (buffer != String.Empty)
                litPageSubTitle.Text = "<div class=\"pageSubTitle\"><h2 style=\"margin-bottom:0px;margin-top:0px;font-weight:bold\">" + buffer + "</h2></div>";
            else
            {
                litPageSubTitle.Visible = false;
                js += "$(document).ready(function () {jQuery('.pageSubTitle').remove();});";
            }

            // PageDescription
            buffer = GetStringFromPresentationXML("Presentation/PageDescription");
            if (buffer != String.Empty)
                litPageDescription.Text = buffer;
            else
            {
                litPageDescription.Visible = false;
                js += "$(document).ready(function () {$('.pageDescription').remove();});";
            }

            // PageBackLink
            string PageBackLinkURL = GetStringFromPresentationXML("Presentation/PageBackLinkURL");
            string PageBackLinkName = GetStringFromPresentationXML("Presentation/PageBackLinkName");
            if ((PageBackLinkURL != String.Empty) & (PageBackLinkName != String.Empty))
            {
                string url = string.Empty;

                if (PageBackLinkURL.Contains("~/"))
                    url = Brand.GetThemedDomain() + "/" + PageBackLinkURL.Replace("~/", "");
                else if (PageBackLinkURL.Contains("~"))
                    url = Brand.GetThemedDomain() + PageBackLinkURL.Replace("~", "");
                else
                    url = PageBackLinkURL;

                litBackLink.Text = "<a class='masterpage-backlink' href=\"" + url + "\"><img src=\"" + Brand.GetThemedDomain() + "/Framework/Images/arrowLeft.png\" class=\"pageBackLinkIcon\" alt=\"\" />" + PageBackLinkName + "</a>";
            }
            else
            {
                js += "$(document).ready(function () {$('.backLink').remove();});";
            }

            // Window Title
            buffer = GetStringFromPresentationXML("Presentation/WindowName");

            //Page.Header.Title = buffer + " | Profiles RNS";
            bool isperson = false;
            try
            {
                isperson = !String.IsNullOrEmpty(HttpContext.Current.Request.QueryString["Subject"]) && UCSFIDSet.IsPerson(Convert.ToInt64(Request.QueryString["Subject"].Trim()));
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ master page seeing if on person page " + ex.StackTrace);
            }
            //Unfuddle #375
            string brandPrefix = "UCD".Equals(Brand.GetCurrentBrand().Theme) ? "UC Davis" : Brand.GetCurrentBrand().Theme;
            if (isperson)
            {   //Person
                Page.Header.Title = buffer + " | " + brandPrefix + " Profiles";
            }
            else
            {
                Page.Header.Title = brandPrefix + " Profiles • " + buffer;
            }
            litJS.Text += js;

        }

        #region "Panel Methods"

        private void InitFrameworkPanels()
        {
            XmlNodeList panels = this.PresentationXML.GetElementsByTagName("Panel");
            bool display = true;

            if (_panels == null) { _panels = new List<Framework.Utilities.Panel>(); }

            for (int i = 0; i < panels.Count; i++)
            {
                if (panels[i].SelectSingleNode("@DisplayRule") != null)
                {
                    if (panels[i].SelectSingleNode("@DisplayRule").Value != string.Empty)
                    {
                        if (this.RDFData.SelectSingleNode(panels[i].SelectSingleNode("@DisplayRule").Value, this.RDFNamespaces) != null)
                            if (this.RDFData.SelectSingleNode(panels[i].SelectSingleNode("@DisplayRule").Value, this.RDFNamespaces).InnerText == string.Empty)
                            { display = false; }
                    }
                }

                if (display)
                {



                    _panels.Add(new Framework.Utilities.Panel(panels[i]));


                }

                //reset the default to true.  All Panels will display by default unless a DisplayRule is supplied and that rule fails the test to see
                //if data exists for its display
                display = true;
            }
        }

        private List<Framework.Utilities.Panel> GetPanelByType(string paneltype)
        {
            List<Framework.Utilities.Panel> rtnpanel = null;

            try
            {
                //Query the list of panels for the current panel type
                var p = (from panel in _panels
                         where (panel.Type == paneltype)
                         select panel).OrderBy(a => a.TabSort);

                rtnpanel = p.ToList();

            }
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log(ex.Message + " ++  private List<Framework.Utilities.Panel> GetPanelByType(string paneltype) " + ex.StackTrace); }

            return rtnpanel;
        }

        /// <summary>
        /// Used to bind a repeater for a given Panel to a List of Modules.  Each panel is defined by a type.  Each type can be assigned
        /// one or more modules. 
        /// </summary>
        /// <param name="repeater">A repeater control is passed by ref to this method.</param>
        /// <param name="paneltype">The type of the Panel as defined in the PresentationXML //Panel/@Type attribute</param>
        public void BindRepeaterToPanel(ref Repeater repeater, List<Framework.Utilities.Panel> panels)
        {

            Framework.Utilities.Panel rtnpanel = new Profiles.Framework.Utilities.Panel();
            try
            {
                if (panels.Count() == 1)
                {
                    foreach (Framework.Utilities.Panel f in panels)
                        rtnpanel.Modules = f.Modules;
                }
                else
                {
                    rtnpanel.Modules = new List<Utilities.Module>();
                    foreach (Framework.Utilities.Panel f in panels)
                    {
                        if (f.Alias != string.Empty && this.Tab != string.Empty)
                            f.DefaultTab = false;
                        else if (f.Alias != string.Empty && f.TabType == "Default" && this.Tab == string.Empty)
                            f.DefaultTab = true;

                        if ((f.Alias == this.Tab) || (f.DefaultTab))
                        {
                            foreach (Utilities.Module m in f.Modules)
                                rtnpanel.Modules.Add(m);
                        }
                    }
                }
            }
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log(ex.Message + " ++ at public void BindRepeaterToPanel(ref Repeater repeater, List<Framework.Utilities.Panel> panels) " + ex.StackTrace); }

            repeater.DataSource = rtnpanel.Modules;
            repeater.DataBind();

        }

        #endregion

        public string GetURLDomain()
        {
            return Brand.GetThemedDomain();
        }

        public string GetBrandedSearchTerm()
        {

            if (!String.IsNullOrEmpty(Brand.GetCurrentBrand().PersonFilter))
            {
                return "otherfilters=" + Brand.GetCurrentBrand().PersonFilter;
            }
            else if (!Brand.GetCurrentBrand().IsMultiInstitutional())
            {
                return "institution=" + Brand.GetCurrentBrand().GetInstitution().GetURI();
            }
            return "";
        }

        #region "Public Properties"
        public XmlDocument PresentationXML
        {
            get { return _presentationxml; }
            set
            {
                string buffer = value.InnerXml;

                //clean out the junk from the text editor people use.
                buffer = buffer.Replace("\t", "");
                buffer = buffer.Replace("\n", "");
                buffer = buffer.Replace("\r", "");

                if (_presentationxml == null)
                    _presentationxml = new XmlDocument();

                _presentationxml.LoadXml(buffer);

                this.ProcessPresentationXML();

            }
        }
        public XmlDocument RDFData { get; set; }
        public XmlNamespaceManager RDFNamespaces { get; set; }
        public string SearchRequest { get; set; }

        public string Tab { get; set; }
        public string SessionID { get; set; }
        public Boolean CanEdit { get; set; }

        #endregion

        #region "Themed Items"

        private string GetUniversalAnalyticsJavascipt(string trackingID, string domain, string trackingID2, string domain2)
        {
            domain = (domain == null) ? "auto" : domain;
            domain2 = (domain2 == null) ? "auto" : domain2;
            string createID2 = (trackingID2 != null) ? "ga('create', '" + trackingID2 + "', '" + domain2 + "', { 'name': 'b' });" + Environment.NewLine : "";
            string sendID2 = (trackingID2 != null) ? "ga('b.send', 'pageview')" : "";

            string scriptText = Environment.NewLine +
                "(function (i, s, o, g, r, a, m) {" + Environment.NewLine +
                "i['GoogleAnalyticsObject'] = r; i[r] = i[r] || function () {" + Environment.NewLine +
                "(i[r].q = i[r].q || []).push(arguments)" + Environment.NewLine +
                "}, i[r].l = 1 * new Date(); a = s.createElement(o)," + Environment.NewLine +
                "m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m)" + Environment.NewLine +
                "})(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');" + Environment.NewLine +
                "ga('create', '" + trackingID + "', '" + domain + "');" + Environment.NewLine +
                createID2 +
                "ga('send', 'pageview');" + Environment.NewLine +
                sendID2;
            return scriptText;
        }

        public string GetThemedDomain()
        {
            return Brand.GetThemedDomain();
        }

        public string GetVersion()
        {
            string version = (string)Framework.Utilities.Cache.FetchObject(VERSION_CACHE_KEY);
            if (version == null)
            {
                string contents = System.IO.File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "/GitVersion.txt");
                string[] contentsLines = contents.Split((char[])null, StringSplitOptions.RemoveEmptyEntries);
                version = contentsLines[contentsLines.Length - 1];
                Framework.Utilities.Cache.SetWithTimeout(VERSION_CACHE_KEY, version, 604800); // Cache for 7 days
            }
            return version;
        }

        public string GetThemedFavicon()
        {
            return Brand.GetThemedFile(Page, "Images/favicon.ico");
        }

        #endregion

    }


}

