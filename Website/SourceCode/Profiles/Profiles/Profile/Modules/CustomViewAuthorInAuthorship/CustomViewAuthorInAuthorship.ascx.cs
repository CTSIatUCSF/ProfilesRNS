using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Xml;
using System.Web.UI.HtmlControls;

using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.CustomViewAuthorInAuthorship
{
    public partial class CustomViewAuthorInAuthorship : BaseModule
    {
        protected string svcURL { get { return Brand.GetThemedDomain() + "/profile/modules/CustomViewAuthorInAuthorship/BibliometricsSvc.aspx?p="; } }

        protected long nodeID { get { return base.RDFTriple.Subject; } }
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
            Profiles.Profile.Modules.CustomViewAuthorInAuthorship.DataIO data = new Profiles.Profile.Modules.CustomViewAuthorInAuthorship.DataIO();
            List<Publication> publication = new List<Publication>();

            Utilities.DataIO.ClassType type = Utilities.DataIO.ClassType.Unknown;
            Framework.Utilities.Namespace xmlnamespace = new Profiles.Framework.Utilities.Namespace();
            XmlNamespaceManager namespaces = xmlnamespace.LoadNamespaces(BaseData);
            if (BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Person']", namespaces) != null)
                type = Utilities.DataIO.ClassType.Person;
            if (BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Group']", namespaces) != null)
                type = Utilities.DataIO.ClassType.Group;

            using (SqlDataReader reader = data.GetPublications(base.RDFTriple, type))
            {
                while (reader.Read())
                {
                    publication.Add(new Publication(reader["bibo_pmid"].ToString(), reader["vivo_pmcid"].ToString(), reader["authors"].ToString(), reader["prns_informationResourceReference"].ToString(),
                        reader["vivo_webpage"].ToString(), reader["authorXML"].ToString(), reader["Source"].ToString(), Convert.ToInt32(reader["PMCCitations"]),
                        reader["Fields"].ToString(), Convert.ToInt32(reader["TranslationHumans"]), Convert.ToInt32(reader["TranslationAnimals"]),
                        Convert.ToInt32(reader["TranslationCells"]), Convert.ToInt32(reader["TranslationPublicHealth"]), Convert.ToInt32(reader["TranslationClinicalTrial"])));
                }

                rpPublication.DataSource = publication;
                rpPublication.DataBind();
            }

            // Get timeline bar chart
            string storedproc = "[Profile.Module].[NetworkAuthorshipTimeline.Person.GetData]";
            if (type == Utilities.DataIO.ClassType.Group) storedproc = "[Profile.Module].[NetworkAuthorshipTimeline.Group.GetData]";
            using (SqlDataReader reader = data.GetGoogleTimeline(base.RDFTriple, storedproc))
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

            if (type == Utilities.DataIO.ClassType.Group) divPubHeaderText.Visible = false;

            Framework.Utilities.DebugLogging.Log("PUBLICATION MODULE end Milliseconds:" + (DateTime.Now - d).TotalSeconds);
        }

        protected void rpPublication_OnDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Publication pub = (Publication)e.Item.DataItem;
                Label lblNum = (Label)e.Item.FindControl("lblNum");
                Label lblPublication = (Label)e.Item.FindControl("lblPublication");
                Label lblPublicationIDs = (Label)e.Item.FindControl("lblPublicationIDs");
                Literal litViewIn = (Literal)e.Item.FindControl("litViewIn");
                System.Web.UI.HtmlControls.HtmlGenericControl liPublication = ((System.Web.UI.HtmlControls.HtmlGenericControl)(e.Item.FindControl("liPublication")));

                // use the XML if it is not null so that we can display links, otherwise the regular list
                // clean up pub.authors so that me,you becomes me, you

                string lblPubTxt = !String.IsNullOrEmpty(pub.authorXML) ? getAuthorList(pub.authorXML) : pub.authors.Replace(",", ", ").Replace("  ", " ");

                // from the DrawProfilesModule it seems that divPubHeaderText is made not visible when this is shown for a group
                if (!lblPubTxt.Contains("<b>") && divPubHeaderText.Visible)
                {
                    // ugly logic but it works. If we did not match current author on URI, then do a name match
                    // Also added code to skip this for groups
                    Framework.Utilities.Namespace xmlnamespace = new Profiles.Framework.Utilities.Namespace();
                    XmlNamespaceManager namespaces = xmlnamespace.LoadNamespaces(BaseData);
                    try
                    {
                        lblPubTxt = findAndDecorateThisAuthor(base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/foaf:firstName", this.Namespaces).InnerText.Substring(0, 1),
                                                              base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/foaf:lastName", this.Namespaces).InnerText,
                                                              lblPubTxt);
                    }
                    catch (Exception ex)
                    {
                        Framework.Utilities.DebugLogging.Log(ex.Message + ex.StackTrace);
                    }
                }
                //some cleanup to help with the dimensions stuff
                lblPubTxt += (!String.IsNullOrEmpty(lblPubTxt) && !lblPubTxt.TrimEnd().EndsWith(".") ? ". " : "");
                lblPubTxt = lblPubTxt.Replace(". .", ".");

                string doi = "";
                if (pub.bibo_pmid != string.Empty && pub.bibo_pmid != null)
                {
                    if (pub.bibo_pmid.IndexOf("-") < 0)
                    {
                        lblPubTxt = lblPubTxt + " PMID: " + pub.bibo_pmid;
                    }
                    else
                    {
                        if (pub.vivo_webpage.IndexOf("doi.org") > -1)
                        {
                            pub.prns_pubsource = "Publisher Site";
                            int doistart = pub.vivo_webpage.IndexOf("doi.org") + 8;
                            doi = pub.vivo_webpage.Substring(doistart);
                            liPublication.Attributes["data-doi"] = doi;
                        }
                    }
                    liPublication.Attributes["data-pmid"] = pub.bibo_pmid;
                    liPublication.Attributes["data-citations"] = "" + pub.PMCCitations;
                    // liPublication.Attributes["data-Fields"] = pub.Fields;
                    liPublication.Attributes["data-TranslationHumans"] = "" + pub.TranslationHumans;
                    liPublication.Attributes["data-TranslationAnimals"] = "" + pub.TranslationAnimals;
                    liPublication.Attributes["data-TranslationCells"] = "" + pub.TranslationCells;
                    liPublication.Attributes["data-TranslationPublicHealth"] = "" + pub.TranslationPublicHealth;
                    liPublication.Attributes["data-TranslationClinicalTrial"] = "" + pub.TranslationClinicalTrial;
                    //litViewIn.Text = "View in: <a href='//www.ncbi.nlm.nih.gov/pubmed/" + pub.bibo_pmid + "' target='_blank'>PubMed</a>";
                    if (pub.vivo_webpage.IndexOf("doi.org") > -1)
                    {
                        pub.prns_pubsource = "Publisher Site";
                    }
                    // litViewIn.Text = "View in: <a href='//www.ncbi.nlm.nih.gov/pubmed/" + pub.bibo_pmid + "' target='_blank'>PubMed</a>";
                    if (pub.vivo_webpage != string.Empty && pub.vivo_webpage != null)
                    {
                        litViewIn.Text = "View in: <a href=" + pub.vivo_webpage + " target='_blank'>" + pub.prns_pubsource + "</a>";
                    }
                    if (pub.vivo_pmcid != null)
                    {
                        if (pub.vivo_pmcid.Contains("PMC"))
                        {
                            string pmcid = pub.vivo_pmcid;
                            int len = pmcid.IndexOf(' ');
                            if (len != -1) pmcid = pmcid.Substring(0, len);
                            lblPubTxt = lblPubTxt + "; PMCID: <a href='//www.ncbi.nlm.nih.gov/pmc/articles/" + pmcid + "' target='_blank'>" + pmcid + "</a>";
                            //litViewIn.Text = litViewIn.Text + ", <a href='//www.ncbi.nlm.nih.gov/pmc/articles/" + pmcid + "' target='_blank'>PubMed Central</a>";
                        }
                        else if (pub.vivo_pmcid.Contains("NIHMS"))
                        {
                            lblPubTxt = lblPubTxt + "; NIHMSID: " + pub.vivo_pmcid;
                        }
                    }
                    lblPubTxt += lblPubTxt.EndsWith(".") ? "" : ".";

                    //if (pub.PMCCitations <= 0) litViewIn.Text = "Citations: <span class=\"PMC-citations\"><span class=\"PMC-citation-count\">0</span></span>";
                    string citationText = "";
                    if (pub.bibo_pmid.IndexOf("-") < 0) // if it has a dash it is a DOI, so only do this Harvard type stuff for non-DOI ones
                    {
                        // don't worry about the Altmetric in the spnHideOnNoAltmetric, it really means hide on no citations
                        if (pub.PMCCitations <= 0)
                        {
                            citationText = "<span id='spnHideOnNoAltmetric" + pub.bibo_pmid +
                                "'>&nbsp;&nbsp;&nbsp;Mentions: <span class='altmetric-embed' data-link-target='_blank' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-pmid='" +
                                pub.bibo_pmid + "'></span></span>";
                        }
                        else
                        {
                            citationText = "&nbsp;&nbsp;&nbsp;Mentions: <a href='https://www.ncbi.nlm.nih.gov/pmc/articles/pmid/" + pub.bibo_pmid +
                                "/citedby/' target='_blank' class=\"PMC-citations\"><span class=\"PMC-citation-count\">" +
                                pub.PMCCitations + "</span></a>" + "<span id='spnHideOnNoAltmetric" + pub.bibo_pmid +
                                "'>&nbsp;&nbsp;<span class='altmetric-embed' data-link-target='_blank' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-pmid='" +
                                pub.bibo_pmid + "'></span></span>";
                        }
                    }
                    else if (!doi.IsNullOrEmpty())
                    {
                        // Add badges based on DOI
                        citationText = "<span id='spnHideOnNoAltmetric" + doi +
                            "'>&nbsp;&nbsp;&nbsp;Mentions: <span class='altmetric-embed' data-link-target='_blank' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-doi='" +
                            doi + "'></span></span>";
                    }

                    litViewIn.Text = litViewIn.Text + citationText;

                    /*
                                       if (pub.PMCCitations <= 0) litViewIn.Text = litViewIn.Text + " " + "<span id='spnHideOnNoAltmetric" + pub.bibo_pmid + "'> Citations: <span class='altmetric-embed' data-link-target='_blank' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-pmid='" + pub.bibo_pmid + "'></span>&nbsp;&nbsp;&nbsp;</span>";
                                       else litViewIn.Text = litViewIn.Text + " " + "Citations: <a href='https://www.ncbi.nlm.nih.gov/pmc/articles/pmid/" + pub.bibo_pmid + "/citedby/' target='_blank' class=\"PMC-citations\"><span class=\"PMC-citation-count\">" + pub.PMCCitations + "</span></a>" +
                                          "<span id='spnHideOnNoAltmetric" + pub.bibo_pmid + "'>&nbsp;&nbsp;<span class='altmetric-embed' data-link-target='_blank' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-pmid='" + pub.bibo_pmid + "'></span></span>&nbsp;&nbsp;&nbsp;";
                   */
                    if (!pub.Fields.Equals(""))
                    {
                        litViewIn.Text = litViewIn.Text + "&nbsp;&nbsp;&nbsp;Fields:&nbsp;<div style='display:inline-flex'>";
                        string[] tmparray = pub.Fields.Split('|');
                        for (int i = 0; i < tmparray.Length; i++)
                        {
                            string field = tmparray[i].Split(',')[0];
                            string colour = tmparray[i].Split(',')[1];
                            string displayName = tmparray[i].Split(',')[2];
                            liPublication.Attributes["data-Field" + colour] = "1";
                            litViewIn.Text += "<a class='publication-filter' style='border:1px solid #" + colour + ";' data-color=\"#" + colour + "\" OnClick=\"toggleFilter('data-Field" + colour + "')\">" + field + "<span class='tooltiptext' style='background-color:#" + colour + ";'> " + displayName + "</span></a>";
                        }
                        litViewIn.Text = litViewIn.Text + "</div>&nbsp;&nbsp;&nbsp;";
                    }

                    if (pub.TranslationHumans + pub.TranslationAnimals + pub.TranslationCells + pub.TranslationPublicHealth + pub.TranslationClinicalTrial > 0)
                    {
                        litViewIn.Text = litViewIn.Text + "Translation:";
                        if (pub.TranslationHumans == 1) litViewIn.Text = litViewIn.Text + "<a class='publication-filter publication-humans' data-color='#3333CC' OnClick=\"toggleFilter('data-TranslationHumans')\">Humans</a>";
                        if (pub.TranslationAnimals == 1) litViewIn.Text = litViewIn.Text + "<a class='publication-filter publication-animals' data-color='#33AA33' OnClick=\"toggleFilter('data-TranslationAnimals')\">Animals</a>";
                        if (pub.TranslationCells == 1) litViewIn.Text = litViewIn.Text + "<a class='publication-filter publication-cells' data-color='#BB3333' OnClick=\"toggleFilter('data-TranslationCells')\">Cells</a>";
                        if (pub.TranslationPublicHealth == 1) litViewIn.Text = litViewIn.Text + "<a class='publication-filter publication-public-health' data-color='#609' OnClick=\"toggleFilter('data-TranslationPublicHealth')\">PH<span class='tooltiptext' style='background-color:#609;'>Public Health</span></a>";
                        if (pub.TranslationClinicalTrial == 1) litViewIn.Text = litViewIn.Text + "<a class='publication-filter publication-clinical-trial' data-color='#00C' OnClick=\"toggleFilter('data-TranslationClinicalTrial')\">CT<span class='tooltiptext' style='background-color:#00C;'>Clinical Trials</span></a>";
                    }

                }
                else
                {
                    e.Item.FindControl("divArticleMetrics").Visible = false;
                    
                    if (pub.vivo_webpage != string.Empty && pub.vivo_webpage != null)
                    {
                        lblPubTxt += "<a href='" + pub.vivo_webpage + "' target='_blank'>View Publication</a>.";
                    }

                }
                // hack on a hack for Unfuddle 265
                lblPublication.Text = pub.authors != null && pub.authors.Length > 0 && pub.prns_informationResourceReference.StartsWith(pub.authors) ?
                    pub.prns_informationResourceReference.Substring(pub.authors.Length) : pub.prns_informationResourceReference;
                lblPublicationIDs.Text = lblPubTxt;
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
                        authorList += "<a href='" + Brand.CleanURL(url) + "' target='_blank'>" + display + "</a>";
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
        private String findAndDecorateThisAuthor(string firstInitial, string lastName, string authors)
        {
            try
            {
                foreach (string authorChunk in authors.Split(','))
                {
                    string author = authorChunk.Trim();
                    // if this is a match, either as stand alone text or in an href
                    string[] lastNameOptions = { lastName + " ", " " + lastName }; // PubMed style, Dimensions style
                    foreach (string lastNamePlus in lastNameOptions)
                    {
                        // pubmed match
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
                        // Dimensions match
                        else if (author.IndexOf(lastNamePlus) > 0 && (authors.IndexOf(lastNamePlus, authors.IndexOf(author) + author.Length) == -1))
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
            public Publication(string _bibo_pmid, string _vivo_pmcid,  string _authors, string prns_informationresourcereference, string _vivo_webpage, string _authorXML, string _pubsource, int PMCCitations,
                string Fields, int TranslationHumans, int TranslationAnimals, int TranslationCells, int TranslationPublicHealth, int TranslationClinicalTrial)
            {
                this.bibo_pmid = _bibo_pmid;
                this.vivo_pmcid = _vivo_pmcid;
                this.authors = swapInPrettyURLS(_authors);
                this.prns_informationResourceReference = prns_informationresourcereference;
                this.vivo_webpage = _vivo_webpage;
                this.PMCCitations = PMCCitations;
                this.Fields = Fields;
                this.authorXML = _authorXML;
                this.prns_pubsource = _pubsource;
                this.TranslationHumans = TranslationHumans;
                this.TranslationAnimals = TranslationAnimals;
                this.TranslationCells = TranslationCells;
                this.TranslationPublicHealth = TranslationPublicHealth;
                this.TranslationClinicalTrial = TranslationClinicalTrial;
            }

            public string bibo_pmid { get; set; }
            public string vivo_pmcid { get; set; }
            public string authors { get; set; }
            public string prns_informationResourceReference { get; set; }
            public string prns_pubsource { get; set; }
            public string vivo_webpage
            { get; set; }
            public int PMCCitations { get; set; }
            public string authorXML { get; set; }
            public string Fields { get; set; }
            public int TranslationHumans { get; set; }
            public int TranslationAnimals { get; set; }
            public int TranslationCells { get; set; }
            public int TranslationPublicHealth { get; set; }
            public int TranslationClinicalTrial { get; set; }

            private string swapInPrettyURLS(string authors)
            {
                // look for https://thisURI/profile/12345 and swap it in. 
                int ndx = authors.IndexOf(Root.Domain + "/profile/");
                while (ndx >= 0)
                {
                    string uri = authors.Substring(ndx, authors.IndexOf('"', ndx + Root.Domain.Length + 9) - ndx);
                    authors = authors.Replace(uri, Brand.CleanURL(uri));
                    ndx = authors.IndexOf(Root.Domain + "/profile/", ndx + Root.Domain.Length + 9);
                }
                return authors;
            }

        }
    }
}