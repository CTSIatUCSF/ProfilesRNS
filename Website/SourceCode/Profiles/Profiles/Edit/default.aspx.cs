/*  
 
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
using Profiles.Framework.Utilities;

namespace Profiles.Edit
{
    public partial class _default : BrandedPage
    {
        private Profiles.Framework.Template masterpage;

        override protected void OnInit(EventArgs e)
        {

            SessionManagement session = new SessionManagement();
            
            masterpage = (Framework.Template)base.Master;
            this.Master = masterpage;

            this.LoadAssets();

            if (Request.QueryString["subject"] != null)
            {


                this.RDFTriple = new RDFTriple(Convert.ToInt64(Request.QueryString["subject"]));
                this.RDFTriple.Edit = true;
                this.RDFTriple.Predicate = 0;
                this.RDFTriple.Expand = false;
                this.RDFTriple.Object = 0;
                this.RDFTriple.ShowDetails = true;


                session.RDFTriple = this.RDFTriple;
                session.ClearEditSession();

            }
            else
            {
                this.RDFTriple = session.RDFTriple;
            }

            this.LoadPageData();

            if (this.PresentationXML.SelectSingleNode("Presentation/PageOptions[@CanEdit='true']") == null)
                Response.Redirect(Brand.GetThemedDomain() + "/search");

            //masterpage.Tab = base.Tab;
            masterpage.RDFData = this.RDFData;
            masterpage.RDFNamespaces = this.RDFNamespaces;
            masterpage.PresentationXML = this.PresentationXML;
        }

        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "edit");

//            this.Master.FindControl("pnlNavBarSearch").Visible = false;

            HtmlLink Displaycss = new HtmlLink();
            Displaycss.Href = Brand.GetThemedDomain() + "/Profile/CSS/display.css";
            Displaycss.Attributes["rel"] = "stylesheet";
            Displaycss.Attributes["type"] = "text/css";
            Displaycss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Displaycss);

            // This should get included automatically, but isn't working for Edit for some reason
            HtmlLink ThemeCss = new HtmlLink();
            //ThemeCss.Href = Root.GetThemedFile(Page, "Search/CSS/Theme.css");
            ThemeCss.Href = Brand.GetThemedDomain() + "/App_Themes/" + Page.Theme + "/" + Page.Theme + ".css";
            ThemeCss.Attributes["rel"] = "stylesheet";
            ThemeCss.Attributes["type"] = "text/css";
            ThemeCss.Attributes["media"] = "all";
            Page.Header.Controls.Add(ThemeCss); 
            
            HtmlGenericControl UCSFjs = new HtmlGenericControl("script");
            UCSFjs.Attributes.Add("type", "text/javascript");
            UCSFjs.Attributes.Add("src", Brand.GetThemedDomain() + "/Edit/JavaScript/UCSF.js");
            Page.Header.Controls.Add(UCSFjs);
        }

        public void LoadPageData()
        {
            Framework.Utilities.Namespace namespaces = new Namespace();

            Profiles.Profile.Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            this.PresentationXML = data.GetPresentationData(this.RDFTriple);

            XmlNode x = this.PresentationXML.SelectSingleNode("Presentation[1]/ExpandRDFList[1]");

            if (x != null)
                this.RDFTriple.ExpandRDFList = x.OuterXml;

            this.RDFData = data.GetRDFData(this.RDFTriple);



            this.RDFNamespaces = namespaces.LoadNamespaces(this.RDFData);
        }
        public XmlDocument PresentationXML { get; set; }
        public Profiles.Framework.Template Master { get; set; }
        public Int64 Subject { get; set; }
        public RDFTriple RDFTriple { get; set; }
        public XmlDocument RDFData { get; set; }
        public XmlNamespaceManager RDFNamespaces { get; set; }




    }
}
