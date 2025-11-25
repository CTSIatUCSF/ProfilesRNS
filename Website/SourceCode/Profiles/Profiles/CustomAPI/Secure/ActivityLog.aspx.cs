using CsvHelper;
using Profiles.Framework.Utilities;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace Profiles.CustomAPI.Secure
{
    public partial class ActivityLog : BrandedPage
    {
        private static string profilesdb = (new Profiles.Framework.Utilities.DataIO()).GetConnectionString();

        protected void Page_Load(object sender, EventArgs e)
        {
            Profiles.CustomAPI.Utilities.DataIO data = new Profiles.CustomAPI.Utilities.DataIO();

            Response.ContentType = "text/plain";
            if (!data.IsAllowedSecureAccess(Request))
            {
                Response.Write("Access Denied");
                return;
            }
            string methodName = Request["MethodName"];
            string afterDate = Request["AfterDate"];
            Institution institution = Brand.GetCurrentBrand().GetInstitution();

            using (SqlConnection conn = new SqlConnection(profilesdb)) 
            {
                conn.Open();
                SqlCommand dbcommand = new SqlCommand("[UCSF.].[ReadActivityLog]", conn);
                dbcommand.CommandType = CommandType.StoredProcedure;
                dbcommand.Parameters.Add(methodName != null ? new SqlParameter("@methodName", methodName) : new SqlParameter("@methodName", DBNull.Value));
                dbcommand.Parameters.Add(institution != null ? new SqlParameter("@institutionAbbreviation", institution.GetAbbreviation()) : new SqlParameter("@institutionAbbreviation", DBNull.Value));
                dbcommand.Parameters.Add(afterDate != null ? new SqlParameter("@afterDT", afterDate) : new SqlParameter("@afterDT", DBNull.Value));
                using (SqlDataReader dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    CsvWriter writer = new CsvWriter(Response.Output, CultureInfo.InvariantCulture);
                    while (dbreader.Read())
                    {
                        writer.WriteField(dbreader.GetInt32(0));
                        writer.WriteField(dbreader[1].ToString());
                        writer.WriteField(dbreader[2].ToString());
                        writer.WriteField(dbreader[3].ToString());
                        writer.WriteField(dbreader.GetDateTime(4));
                        writer.WriteField(dbreader[5].ToString());
                        writer.WriteField(dbreader[6].ToString());
                        writer.WriteField(dbreader[7].ToString());
                        writer.NextRecord();
                    }
                    Response.Output.Flush();
                }
            }
        }
    }
}