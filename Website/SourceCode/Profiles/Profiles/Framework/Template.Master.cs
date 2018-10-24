/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;


using Profiles.Framework.Utilities;

namespace Profiles.Framework
{
    /// <summary>
    /// Template.Master.cs
    /// 
    /// 
    /// Used as the master page template for all profiles framework UI pages.
    /// 
    /// Each Panel area of the template is managed by a repeater control.  Each Repeater control will be bound to a List of
    /// List<Utilities.Module> objects that are based on the PresentationXML PannelList/Panel/Module node for each panel.
    /// 
    ///     
    /// 
    ///
    /// </summary>
    public partial class Template : System.Web.UI.MasterPage
    {
        public static readonly string VERSION_CACHE_KEY = "GitVersion";

        #region "Private Properties"

        private XmlDocument _presentationxml;
        private List<Framework.Utilities.Panel> _panels;
        private ModulesProcessing mp;
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            try
            {
                toolkitScriptMaster.AsyncPostBackTimeout = 3600;

                if (this.RDFData == null) { this.RDFData = new XmlDocument(); }
                if (this.RDFNamespaces == null) { this.RDFNamespaces = new XmlNamespaceManager(this.RDFData.NameTable); }

                if (this.GetStringFromPresentationXML("Presentation/PageOptions/@CanEdit") == "true")
                    this.CanEdit = true;
                else
                    this.CanEdit = false;



                this.LoadAssets();

                this.InitFrameworkPanels();


                this.BindRepeaterToPanel(ref rptHeader, GetPanelByType("header"));
                this.BindRepeaterToPanel(ref rptActive, GetPanelByType("active"));
                this.BindRepeaterToPanel(ref rptInfo, GetPanelByType("info"));
                this.BindRepeaterToPanel(ref rptPage, GetPanelByType("page"));
                this.BindRepeaterToPanel(ref rptMain, GetPanelByType("main"));
                this.BindRepeaterToPanel(ref rptPassive, GetPanelByType("passive"));
                this.BindRepeaterToPanel(ref rptFooter, GetPanelByType("footer"));


                if (rptHeader.Items.Count == 0)
                {
                    divProfilesHeader.Visible = false;
                }

                if (this.GetStringFromPresentationXML("Presentation/PageOptions/@Columns") == "2")
                {
                    tdProfilesMainColumnRight.Visible = false;
                    divProfilesPageColumnRightTopLine.Visible = false;
                    divProfilesPage.Style.Remove("background-image");
                    //These two lines are adding inline styles to get the rounded border at bottom of left column. This has been replicated in CSS.
                    //divProfilesPageColumnRightBottom.Style.Remove("background-image");
                    //divProfilesPageColumnRightBottom.Style.Add("background-image", Brand.GetDomain() + "/Framework/images/passive_bottom_alt.gif");
                    divProfilesMainColumnLeft.Style.Remove("width");
                    divProfilesMainColumnLeft.Style.Add("width", "777px");
                    divProfilesContentMain.Style.Remove("width");
                    divProfilesContentMain.Style.Add("width", "756px");
                }


                this.DrawTabs();
            }
            catch (Exception ex)
            {

                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace);

