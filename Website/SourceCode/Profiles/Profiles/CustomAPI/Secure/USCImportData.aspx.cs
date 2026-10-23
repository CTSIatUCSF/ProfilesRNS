using CsvHelper;
using Profiles.Framework.Utilities;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;

namespace Profiles.CustomAPI.Secure
{
    public partial class USCImportData : BrandedPage
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

            using (SqlConnection conn = new SqlConnection(profilesdb)) 
            {
                //conn.Open();
                using (SqlCommand command = new SqlCommand("select * from [import_usc].[dbo].[vw_importReport]", conn))
                {
                    using (CsvWriter writer = new CsvWriter(Response.Output, CultureInfo.InvariantCulture))
                    {
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            // 1. Write headers
                            int fieldCount = reader.FieldCount;
                            for (int i = 0; i < fieldCount; i++)
                            {
                                writer.WriteField(reader.GetName(i));
                            }
                            writer.NextRecord();

                            // 2. Write data rows
                            while (reader.Read())
                            {
                                for (int i = 0; i < fieldCount; i++)
                                {
                                    writer.WriteField(reader[i].ToString());
                                }
                                writer.NextRecord();
                            }
                            Response.Output.Flush();
                        }
                    }
                }
            }
        }
    }
}