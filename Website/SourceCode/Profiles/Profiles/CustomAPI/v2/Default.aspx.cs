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
using System.Net;
using System.IO;
using System.Text;
using System.Runtime.Serialization;
using System.Configuration;
using Profiles.Framework.Utilities;

using Profiles.Profile.Utilities;

namespace Profiles.CustomAPI.v2
{
    public partial class Default : BrandedPage
    {
        // add smart caching of all of these ID lookups!
        protected void Page_Load(object sender, EventArgs e)
        {
            Profiles.CustomAPI.Utilities.DataIO data = new Profiles.CustomAPI.Utilities.DataIO();
            UCSFIDSet person = data.GetPerson(Request);

            Response.Clear();
            if (person == null)
            {
                Response.StatusCode = 404;
                return;
            }
            Response.StatusCode = 200;
            Response.Charset = "charset=UTF-8";

            RDFTriple request = new RDFTriple(person.NodeId);
            string Expand = Request["Expand"];
            string ShowDetails = Request["ShowDetails"];
            string callback = Request["callback"];

            //The system default is True and True for showdetails and expand, but if its an external page call to this page, 
            //then its set to false for expand.           
            if (Expand != null)
            {
                request.Expand = Convert.ToBoolean(Expand);
            }
            else
            {
                request.Expand = false;
            }


            if (ShowDetails != null)
            {
                request.ShowDetails = Convert.ToBoolean(ShowDetails);
            }
            else
            {
                request.ShowDetails = false;
            }

            if ("JSON-LD".Equals(Request["Format"]))
            {
                string URL = ConfigurationManager.AppSettings["OpenSocial.ShindigURL"] + "/rest/rdf?userId=" +
                    HttpUtility.UrlEncode(Brand.GetDomain() + "/CustomAPI/v2/Default.aspx?Subject=" + person.NodeId + "&Expand=" + request.Expand + "&ShowDetails=" + request.ShowDetails);
                WebClient client = new WebClient();
                String jsonProfiles = client.DownloadString(URL);
                if (callback != null && callback.Length > 0)
                {
                    Response.ContentType = "application/javascript";
                    Response.Write(callback + "(" + jsonProfiles + ");");
                }
                else
                {
                    Response.ContentType = "application/json";
                    Response.Write(jsonProfiles);
                }
            }
            else
            {
                Response.ContentType = "text/xml";//"application/rdf+xml";
                Response.Write(new Profiles.Profile.Utilities.DataIO().GetRDFData(new RDFTriple(person.NodeId)).InnerXml);
            }
        }

        [System.Web.Services.WebMethod]
        public static string Disambiguate(string institution, string name)
        {
            Institution inst = Institution.GetByAbbreviation(institution);

            string searchrequest = String.Empty;
            Profiles.Search.Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();
            XmlDocument searchRequest = data.SearchRequest(name, "", "", "", inst.GetURI(), "", "", "", "", "", "http://xmlns.com/foaf/0.1/Person", "15", "0", "", "", "", "", ref searchrequest);
            XmlDocument searchResult = data.Search(searchRequest, false);
            return searchResult.InnerXml;
        }
    
    
    
    }
}
