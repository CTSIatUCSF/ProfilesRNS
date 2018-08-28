using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Xml;

using Profiles.Framework.Utilities;


namespace Profiles.Profile.Modules
{
    public partial class CustomViewAuthorInAuthorship : BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            DrawProfilesModule();
        }

        public CustomViewAuthorInAuthorship() : base() { }
        public CustomViewAuthorInAuthorship(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            base.RDFTriple = new RDFTriple(Convert.ToInt64(Request.QueryString["Subject"]));

        }
        private void DrawProfilesModule()
        {


            DateTime d = DateTime.Now;
            Profiles.Profile.Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            List<Publication> publication = new List<Publication>();

            Utilities.DataIO.ClassType type = Utilities.DataIO.ClassType.Unknown;
            Framework.Utilities.Namespace xmlnamespace = new Profiles.Framework.Utilities.Namespace();
            XmlNamespaceManager namespaces = xmlnamespace.LoadNamespaces(BaseData);
            if (BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Person']", namespaces) != null)
                type = Utilities.DataIO.ClassType.Person;
            if (BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Group']", namespaces) != null)
                type = Utilities.DataIO.ClassType.Grant;

            using (SqlDataReader reader = data.GetPublications(base.RDFTriple, type))
            {
                while (reader.Read())
                {
                    publication.Add(new Publication(reader["bibo_pmid"].ToString(), reader["vivo_pmcid"].ToString(), reader["authors"].ToString(), reader["prns_informationResourceReference"].ToString(), reader["vivo_webpage"].ToString(), reader["authorXML"].ToString()));
                }

                rpPublication.DataSource = publication;
                rpPublication.DataBind();
            }

            // Get timeline bar chart
            string storedproc = "[Profile.Module].[NetworkAuthorshipTimeline.Person.GetData]";
            if (type == Utilities.DataIO.ClassType.Grant) storedproc = "[Profile.Module].[NetworkAuthorshipTimeline.Group.GetData]";
            using (SqlDataReader reader = data.GetGoogleTimeline(base.RDFTriple, storedproc, null))
            {
                while (reader.Read())
                {
                    timelineBar.Src = reader["gc"].ToString();
                    timelineBar.Alt = reader["alt"].ToString();
                    litTimelineTable.Text = reader["asText"].ToString();
                }
                reader.Close();
            }

            if (timelineBar.Src == "")
            {
                timelineBar.Visible = false;
            }


            // Login link
            loginLiteral.Text = String.Format("<a href='{0}'>login</a>", Brand.GetThemedDomain() + "/login/default.aspx?pin=send&method=login&edit=true");

            if (type == Utilities.DataIO.ClassType.Grant) divPubHeaderText.Visible = false;

            Framework.Utilities.DebugLogging.Log("PUBLICATION MODULE end Milliseconds:" + (DateTime.Now - d).TotalSeconds);

        }

        protected void rpPublication_OnDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Publication pub = (Publication)e.Item.DataItem;
                Label lblNum = (Label)e.Item.FindControl("lblNum");
                Label lblPublication = (Label)e.Item.FindControl("lblPublication");
                Literal litViewIn = (Literal)e.Item.FindControl("litViewIn");
                System.Web.UI.HtmlControls.HtmlGenericControl liPublication = ((System.Web.UI.HtmlControls.HtmlGenericControl)(e.Item.FindControl("liPublication")));

                // use the XML if it is not null so that we can display links, otherwise the regular list
                string lblPubTxt = !String.IsNullOrEmpty(pub.authorXML) ? getAuthorList(pub.authorXML) : pub.authors;
                // ugly logic but it works. If we did not match current author on URI, then do a name match
                if (!lblPubTxt.Contains("<b>"))
                {
                    lblPubTxt = findAndDecorateThisAuthor(base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/foaf:firstName", this.Namespaces).InnerText.Substring(0, 1),
                                                          base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/foaf:lastName", this.Namespaces).InnerText + " ",
                                                          lblPubTxt);
                }
                lblPubTxt += (!String.IsNullOrEmpty(lblPubTxt) && !lblPubTxt.TrimEnd().EndsWith(".") ? ". " : "") + pub.prns_informationResourceReference;
                if (pub.bibo_pmid != string.Empty && pub.bibo_pmid != null)
                {
                    lblPubTxt = lblPubTxt + " PMID: " + pub.bibo_pmid;
                    liPublication.Attributes["data-pmid"] = pub.bibo_pmid;
                    litViewIn.Text = "View in: <a href='//www.ncbi.nlm.nih.gov/pubmed/" + pub.bibo_pmid + "' target='_blank'>PubMed</a>";
                    if (pub.vivo_pmcid != null)
                    {
                        if (pub.vivo_pmcid.Contains("PMC"))
                        {
                            lblPubTxt = lblPubTxt + "; PMCID: " + pub.vivo_pmcid;
                            string pmcid = pub.vivo_pmcid;
                            int len = pmcid.IndexOf(' ');
                            if (len != -1) pmcid = pmcid.Substring(0, len);
                            litViewIn.Text = litViewIn.Text + ", <a href='//www.ncbi.nlm.nih.gov/pmc/articles/" + pmcid + "' target='_blank'>PubMed Central</a>";
                        }
                        else if (pub.vivo_pmcid.Contains("NIHMS"))
                        {
                            lblPubTxt = lblPubTxt + "; NIHMSID: " + pub.vivo_pmcid;
                        }
                    }
                    lblPubTxt = lblPubTxt + ".";
                }
                else if (pub.vivo_webpage != string.Empty && pub.vivo_webpage != null)
                {
                    litViewIn.Text = "<a href='" + pub.vivo_webpage + "' target='_blank'>View Publication</a>";
                }
                lblPublication.Text = lblPubTxt;
            }
        }

        private String getAuthorList(string authorXml)
        {
            string authorList = "";
            // parse out XML document to get known coauthor URI's
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(authorXml); 
            XmlNodeList xnList = doc.SelectNodes("/authors/author");
            foreach (XmlNode xn in xnList)
            {
                authorList += ", ";
                string display = xn["display"].InnerText;
                if (xn["url"] != null)
                {
                    string url = xn["url"].InnerText;
                    if ((Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath).Equals(url, StringComparison.InvariantCultureIgnoreCase))
                    {
                        // this is the author, just make it bold
                        authorList += "<b>" + display + "</b>";
                    }
                    else
                    {
                        // this is a coauthor, make it a hyperlink
                        authorList += "<a href='" + url + "' target='_blank'>" + display + "</a>";
                    }
                }
                else
                {
                    authorList += display;
                }
            }
            return authorList.Length > 0 ? authorList.Substring(2) : authorList;
        }

        // find a way to put the current author in bold to match what happens above in getAuthorList
        private String findAndDecorateThisAuthor(string firstInitial, string lastNamePlus, string authors)
        {
            try
            {
                foreach (string authorChunk in authors.Split(','))
                {
                    string author = authorChunk.Trim();
                    // if this is a match, either as stand alone text or in an href
                    if (author.IndexOf(lastNamePlus) == 0 || author.IndexOf(">" + lastNamePlus) != -1)
                    {
                        // if this is the only match
                        if (authors.IndexOf(lastNamePlus, authors.IndexOf(author) + author.Length) == -1 ||
                            // this is the only match with first initial
                            (author.IndexOf(lastNamePlus + firstInitial) == 0 && authors.IndexOf(lastNamePlus + firstInitial, authors.IndexOf(author) + author.Length) == -1))
                        {
                            return authors.Replace(author, "<b>" + author + "</b>");
                        }
                    }
                }
            }
            catch (Exception e)
            {
                Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
            }
            return authors;
        }

        public class Publication
        {
            public Publication(string _bibo_pmid, string _vivo_pmcid, string _authors, string prns_informationresourcereference, string _vivo_webpage, string _authorXML)
            {
                this.bibo_pmid = _bibo_pmid;
                this.vivo_pmcid = _vivo_pmcid;
                this.authors = _authors;
                this.prns_informationResourceReference = prns_informationresourcereference;
                this.vivo_webpage = _vivo_webpage;
                this.authorXML = _authorXML;
            }

            public string bibo_pmid { get; set; }
            public string vivo_pmcid { get; set; }
            public string authors { get; set; } 
            public string prns_informationResourceReference { get; set; }
            public string vivo_webpage { get; set; }
            public string authorXML { get; set; }
        }

    }
}