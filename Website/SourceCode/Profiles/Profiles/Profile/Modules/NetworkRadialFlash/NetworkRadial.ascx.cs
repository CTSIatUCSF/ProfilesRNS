﻿using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Xml;
using System.Web.UI.HtmlControls;


using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.NetworkRadialFlash
{
    public partial class NetworkRadial : BaseModule
    {
        public NetworkRadial() { }

        public NetworkRadial(XmlDocument data, List<ModuleParams> moduleparams, XmlNamespaceManager namespaces)
            : base(data, moduleparams, namespaces)
        {


        }
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Request.QueryString["Subject"] != null)
                InitAssets();
        }
        protected void InitAssets()
        {
            System.Web.UI.HtmlControls.HtmlLink NetworkBrowsercss = new System.Web.UI.HtmlControls.HtmlLink();
            NetworkBrowsercss.Href = Brand.GetThemedDomain() + "/Profile/CSS/NetworkBrowser.css";
            NetworkBrowsercss.Attributes["rel"] = "stylesheet";
            NetworkBrowsercss.Attributes["type"] = "text/css";
            NetworkBrowsercss.Attributes["media"] = "all";
            Page.Header.Controls.Add(NetworkBrowsercss);

            HtmlGenericControl jsscript1 = new HtmlGenericControl("script");
            jsscript1.Attributes.Add("type", "text/javascript");
            jsscript1.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/NetworkRadialFlash/scriptaculous/lib/prototype.js");
            Page.Header.Controls.Add(jsscript1);

            HtmlGenericControl jsscript2 = new HtmlGenericControl("script");
            jsscript2.Attributes.Add("type", "text/javascript");
            jsscript2.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/NetworkRadialFlash/scriptaculous/src/scriptaculous.js");
            Page.Header.Controls.Add(jsscript2);

            HtmlGenericControl jsscript3 = new HtmlGenericControl("script");
            jsscript3.Attributes.Add("type", "text/javascript");
            jsscript3.Attributes.Add("src", Brand.GetThemedDomain() + "/Profile/Modules/NetworkRadialFlash/JavaScript/networkBrowserClass.js");
            Page.Header.Controls.Add(jsscript3);

            divSwfScript.InnerHtml = "<script language=\"JavaScript\" type=\"text/javascript\"> " +
               "AC_FL_RunContent(" +
               "'codebase', '//download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0'," +
               "'width', '600'," +
               "'height', '600'," +
               "'src', '" + Brand.GetThemedDomain() + "/profile/Modules/NetworkRadialFlash/network_browser.swf'," +
               "'movie', '" + Brand.GetThemedDomain() + "/profile/Modules/NetworkRadialFlash/network_browser'," +
               "'quality', 'high'," +
               "'pluginspage', '//www.adobe.com/go/getflashplayer'," +
               "'align', 'middle'," +
               "'play', 'true'," +
               "'loop', 'true'," +
               "'scale', 'showall'," +
               "'wmode', 'transparent'," +
               "'devicefont', 'false'," +
               "'id', 'network_browserFLASH'," +
               "'bgcolor', '#ffffff'," +
               "'name', 'network_browserFLASH'," +
               "'menu', 'true'," +
               "'allowFullScreen', 'false'," +
               "'allowScriptAccess', 'always'," +
               "'salign', ''" +
               "); //end AC code" +
           "</script>";

			
            HtmlGenericControl script = new HtmlGenericControl("script");
            script.Attributes.Add("type", "text/javascript");
            script.InnerHtml = "window.onload = function() {" +
				" network_browser._cfg.profile_network_path = '/"+Request.QueryString["Predicate"].ToString()+"/radial'; " +
                " network_browser.Init('" + Brand.GetThemedDomain() + "/profile/modules/NetworkRadialFlash/NetworkRadialSvc.aspx?p='); " +
                " network_browser.loadNetwork('" + Request.QueryString["Subject"].ToString() + "'); " +
                "}";
            Page.Header.Controls.Add(script);

        }

    }
}