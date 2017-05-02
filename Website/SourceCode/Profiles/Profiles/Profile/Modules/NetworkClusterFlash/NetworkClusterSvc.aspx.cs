﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Profiles.Profile.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.NetworkClusterFlash
{
    public partial class NetworkClusterSvc : BrandedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {            
            Profiles.Profile.Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();

            Profiles.Framework.Utilities.RDFTriple request = new RDFTriple(Convert.ToInt32(Request.QueryString["p"]));
			Response.ContentType = "application/xml; charset=utf-8";
            Response.Write(data.GetProfileNetworkForBrowserXML(request).InnerXml);            
        }
    }
}
