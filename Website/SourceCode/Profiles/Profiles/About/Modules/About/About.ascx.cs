using System;
using System.Collections.Generic;
using System.Xml;

using Profiles.Framework.Utilities;

namespace Profiles.About.Modules.About
{
    public partial class About : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {


        }

        public About() { }
        public About(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
            DrawProfilesModule();
        }

        public void DrawProfilesModule()
        {

            string tabs = string.Empty;
            string tab = string.Empty;

            if (Request.QueryString["tab"] != null)
            {
                tab = Request.QueryString["tab"].ToString().ToLower();
            }
            else
            {
                tab = "overview";
            }

            tabs = Tabs.DrawTabsStart();


            switch (tab)
            {
                case "overview":
                    
                    tabs += Tabs.DrawActiveTab("Overview");
                    tabs += Tabs.DrawDisabledTab("Frequently Asked Questions", Brand.GetThemedDomain() + "/about/default.aspx?tab=faq");
                    tabs += Tabs.DrawDisabledTab("Sharing Data", Brand.GetThemedDomain() + "/about/default.aspx?tab=data");
                    tabs += Tabs.DrawDisabledTab("ORCID", Brand.GetThemedDomain() + "/about/default.aspx?tab=orcid");

                    pnlOverview.Visible = true;

                    break;

                case "faq":
                    tabs += Tabs.DrawDisabledTab("Overview", Brand.GetThemedDomain() + "/about/default.aspx?tab=overview");
                    tabs += Tabs.DrawActiveTab("Frequently Asked Questions");
                    tabs += Tabs.DrawDisabledTab("Sharing Data", Brand.GetThemedDomain() + "/about/default.aspx?tab=data");
                    tabs += Tabs.DrawDisabledTab("ORCID", Brand.GetThemedDomain() + "/about/default.aspx?tab=orcid");

                    pnlFAQ.Visible = true;
                    break;


                case "data":
                    tabs += Tabs.DrawDisabledTab("Overview", Brand.GetThemedDomain() + "/about/default.aspx?tab=overview");
                    tabs += Tabs.DrawDisabledTab("Frequently Asked Questions", Brand.GetThemedDomain() + "/about/default.aspx?tab=faq");
                    tabs += Tabs.DrawActiveTab("Sharing Data");
                    tabs += Tabs.DrawDisabledTab("ORCID", Brand.GetThemedDomain() + "/about/default.aspx?tab=orcid");

                    pnlData.Visible = true;
                    break;
                case "orcid":
                    tabs += Tabs.DrawDisabledTab("Overview", Brand.GetThemedDomain() + "/about/default.aspx?tab=overview");
                    tabs += Tabs.DrawDisabledTab("Frequently Asked Questions", Brand.GetThemedDomain() + "/about/default.aspx?tab=faq");
                    tabs += Tabs.DrawDisabledTab("Sharing Data", Brand.GetThemedDomain() + "/about/default.aspx?tab=data");
                    tabs += Tabs.DrawActiveTab("ORCID");

                    pnlORCID.Visible = true;
                    break;


            }

            //tabs += Tabs.DrawTabsEnd();
            //litTabs.Text = tabs;
        }
    }
}