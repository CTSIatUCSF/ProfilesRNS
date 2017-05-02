using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using Profiles.Activity.Utilities;

public partial class EditedCount : Profiles.Framework.Utilities.BrandedPage
{

    protected void Page_Load(object sender, EventArgs e)
    {
        DataIO data = new DataIO();
        Response.Write(data.GetEditedCount());
    }

}