                HttpContext.Current.Session["GLOBAL_ERROR"] = ex.Message + " ++ " + ex.StackTrace;
                Response.Redirect(Brand.GetThemedDomain() + "/error/default.aspx");
            }



        }

        /// <summary>
        /// Used to set the link for css/js client Assets
        /// </summary>
        protected void LoadAssets()
        {

            //This should loop the application table or be set based on the contest of the RESTFul URL to know
            //What application is currently being viewed then set the correct asset link.

            HtmlLink Profilescss = new HtmlLink();
            Profilescss.Href = Brand.GetThemedDomain() + "/Framework/CSS/profiles.css";
            Profilescss.Attributes["rel"] = "stylesheet";
            Profilescss.Attributes["type"] = "text/css";
            Profilescss.Attributes["media"] = "all";
            //Page.Header.Controls.Add(Profilescss);
            head.Controls.Add(Profilescss);

            HtmlLink DEFAULTcss = new HtmlLink();
            DEFAULTcss.Href = Brand.GetThemedDomain() + "/App_Themes/DEFAULT.css";
            DEFAULTcss.Attributes["rel"] = "stylesheet";
            DEFAULTcss.Attributes["type"] = "text/css";
            DEFAULTcss.Attributes["media"] = "all";
            //Page.Header.Controls.Add(DEFAULTcss); 
            head.Controls.Add(DEFAULTcss);
            
            HtmlGenericControl jsscript = new HtmlGenericControl("script");
            jsscript.Attributes.Add("type", "text/javascript");
            jsscript.Attributes.Add("src", Brand.GetThemedDomain() + "/Framework/JavaScript/profiles.js");
            Page.Header.Controls.Add(jsscript);

            HtmlGenericControl UCSFjs = new HtmlGenericControl("script");
            UCSFjs.Attributes.Add("type", "text/javascript");
            UCSFjs.Attributes.Add("src", Brand.GetThemedDomain() + "/Framework/JavaScript/UCSF.js");
            Page.Header.Controls.Add(UCSFjs);

            // add one specific to the theme
            HtmlGenericControl ThemeJs = new HtmlGenericControl("script");
            ThemeJs.Attributes.Add("type", "text/javascript");
            ThemeJs.Attributes.Add("src", Brand.GetThemedDomain() + "/App_Themes/" + Page.Theme + "/" + Page.Theme + ".js");
            Page.Header.Controls.Add(ThemeJs);

            // UCSF. To support lazy login
            String lazyShibLogin = Profiles.Login.ShibbolethSession.GetJavascriptSrc(Request);
            if (!String.IsNullOrEmpty(lazyShibLogin))
            {
                HtmlGenericControl multiShibLogin = new HtmlGenericControl("script");
                multiShibLogin.Attributes.Add("type", "text/javascript");
                multiShibLogin.Attributes.Add("src", lazyShibLogin);
                Page.Header.Controls.Add(multiShibLogin);
            }

            // UCSF. This is handy to have in JavaScript form and is required for ORNG
            HtmlGenericControl rootDomainjs = new HtmlGenericControl("script");
            rootDomainjs.Attributes.Add("type", "text/javascript");
            rootDomainjs.InnerHtml = Environment.NewLine + "var _rootDomain = \"" + Brand.GetThemedDomain() + "\";" + Environment.NewLine;
            Page.Header.Controls.Add(rootDomainjs);

            //The below statement was adding inline styles to the left side navigation. Not needed anymore.
            //if (this.GetStringFromPresentationXML("Presentation/PageOptions/@Columns") == "3")
            //{
            //    divPageColumnRightCenter.Style["background-image"] = Brand.GetDomain() + "/Framework/Images/passive_back.gif";
            //    divPageColumnRightCenter.Style["background-repeat"] = "repeat";
            //}


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
                placeholder = (PlaceHolder)e.Item.FindControl("phInfo");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phMain");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phPage");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phPassive");

            if (placeholder == null)
                placeholder = (PlaceHolder)e.Item.FindControl("phFooter");

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
            return buffer;
        }

        protected void ProcessPresentationXML()
        {
            string buffer = string.Empty;
            SessionManagement sm = new SessionManagement();

            // PageTitle
            buffer = GetStringFromPresentationXML("Presentation/PageTitle");
            string PresentationClass = GetStringFromPresentationXML("//Presentation/@PresentationClass").ToLower();
            if ((PresentationClass == "profile") || (PresentationClass == "network") || (PresentationClass == "connection"))
            {
                if (buffer == String.Empty)
                {
                    buffer = PresentationClass.Substring(0, 1).ToUpper() + PresentationClass.Substring(1, PresentationClass.Length - 1);
                }
                // UCSF schema.org addition to improve SEO
                if (PresentationClass == "profile")
                {
                    buffer = "<span itemprop=\"name\">" + buffer + "</span>";
                }
                litPageTitle.Text = "<h2><a><img class=\"pageIcon\" src=\"" + Brand.GetThemedDomain() + "/Framework/Images/icon_" + PresentationClass + ".gif\"/></a>" + buffer + "</h2>";
            }

            // PageSubTitle
            buffer = GetStringFromPresentationXML("Presentation/PageSubTitle");
            if (buffer != String.Empty)
            {
                litPageSubTitle.Text = "<h3>" + buffer + "</h3>";
            }

            // PageDescription
            buffer = GetStringFromPresentationXML("Presentation/PageDescription");
            if (buffer != String.Empty)
            {
                litPageDescription.Text = "<p>" + buffer + "</p>";
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
                    url = Brand.CleanURL(PageBackLinkURL);

                litBackLink.Text = "<a href=\"" + url + "\" class=\"dblarrow\">" + PageBackLinkName + "</a>";

            }

            // Window Title
            buffer = GetStringFromPresentationXML("Presentation/WindowName");

            if (buffer != String.Empty)
            {
                buffer = buffer + " | ";
            }
            Page.Header.Title = buffer + Brand.GetNiceTitle(Page.Theme) + " Profiles";
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
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace); }

            return rtnpanel;
        }

        private string GetGoogleAnalyticsJavascipt(string trackingID)
        {
            string scriptText = Environment.NewLine +
                    "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){" + Environment.NewLine +
                    "(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o)," + Environment.NewLine +
                    " m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)" + Environment.NewLine +
                    "})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');" + Environment.NewLine +
                    "ga('create', '" + trackingID + "', 'auto');" + Environment.NewLine +
                    "ga('send', 'pageview');" + Environment.NewLine;
            return scriptText;
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
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace); }

            repeater.DataSource = rtnpanel.Modules;
            repeater.DataBind();
        }

        #endregion

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
                "ga('create', '" + trackingID + "', '"+domain+"');" + Environment.NewLine +
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

    }


}

