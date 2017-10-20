/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using System.Configuration;

using Profiles.Login.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.Login.Modules.MultiShibLogin
{
    public partial class MultiShibLogin : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            if (!IsPostBack)
            {
                HttpContext.Current.Session["multiShibLoginTarget"] = Request["target"];
            }

        }

        public MultiShibLogin() { }

        public MultiShibLogin(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
        }

        protected void cmdSubmit_Click(object sender, EventArgs e)
        {

            Response.Redirect("https://" + Request.Url.Host + "/Shibboleth.sso/Login?entityID=" + 
                ((ImageButton)sender).Attributes["EntityID"] + "&target=" + HttpUtility.UrlEncode(HttpContext.Current.Session["multiShibLoginTarget"].ToString()));
        }


    }
}