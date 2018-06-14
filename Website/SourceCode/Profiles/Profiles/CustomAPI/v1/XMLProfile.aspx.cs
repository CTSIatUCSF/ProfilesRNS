using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.Common;
using Connects.Profiles.Common;
using Connects.Profiles.Service.DataContracts;
using Connects.Profiles.Utility;
using System.Web.Script.Serialization;
using Profiles.Framework.Utilities;

public partial class XMLProfile : BrandedPage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            Profiles.CustomAPI.Utilities.DataIO data = new Profiles.CustomAPI.Utilities.DataIO();
            UCSFIDSet person = data.GetPerson(Request);

            // get response text
            string xmlProfiles = "{}";
            try
            {
                if (person != null)
                {
                    xmlProfiles = GetXMLProfiles(person.PersonId);
                }
            }
            catch (Exception ex)
            {
                // do nothing
            }

            // return with proper content type
            if (xmlProfiles != null) 
            {
                {
                    Response.ContentType = "text/xml";
                    Response.Write(xmlProfiles);
                }
            }
        }
        catch (Exception ex)
        {
            Response.Write("ERROR" + Environment.NewLine + ex.Message + Environment.NewLine);
        }
    }

    private string GetXMLProfiles(int personId)
    {
        PersonList personProfileList = new Connects.Profiles.Service.ServiceImplementation.ProfileServiceAdapter().GetPersonFromPersonId(personId);
        return XmlUtilities.SerializeObject(personProfileList);
    }

}
