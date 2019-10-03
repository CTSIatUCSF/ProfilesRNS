using System;
using System.Collections.Generic;

using Profiles.Framework.Utilities;
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
                                        "<url><loc>" + Brand.GetThemedDomain() + "</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetThemedDomain() + "/About/AboutProfiles.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetThemedDomain() + "/About/Help.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetThemedDomain() + "/About/ORCID.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Brand.GetThemedDomain() + "/search</loc></url>" + Environment.NewLine);
                foreach (string prettyURL in LoadPeople(Brand.GetThemedDomain().ToLower())) 
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
                Response.Write("<a href='" + Brand.GetThemedDomain() + "'>" + Brand.GetThemedDomain() + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetThemedDomain() + "/About/AboutProfiles.aspx" + "'>" + Brand.GetThemedDomain() + "/About/AboutProfiles.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetThemedDomain() + "/About/Help.aspx" + "'>" + Brand.GetThemedDomain() + "/About/Help.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetThemedDomain() + "/About/ORCID.aspx" + "'>" + Brand.GetThemedDomain() + "/About/ORCID.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Brand.GetThemedDomain() + "/search" + "'>" + Brand.GetThemedDomain() + "/search" + "</a>" + Environment.NewLine);
                foreach (string prettyURL in LoadPeople(Brand.GetThemedDomain().ToLower())) 
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
