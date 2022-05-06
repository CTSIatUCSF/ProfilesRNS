using System;
using Profiles.Framework.Utilities;
using System.Xml;
using System.Collections.Generic;
using System.Web.UI.HtmlControls;

namespace Profiles.Profile.Modules.CustomViewUCSFPlugins
{
    public partial class UCSFFeaturedVideos : BaseUCSFModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            

        }
        public UCSFFeaturedVideos() : base() {}
        public UCSFFeaturedVideos(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {   
            LoadAssets();
        }


        private void LoadAssets()
        {
            HtmlGenericControl jsscript1 = new HtmlGenericControl("script");
            jsscript1.Attributes.Add("type", "text/javascript");
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/jquery.validate.min.js");
            Page.Header.Controls.Add(jsscript1);

            HtmlGenericControl jsscript2 = new HtmlGenericControl("script");
            jsscript2.Attributes.Add("type", "text/javascript");
            jsscript2.Attributes.Add("src", "https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/2.0.0/handlebars.min.js");
            Page.Header.Controls.Add(jsscript2);

            HtmlGenericControl jsscript3 = new HtmlGenericControl("script");
            jsscript3.Attributes.Add("type", "text/javascript");
            jsscript3.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/CustomViewUCSFPlugins/UCSFFeaturedVideos.js");
            Page.Header.Controls.Add(jsscript3);

            //this.PlugInName = "FeaturedVideos";
            //litjs.Text = base.SocialMediaInit(this.PlugInName);
            //TODO Obviously change this 
            //litjs.Text = base.jsStart + "FeaturedVideos.init('" + Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "UCSFFeaturedVideos").Replace("'", "\\'") + "'); " + base.jsEnd;
            litjs.Text = base.jsStart + "FeaturedVideos.init('" + Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, "UCSFFeaturedVideos").Replace("\\", "\\\\").Replace("'", "\\'") + "'); " + base.jsEnd;


            HtmlLink Displaycss = new HtmlLink();
            Displaycss.Href = Brand.GetThemedDomain() + "/Profile/Modules/CustomViewSocialMediaPlugins/style.css";
            Displaycss.Attributes["rel"] = "stylesheet";
            Displaycss.Attributes["type"] = "text/css";
            Displaycss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Displaycss);

        }

    }
}