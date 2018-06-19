using System;


public partial class PubXML : Profiles.Framework.Utilities.BrandedPage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {            
            string PMID = Request["PMID"];

            if (PMID != null && PMID.Length > 0)
            {
                Response.ContentType = "text/xml";
                Response.Write(new Profiles.CustomAPI.Utilities.DataIO().ProcessPMID(PMID));
            }
        }
        catch (Exception ex)
        {
            Response.Write("ERROR" + Environment.NewLine + ex.Message + Environment.NewLine);
        }
    }
}
