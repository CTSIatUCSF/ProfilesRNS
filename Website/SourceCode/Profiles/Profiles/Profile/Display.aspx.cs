﻿/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/

using System;
using System.Web.UI;
using System.Xml;
using System.Web.UI.HtmlControls;

using Profiles.Profile.Utilities;
using Profiles.Framework.Utilities;
using System.Web;

namespace Profiles.Profile
{
    public partial class Display : ProfileData
    {
        private Profiles.Framework.Template masterpage;

        private static Random random = new Random();

        public void Page_Load(object sender, EventArgs e)
        {
            UserHistory uh = new UserHistory();

            masterpage = (Framework.Template)base.Master;
            this.Master = masterpage;

            this.LoadAssets();

            this.LoadPresentationXML();

            XmlNode x = this.PresentationXML.SelectSingleNode("Presentation[1]/ExpandRDFList[1]");

            if (x != null)
                base.RDFTriple.ExpandRDFList = x.InnerXml;

            if (base.RDFTriple.Subject != 0 && base.RDFTriple.Predicate != 0 && base.RDFTriple.Object == 0)
                base.RDFTriple.Limit = "1";

            base.LoadRDFData();

            Framework.Utilities.DebugLogging.Log("Page_Load Profile 1: " + DateTime.Now.ToLongTimeString());

            masterpage.Tab = base.Tab;
            masterpage.RDFData = base.RDFData;
            masterpage.RDFNamespaces = base.RDFNamespaces;
            masterpage.PresentationXML = this.PresentationXML;
            Framework.Utilities.DebugLogging.Log("Page_Load Profile 2: " + DateTime.Now.ToLongTimeString());

            // UCSF added schema.org info
            // Only do this for a person version of this page !
            XmlNode presentationClass = PresentationXML.SelectSingleNode("//Presentation/@PresentationClass", base.RDFNamespaces);
            if (presentationClass != null && "profile".Equals(presentationClass.InnerText.ToLower()) &&
                this.RDFData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/foaf:firstName", base.RDFNamespaces) != null &&
                this.RDFData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/foaf:lastName", base.RDFNamespaces) != null)
            {
                ((HtmlGenericControl)masterpage.FindControl("divProfilesContentMain")).Attributes.Add("itemscope", "itemscope");
                ((HtmlGenericControl)masterpage.FindControl("divProfilesContentMain")).Attributes.Add("itemtype", "http://schema.org/Person");

                HtmlMeta Description = new HtmlMeta();
                Description.Name = "Description";
                string name = this.RDFData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/foaf:firstName", base.RDFNamespaces).InnerText + " " +
                     this.RDFData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/foaf:lastName", base.RDFNamespaces).InnerText;
                Description.Content = name + "'s profile, publications, research topics, and co-authors";
                Page.Header.Controls.Add(Description);

                // Unfuddle 191. Add twitter metadata
                HtmlMeta twitterCard = new HtmlMeta();
                twitterCard.Name = "twitter:card";
                twitterCard.Content = "summary";
                Page.Header.Controls.Add(twitterCard);

                if (UCSFIDSet.IsPerson(base.RDFTriple.Subject) && !String.IsNullOrEmpty(UCSFIDSet.ByNodeId[base.RDFTriple.Subject].Institution.GetTwitterHandle()))
                {
                    HtmlMeta twitterSite = new HtmlMeta();
                    twitterSite.Name = "twitter:site";
                    twitterSite.Content = UCSFIDSet.ByNodeId[base.RDFTriple.Subject].Institution.GetTwitterHandle();
                    Page.Header.Controls.Add(twitterSite);

                    HtmlMeta twitterCreator = new HtmlMeta();
                    twitterCreator.Name = "twitter:creator";
                    twitterCreator.Content = UCSFIDSet.ByNodeId[base.RDFTriple.Subject].Institution.GetTwitterHandle();
                    Page.Header.Controls.Add(twitterCreator);
                }

                HtmlMeta twitterTitle = new HtmlMeta();
                twitterTitle.Name = "twitter:title";
                twitterTitle.Content = name + " • " + Brand.GetNiceTitle(Page.Theme) + " Profiles";
                Page.Header.Controls.Add(twitterTitle);

                HtmlMeta twitterDescription = new HtmlMeta();
                twitterDescription.Name = "twitter:description";
                twitterDescription.Content = Description.Content;
                Page.Header.Controls.Add(twitterDescription);

                HtmlMeta twitterImage = new HtmlMeta();
                twitterImage.Name = "twitter:image";
                twitterImage.Content = "https://researcherprofiles.org/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=" + base.RDFTriple.Subject;
                Page.Header.Controls.Add(twitterImage);

                HtmlMeta twitterImageAlt = new HtmlMeta();
                twitterImageAlt.Name = "twitter:image:alt";
                twitterImageAlt.Content = "Photo of " + name;
                Page.Header.Controls.Add(twitterImageAlt);
                // end Unfulddle 191

                HtmlLink Canonical = new HtmlLink();
                Canonical.Href = Request.Url.AbsoluteUri.IndexOf('?') == -1 ? Request.Url.AbsoluteUri.ToLower() : Request.Url.AbsoluteUri.ToLower().Substring(0, Request.Url.AbsoluteUri.IndexOf('?'));
                Canonical.Attributes["rel"] = "canonical";
                Page.Header.Controls.Add(Canonical);
            }
            else
            {
                // Tell the bots that this is slow moving data, add an exires at some random date up to 30 days out
                DateTime expires = DateTime.Now.Add( TimeSpan.FromDays( random.NextDouble() * 29 + 1 ));
                Response.AddHeader("Expires", expires.ToUniversalTime().ToString("r"));
            }
        }


        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            if (Root.AbsolutePath.ToLower().Contains("/network/"))
            {
                body.Attributes.Add("class", "researcherprofiles--researcher-network-page researcherprofiles--researcher-profile-or-network-page");
            }
            else
            {
                body.Attributes.Add("class", "researcherprofiles--researcher-profile-page researcherprofiles--researcher-profile-or-network-page");
            }

            HtmlLink Displaycss = new HtmlLink();
            Displaycss.Href = Brand.GetThemedDomain() + "/Profile/CSS/display.css";
            Displaycss.Attributes["rel"] = "stylesheet";
            Displaycss.Attributes["type"] = "text/css";
            Displaycss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Displaycss);

