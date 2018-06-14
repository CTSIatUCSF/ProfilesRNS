using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Profiles.Framework.Utilities;

namespace Profiles.Edit.Modules.CustomEditFreetextKeyword
{
    public partial class keywordAutocomplete : BrandedPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string keys = Request.QueryString["keys"];
            Profiles.Edit.Utilities.DataIO data = new Profiles.Edit.Utilities.DataIO();
            string suggestions = data.getAutoCompleteSuggestions(keys);

            litTest.Text = suggestions;
            return;
        }
    }
}