﻿using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Xml;

using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules.CustomViewPersonSameDepartment
{
    public partial class CustomViewPersonSameDepartment : BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {

            DrawProfilesModule();
        }

        public CustomViewPersonSameDepartment() : base() { }
        public CustomViewPersonSameDepartment(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            base.RDFTriple = new RDFTriple(Convert.ToInt64(Request.QueryString["Subject"]));

        }
        private void DrawProfilesModule()
        {
            Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            Search.Utilities.DataIO search = new Profiles.Search.Utilities.DataIO();

            XmlDocument xml = data.GetSameDepartment(base.RDFTriple);
            List<ListItem> items = new List<ListItem>();


            if (xml.SelectSingleNode("Network/NumberOfConnections").InnerText != "0")
            {
                string departmenturi = xml.SelectSingleNode("Network/DepartmentURI").InnerText;
                string insitutitionuri = xml.SelectSingleNode("Network/InstitutionURI").InnerText;
                string searchrequest = string.Empty;

                search.SearchRequest("", "", "", "", insitutitionuri, "", departmenturi, "", "", "", "http://xmlns.com/foaf/0.1/Person", "25", "0", "", "", "","", false, ref searchrequest);

                this.SearchRequest = searchrequest;

                foreach (XmlNode n in xml.SelectNodes("Network/Connection"))
                {
                    items.Add(new ListItem(n.InnerText, n.SelectSingleNode("@URI").Value, n.SelectSingleNode("@NodeID").Value));

                }

                rptSameDepartment.DataSource = items;
                rptSameDepartment.DataBind();

            }
            else
            {
                rptSameDepartment.Visible = false;
            }

        }

        protected void SameDepartmentItemBound(object sender, RepeaterItemEventArgs e)
        {
            ListItem x = (ListItem)e.Item.DataItem;
            Image img = (Image)e.Item.FindControl("imgQuestion");

            if (img != null)
            {
                img.ImageUrl = Brand.GetThemedDomain() + "/Framework/Images/info.png";
                img.Width = 11;
                img.Height = 11;
            }
            Literal litListItem = (Literal)e.Item.FindControl("litListItem");
            if (litListItem != null)
                litListItem.Text = "<li><a href='" + x.URI + "'>" + "<div class='thumbnail'><img src='" + Brand.GetThemedDomain() + 
                    //"/PhotoHandler.jpg?NodeID=" + x.NodeID + "' width='15' height='30'></img></div>" +
                    "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=" + x.NodeID + "&Thumbnail=True&Width=15' width='15' height='30'></img></div>" + 
                    x.Name + "</a></li>";

            if (e.Item.ItemType == ListItemType.Footer)
            {
                Literal litFooter = (Literal)e.Item.FindControl("litFooter");
                //HyperLink moreurl = (HyperLink)e.Item.FindControl("moreurl");
                litFooter.Text = "<a href='" + Brand.GetThemedDomain() + "/search/default.aspx?searchtype=people&searchfor=&SearchRequest=" + this.SearchRequest + "' class='dblarrow'>Search Department</a>";
            }

        }

        public string SearchRequest { get; set; }

        public class ListItem
        {
            public ListItem(string name, string uri, string nodeId)
            {
                Name = name;
                URI = uri;
                NodeID = nodeId;
            }
            public string Name { get; set; }
            public string URI { get; set; }
            public string NodeID { get; set; }
        }


    }
}