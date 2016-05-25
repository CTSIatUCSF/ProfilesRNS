﻿using System;
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
    public partial class SiteMap : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.Path.ToLower().EndsWith(".xml")) 
            {
                Response.Write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>" + Environment.NewLine +
                                        "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"" + Environment.NewLine +
                                        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"" + Environment.NewLine +
                                        "xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\">" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/About</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/About/AboutProfiles.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/About/ForDevelopers.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/About/GadgetLibrary.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/About/Help.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/About/HowProfilesWorks.aspx</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/search</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/search/people</loc></url>" + Environment.NewLine +
                                        "<url><loc>" + Root.Domain + "/search/all</loc></url>" + Environment.NewLine);
                foreach (string urlname in LoadPeople()) 
                {
                        Response.Write("<url><loc>" + Root.Domain + "/" + urlname + "</loc></url>" + Environment.NewLine);
                }

                Response.Write("</urlset>");
                Response.ContentType = "application/xml";
            	Response.Charset = "UTF-8";
                Response.End();
            }
            else 
            {
                Response.Write("<a href='" + Root.Domain + "'>" + Root.Domain + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/About" + "'>" + Root.Domain + "/About" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/About/AboutProfiles.aspx" + "'>" + Root.Domain + "/About/AboutProfiles.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/About/ForDevelopers.aspx" + "'>" + Root.Domain + "/About/ForDevelopers.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/About/GadgetLibrary.aspx" + "'>" + Root.Domain + "/About/GadgetLibrary.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/About/Help.aspx" + "'>" + Root.Domain + "/About/Help.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/About/HowProfilesWorks.aspx" + "'>" + Root.Domain + "/About/HowProfilesWorks.aspx" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/search" + "'>" + Root.Domain + "/search" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/search/people" + "'>" + Root.Domain + "/search/people" + "</a>" + Environment.NewLine +
                               "<a href='" + Root.Domain + "/search/all" + "'>" + Root.Domain + "/search/all" + "</a>" + Environment.NewLine);
                foreach (string urlname in LoadPeople()) 
                {
                        Response.Write("<a href='" + Root.Domain + "/" + urlname + "'>" + Root.Domain + "/" + urlname + "</a>" + Environment.NewLine);
                }
                Response.End();
            }
        }

        // can do this via Search API but this is much faster since we know exactly what we want
        private List<string> LoadPeople()
        {
            List<string> urlNames = new List<string>();
            DataIO data = new DataIO();
            using (SqlDataReader reader = data.GetDBCommand(ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString,
                "select n.UrlName from [Profile.Data].Person p join [UCSF.].NameAdditions n on p.InternalUserName = n.InternalUserName where p.IsActive = 1"
                , CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader())
            {
                while (reader.Read())
                {
                    urlNames.Add(reader[0].ToString());
                }
            }
            return urlNames;
        }
    }

}
