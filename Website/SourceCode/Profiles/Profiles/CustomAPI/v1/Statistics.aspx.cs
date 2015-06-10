using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Statistics : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
        Response.ContentType = "application/json";
        Response.Write(new Profiles.CustomAPI.Utilities.DataIO().GetAllAsJSON());
    }

}
