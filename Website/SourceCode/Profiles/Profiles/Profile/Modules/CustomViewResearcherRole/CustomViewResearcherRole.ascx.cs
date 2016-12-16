using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using Profiles.Framework.Utilities;
using Profiles.Profile.Utilities;

namespace Profiles.Profile.Modules.CustomViewResearcherRole
{
    public partial class CustomViewResearcherRole : BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            this.FillResearchGrid(false);


        }


        public CustomViewResearcherRole() : base() { }
        public CustomViewResearcherRole(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {


            if (Request.QueryString["subject"] != null)
                this.SubjectID = Convert.ToInt64(Request.QueryString["subject"]);
            else if (base.GetRawQueryStringItem("subject") != null)
                this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));

        }
        protected void FillResearchGrid(bool refresh)
        {
            Edit.Utilities.DataIO data = new Edit.Utilities.DataIO();

            //Need RDF data for the links.           

            List<Profiles.Edit.Utilities.FundingState> fundingstate = data.GetFunding(data.GetPersonID(this.SubjectID));
            if (fundingstate.Count > 0)
            {

                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                int last = 0;

                sb.Append("<div class='basicInfo scroll'><table class='grants' width='590px' border='0' cellpadding='5px' cellspacing='3px'>");
                foreach (Profiles.Edit.Utilities.FundingState fs in fundingstate)
                {
                    last += 1;
                    AddRow(fs, ref sb);
                }
                sb.Append("</table></div>");
                litHTML.Text = sb.ToString();
            }

        }
        private void AddRow(Profiles.Edit.Utilities.FundingState fs, ref System.Text.StringBuilder sb)
        {
            string pi = string.Empty;
            string date = string.Empty;

            if(fs.PrincipalInvestigatorName!= string.Empty)
                pi = "(" + fs.PrincipalInvestigatorName + ")";

            if (fs.StartDate != "?")
                date = fs.StartDate;

            if (fs.EndDate != "?")
            {
                if (date != string.Empty)
                    date += "&nbsp;-&nbsp;" + fs.EndDate;
                else
                    date = fs.EndDate;
            }
            else if (fs.StartDate == "?" && fs.EndDate == "?")
                date = string.Empty;

            sb.Append("<tr><td>");
            if (fs.AgreementLabel != string.Empty)
                sb.Append(fs.AgreementLabel + "<br/>");
            if (fs.GrantAwardedBy != string.Empty)
                sb.Append("<span style='float:left;padding-right:10px'>" + fs.GrantAwardedBy + "</span> ");
            if (fs.FullFundingID != string.Empty)
                sb.Append("<span style='float:left'>" + fs.FullFundingID + "</span>");
            if (date != string.Empty)
                sb.Append("<span style='float:right;padding-left:10px'>" + date + "</span>");
            if (fs.RoleDescription != string.Empty)
                sb.Append("<br/>Description: " + fs.RoleDescription);
            if (fs.RoleLabel != string.Empty)
                sb.Append("<br/>Role: " + fs.RoleLabel);

            sb.Append("</td></tr>");

            litHTML.Text = sb.ToString();




        }

        private Int64 SubjectID { get; set; }
    }
}