﻿using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using Profiles.Framework.Utilities;

namespace Profiles.CustomAPI.Secure
{
    public partial class Default : BrandedPage
    {
        private static string profilesdb = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            Profiles.CustomAPI.Utilities.DataIO data = new Profiles.CustomAPI.Utilities.DataIO();

            Response.ContentType = "text/plain";
            if (!data.IsAllowedSecureAccess(Request))
            {
                Response.Write("Access Denied");
                return;
            }
            Institution institution = Brand.GetCurrentBrand().GetInstitution();
            using (SqlConnection conn = new SqlConnection(profilesdb)) 
            {
                conn.Open();
                using (SqlDataReader dbreader = new SqlCommand("SELECT internalusername, nodeid, PrettyURL from [UCSF.].vwPerson" +
                    (institution != null ? " WHERE InstitutionAbbreviation = '" + institution.GetAbbreviation() + "'" : ""), conn).ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (dbreader.Read())
                    {
                        Response.Write(dbreader[0].ToString() + ", " + dbreader[1].ToString() + ", " + dbreader[2].ToString() + Environment.NewLine);
                    }
                }
            }
        }
    }
}