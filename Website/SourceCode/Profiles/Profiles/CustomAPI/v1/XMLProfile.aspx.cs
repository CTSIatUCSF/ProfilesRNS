using System;

using Connects.Profiles.Service.DataContracts;
using Connects.Profiles.Service.ServiceImplementation;
using Connects.Profiles.Utility;
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
        PersonList personProfileList = new ProfileServiceAdapter().GetPersonFromPersonId(personId);
        return XmlUtilities.SerializeObject(personProfileList);
    }

}
