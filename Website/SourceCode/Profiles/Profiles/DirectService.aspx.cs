using System;
using Profiles.Framework.Utilities;

namespace Profiles
{
    public partial class DirectService : BrandedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Server.Transfer("~/DIRECT/Modules/DirectSearch/DirectService.aspx?Request=" + Request.QueryString["Request"] + "&SearchPhrase=" + Request.QueryString["SearchPhrase"]);
            Response.End();


        }
    }
}
