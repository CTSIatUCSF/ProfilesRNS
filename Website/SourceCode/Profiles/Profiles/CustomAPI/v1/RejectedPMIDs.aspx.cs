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

namespace Profiles.CustomAPI
{
    public partial class RejectedPMIDs : System.Web.UI.Page
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
            Response.ContentType = "text/html";
            Response.Write(data.GetRejectedPMIDs(person.PersonId));
        }
    }
}
