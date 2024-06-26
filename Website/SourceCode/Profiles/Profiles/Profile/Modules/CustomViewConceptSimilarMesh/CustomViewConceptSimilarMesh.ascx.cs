﻿using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

using Profiles.Framework.Utilities;


namespace Profiles.Profile.Modules
{
    public partial class CustomViewConceptSimilarMesh : BaseModule
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			DrawProfilesModule();
		}

		public CustomViewConceptSimilarMesh() : base() { }
		public CustomViewConceptSimilarMesh(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
			: base(pagedata, moduleparams, pagenamespaces)
		{
			base.RDFTriple = new RDFTriple(Convert.ToInt64(Request.QueryString["Subject"]));

		}

		public void DrawProfilesModule()
		{
			var dataIO = new Profiles.Profile.Utilities.DataIO();
			StringBuilder html = new StringBuilder();		
			using (var reader = dataIO.GetConceptSimilarMesh(base.RDFTriple))
			{
				while (reader.Read())
				{
					html.AppendFormat("<li><a href='{0}'>{1}</a></li>", Brand.CleanURL(reader["ObjectURI"].ToString()), reader["DescriptorName"].ToString());
				}
				reader.Close();
			}

			// Hide section title if no Top Journals are returned
			if (html.ToString().Length == 0)
			{
				sectionTitle.Attributes.Add("style", "display: none;");
			}
			else
			{
				lineItemLiteral.Text = html.ToString();
			}			
		}
	}
}