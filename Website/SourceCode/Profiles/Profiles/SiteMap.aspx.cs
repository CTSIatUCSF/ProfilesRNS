using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Routing;
using System.Web.Compilation;
using System.Web.UI;
using System.Web.UI.WebControls;

using Profiles.Framework.Utilities;
using System.Xml;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace Profiles
{
    public partial class SiteMap : BrandedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Path.ToLower().EndsWith(".xml")) 
            {
                Response.Write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + Environment.NewLine +
                                        "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"" + Environment.NewLine +
                                        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"" + Environment.NewLine +
                                        "xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\">" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/About</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/About/AboutProfiles.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/About/ForDevelopers.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/About/GadgetLibrary.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/About/Help.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/About/HowProfilesWorks.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/search</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/search/people</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetDomain() + "/search/all</loc></url>" + Environment.NewLine);
                foreach (string prettyURL in LoadPeople(Brand.GetDomain().ToLower())) 
                {
                        Response.Write("<url><loc>" + prettyURL + "</loc></url>" + Environment.NewLine);
                }

                Response.Write("</urlset>");
                Response.ContentType = "application/xml";
            	Response.Charset = "UTF-8";
                Response.End();
            }
            else 
            {
                Response.Write("<a href='" + Brand.GetDomain() + "'>" + Brand.GetDomain() + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/About" + "'>" + Brand.GetDomain() + "/About" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/About/AboutProfiles.aspx" + "'>" + Brand.GetDomain() + "/About/AboutProfiles.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/About/ForDevelopers.aspx" + "'>" + Brand.GetDomain() + "/About/ForDevelopers.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/About/GadgetLibrary.aspx" + "'>" + Brand.GetDomain() + "/About/GadgetLibrary.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/About/Help.aspx" + "'>" + Brand.GetDomain() + "/About/Help.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/About/HowProfilesWorks.aspx" + "'>" + Brand.GetDomain() + "/About/HowProfilesWorks.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/search" + "'>" + Brand.GetDomain() + "/search" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/search/people" + "'>" + Brand.GetDomain() + "/search/people" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetDomain() + "/search/all" + "'>" + Brand.GetDomain() + "/search/all" + "</a>" + Environment.NewLine);
                foreach (string prettyURL in LoadPeople(Brand.GetDomain().ToLower())) 
                {
                    Response.Write("<a href='" + prettyURL + "'>" + prettyURL + "</a>" + Environment.NewLine);
                }
                Response.End();
            }
        }

        // can do this via Search API but this is much faster since we know exactly what we want
        private List<string> LoadPeople(string matchingDomain)
        {
            List<string> urlNames = new List<string>();
            foreach (string prettyURL in UCSFIDSet.PrettyURLs)
            {
                if (prettyURL.ToLower().StartsWith(matchingDomain))
                {
                    urlNames.Add(prettyURL);
                }
            }
            return urlNames;
        }
    }

}
