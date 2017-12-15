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

namespace Profiles.CustomAPI.v2
{
    public partial class Disambiguate : BrandedPage
    {

        private static readonly Dictionary<string, string> NameSwapsRaw = new Dictionary<string, string>
        {
            { "Tom", "Thomas" },
            { "Rick", "Frederick" }
        };

        private static Dictionary<string, string> NameSwaps = new Dictionary<string, string>();

        static Disambiguate()
        {
            // double map everything and pad with white space, so "Tom " now returens "Thomas " and "Thomas " return "Tom "
            foreach (string keyName in NameSwapsRaw.Keys)
            {
                NameSwaps[keyName + " "] = NameSwapsRaw[keyName] + " ";
                NameSwaps[NameSwapsRaw[keyName] + " "] = keyName + " ";
            }
        }

        // add smart caching of all of these ID lookups!
        protected void Page_Load(object sender, EventArgs e)
        {

            Institution inst = Institution.GetByAbbreviation(Request["institution"].ToUpper());
            string name = Request["name"];

            string uri = find(inst, name);
            if (uri == null)
            {
                foreach (string keyName in NameSwaps.Keys)
                {
                    if (name.Contains(keyName))
                    {
                        uri = find(inst, name.Replace(keyName, NameSwaps[keyName]));
                        if (uri != null)
                        {
                            break;
                        }
                    }
                }
            }

            JavaScriptSerializer serializer = new JavaScriptSerializer();

            Dictionary<string, string> easyjsonperson = new Dictionary<string, string>();
            if (uri != null)
            {
                easyjsonperson.Add("URI", uri);
                Int64 nodeId = Int64.Parse(uri.Split('/')[uri.Split('/').Length - 1]);
                easyjsonperson.Add("URL", UCSFIDSet.ByNodeId[nodeId].PrettyURL);
            }

            Response.StatusCode = 200;
            Response.Charset = "charset=UTF-8";
            Response.ContentType = "application/json";
            Response.Write(serializer.Serialize(easyjsonperson)); 
        }

        private string find(Institution inst, string name)
        {
            // try with full name
            string uri = search(inst, name, false);
            char[] splintOn = { ' ', '-' };
            if (uri == null && name.Split(splintOn).Length >= 3)
            {
                // had a middle name or initial, try dropping it
                uri = search(inst, name.Split(splintOn)[0] + " " + name.Split(' ')[name.Split(splintOn).Length - 1], false);
            }
            if (uri == null)
            {
                // try just last name
                uri = search(inst, name.Split(splintOn)[name.Split(splintOn).Length - 1], true);
            }
            if (uri == null)
            {
                // try just first name
                uri = search(inst, name.Split(splintOn)[0], true);
            }

            return uri;
        }

        private string search(Institution inst, string name, bool forceUnique)
        {
            string searchrequest = String.Empty;
            Profiles.Search.Utilities.DataIO data = new Profiles.Search.Utilities.DataIO();
            XmlDocument searchRequest = data.SearchRequest(name.Replace("'", ""), "false", "", "", inst.GetURI(), "", "", "", "", "", "http://xmlns.com/foaf/0.1/Person", "15", "0", "", "", "", "", ref searchrequest);
            XmlDocument searchResult = data.Search(searchRequest, false);

            string retval = null;
            Namespace rdfnamespaces = new Namespace();
            foreach (XmlNode fullNameNode in searchResult.SelectNodes("rdf:RDF/rdf:Description/prns:fullName", rdfnamespaces.LoadNamespaces(searchResult)))
            {
                string fullName = fullNameNode.InnerText.ToUpper();

                XmlNode foundPerson = fullNameNode.ParentNode;
                string lastName = foundPerson.SelectSingleNode("foaf:lastName", rdfnamespaces.LoadNamespaces(searchResult)).InnerText.ToUpper();
                string firstName = foundPerson.SelectSingleNode("foaf:firstName", rdfnamespaces.LoadNamespaces(searchResult)).InnerText.ToUpper();

                if (fullName.Contains(name.ToUpper()) || name.ToUpper().Contains(lastName) || name.ToUpper().Contains(firstName))
                {
                    if (!forceUnique)
                    {
                        return foundPerson.Attributes["rdf:about"].Value;
                    }
                    else 
                    {
                        // we searched on one name alone, only return a postive hit if you have just one person
                        if (retval == null)
                        {
                            retval = foundPerson.Attributes["rdf:about"].Value;
                        }
                        else
                        {
                            return null;
                        }
                    }
                }
            }
            return retval;
        }
    }
}
