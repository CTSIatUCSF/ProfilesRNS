/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Web;
using System.Xml;
using Profiles.Framework.Utilities;

namespace Profiles.Error
{
    public partial class Default : BrandedPage
    {
        Profiles.Framework.Template masterpage;

        protected void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;

            masterpage.Tab = "";
            masterpage.RDFData = null;
            XmlDocument presentationxml = new XmlDocument();
            string global_error = "";
            if (HttpContext.Current.Session["GLOBAL_ERROR"] != null)
            {
                global_error = HttpContext.Current.Session["GLOBAL_ERROR"].ToString();
            }
            if (global_error.Equals("HttpRequestValidationException")) presentationxml.LoadXml(XslHelper.GetThemedOrDefaultPresentationXML(Page, "HttpRequestValidationExceptionPresentation.xml"));
            else presentationxml.LoadXml(XslHelper.GetThemedOrDefaultPresentationXML(Page, "ErrorPresentation.xml"));
            masterpage.PresentationXML = presentationxml;
        }
    }
}
