﻿using System;
using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.NetworkRadialFlash
{
    public partial class NetworkRadialSvc : BrandedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {            
            Profiles.Profile.Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();

            Profiles.Framework.Utilities.RDFTriple request = new RDFTriple(Convert.ToInt32(Request.QueryString["p"]));            

            Response.Write(data.GetProfileNetworkForBrowserXML(request).InnerXml);            
        }
    }
}
