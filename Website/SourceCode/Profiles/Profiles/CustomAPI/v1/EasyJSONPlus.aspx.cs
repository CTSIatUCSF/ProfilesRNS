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
using System.Web.Script.Serialization;
using Profiles.Framework.Utilities;

using Profiles.Profile.Utilities;

namespace Profiles.CustomAPI
{
    public partial class EasyJSONPlus : System.Web.UI.Page
    {
        // add smart caching of all of these ID lookups!
        protected void Page_Load(object sender, EventArgs e)
        {
            Profiles.CustomAPI.Utilities.DataIO data = new Profiles.CustomAPI.Utilities.DataIO();
            UCSFIDSet person = data.GetPerson(Request);

            if (person == null)
            {
                Response.StatusCode = 404;
                return;
            }
            else
            {
                String URL = "http://api.profiles.ucsf.edu/json/v2/?ProfilesURLName=" +
                    person.PrettyURL + "&source=EasyJSONPlusAPI&publications=full";
                HttpWebRequest myReq = (HttpWebRequest)WebRequest.Create(URL);
                myReq.Accept = "application/json"; // "application/ld+json";
                String jsonProfiles = "";
                using (StreamReader sr = new StreamReader(myReq.GetResponse().GetResponseStream()))
                {
                    jsonProfiles = sr.ReadToEnd();
                }

                List<Dictionary<string, object>> rejected = data.GetRejectedPMIDsAsJSON(person.PersonId);
                // serialize this and stitch it in somehow
                JavaScriptSerializer serializer = new JavaScriptSerializer();
                Dictionary<string, object> easyjsonperson = (Dictionary<string, object>)serializer.DeserializeObject(jsonProfiles);

                if (rejected.Count > 0)
                {
                    Dictionary<string, object> profile = (Dictionary<string, object>)((object[])easyjsonperson["Profiles"])[0];
                    profile["RejectedPublications"] = rejected;
                }

                Response.Clear();
                Response.StatusCode = 200;
                Response.Charset = "charset=UTF-8";
                Response.ContentType = "application/json";
                Response.Write(serializer.Serialize(easyjsonperson));
            }
        }
    }
}