            HtmlGenericControl UCSFjs = new HtmlGenericControl("script");
            UCSFjs.Attributes.Add("type", "text/javascript");
            UCSFjs.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/JavaScript/UCSF.js");
            Page.Header.Controls.Add(UCSFjs);

            // AMP, turned on for all ucsf now
            if (Page.Theme.Equals("UCSF") && UCSFIDSet.ByNodeId.ContainsKey(base.RDFTriple.Subject) && 
                HttpContext.Current.Request.Url.ToString().ToLower().Equals(UCSFIDSet.ByNodeId[base.RDFTriple.Subject].PrettyURL))
            {
                HtmlLink AmpLink = new HtmlLink();
                AmpLink.Href = UCSFIDSet.ByNodeId[base.RDFTriple.Subject].PrettyURL.Replace(Brand.GetThemedDomain(),  "https://amp.profiles.ucsf.edu");
                AmpLink.Attributes["rel"] = "amphtml";
                Page.Header.Controls.Add(AmpLink);
            }
        }

        public void LoadPresentationXML()
        {
            Profiles.Profile.Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            this.PresentationXML = data.GetPresentationData(this.RDFTriple);
            this.masterpage.CanEdit = data.canEdit(this.RDFTriple);
        }

        public XmlDocument PresentationXML { get; set; }
        public Profiles.Framework.Template Master { get; set; }

    }
}
