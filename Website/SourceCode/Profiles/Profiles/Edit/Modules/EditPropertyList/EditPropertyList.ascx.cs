/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Text;
using System.Xml;
using System.Configuration;
using Profiles.Framework.Utilities;
using Profiles.ORNG.Utilities;
using System.Data.SqlClient;

namespace Profiles.Edit.Modules.EditPropertyList
{
    public partial class EditPropertyList : BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }

        public EditPropertyList() : base() { }
        public EditPropertyList(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            imgLock.ImageUrl = Brand.GetThemedDomain() + "/edit/images/icons_lock.gif";
        }

        private void DrawProfilesModule()
        {
            List<GenericListItem> gli = new List<GenericListItem>();
            bool canedit = false;
            Profile.Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            List<List<SecurityItem>> si = new List<List<SecurityItem>>();
            List<SecurityItem> singlesi;
            this.Dropdown = new List<GenericListItem>();
            this.PropertyList = data.GetPropertyList(this.BaseData, base.PresentationXML, "", true, true, false);

            this.Subject = Convert.ToInt64(Request.QueryString["subject"]);

            this.SecurityGroups = new XmlDocument();
            this.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);

            litBackLink.Text = "<h2>Edit Menu</h2>";

            foreach (XmlNode group in this.PropertyList.SelectNodes("//PropertyList/PropertyGroup"))
            {
                // Skip ORNG if gadgets are turned off
                if ("http://orng.info/ontology/orng#PropertyGroupORNGApplications".Equals(group.SelectSingleNode("@URI").Value) && !ORNGSettings.getSettings().Enabled)
                {
                    continue;
                }
                singlesi = new List<SecurityItem>();

                foreach (XmlNode node in group.SelectNodes("Property"))
                {
                    // for multi institutional implementations. If an ORNG gadget is scoped to an institution that this user does not belong to, remove it
                    if (node.SelectSingleNode("@URI").Value.StartsWith(Profiles.ORNG.Utilities.OpenSocialManager.ORNG_ONTOLOGY_PREFIX)) 
                    {
                        GadgetSpec spec = OpenSocialManager.GetGadgetByPropertyURI(node.SelectSingleNode("@URI").Value);
                        if (spec != null && !spec.IsVisibleFor(UCSFIDSet.ByNodeId.ContainsKey(Subject) ? UCSFIDSet.ByNodeId[Subject].Institution : null))
                        {
                            continue;
                        }
                    }
                    // plugins http://profiles.catalyst.harvard.edu/ontology/plugins!GlobalHealthEquity
                    else if (node.SelectSingleNode("@URI").Value.StartsWith("http://profiles.catalyst.harvard.edu/ontology/plugins"))
                    {
                        if (!Institution.IsPluginAllowedFor(node.SelectSingleNode("@URI").Value.Substring("http://profiles.catalyst.harvard.edu/ontology/plugins".Length + 1), UCSFIDSet.ByNodeId[Subject].Institution) )
                        {
                            continue;
                        }
                    }

                    // skip mailing address for UCLA
                    if (node.SelectSingleNode("@URI").Value.StartsWith("http://vivoweb.org/ontology/core#mailingAddress") && UCSFIDSet.ByNodeId[Subject].Institution != null && "UCLA".Equals(UCSFIDSet.ByNodeId[Subject].Institution.GetAbbreviation()))
                    {
                        continue;
                    }

                    if (node.SelectSingleNode("@EditExisting").Value == "false"
                        && node.SelectSingleNode("@EditAddExisting").Value == "false"
                        && node.SelectSingleNode("@EditAddNew").Value == "false"
                        && node.SelectSingleNode("@EditDelete").Value == "false")
                    {
                        canedit = false;
                    }
                    else
                    {
                        canedit = true;
                    }

                    string objecttype = string.Empty;
                    switch (node.SelectSingleNode("@ObjectType").Value)
                    {
                        case "1":
                            objecttype = "Literal";
                            break;
                        case "0":
                            objecttype = "Entity";
                            break;
                    }

                    string editlink = "<a class=listTableLink href=\"" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + this.Subject.ToString() + "&predicateuri=" + node.SelectSingleNode("@URI").Value.Replace("#", "!") + "&module=DisplayItemToEdit&ObjectType=" + objecttype + "\" >" + node.SelectSingleNode("@Label").Value + "</a>";

                    singlesi.Add(new SecurityItem(node.ParentNode.SelectSingleNode("@Label").Value, node.SelectSingleNode("@Label").Value,
                        node.SelectSingleNode("@URI").Value,
                        Convert.ToInt32(node.SelectSingleNode("@NumberOfConnections").Value),
                        Convert.ToInt32(node.SelectSingleNode("@ViewSecurityGroup").Value),
                        this.SecurityGroups.SelectSingleNode("SecurityGroupList/SecurityGroup[@ID='" + node.SelectSingleNode("@ViewSecurityGroup").Value + "']/@Label").Value,
                        node.SelectSingleNode("@ObjectType").Value, canedit, editlink));
                }
                si.Add(singlesi);
            }

            // only show Name and Degress if it is a person
            pnlShowNameAndDegrees.Visible = UCSFIDSet.IsPerson(this.Subject);

            // add one for "Not Added"
            gli.Add(new GenericListItem("Not Added", "This item has not been added to your " + (UCSFIDSet.IsPerson(this.Subject) ? "Profile" : "group") + " page."));
            foreach (XmlNode securityitem in this.SecurityGroups.SelectNodes("SecurityGroupList/SecurityGroup"))
            {
                this.Dropdown.Add(new GenericListItem(securityitem.SelectSingleNode("@Label").Value,
                    securityitem.SelectSingleNode("@ID").Value));

                gli.Add(new GenericListItem(securityitem.SelectSingleNode("@Label").Value, securityitem.SelectSingleNode("@Description").Value));
            }

            repPropertyGroups.DataSource = si;
            repPropertyGroups.DataBind();

            BuildSecurityKey(gli);
            if (!String.IsNullOrEmpty(ConfigurationSettings.AppSettings["HR_NameServiceURL"]))
            {
                // only used by UCSD at the moment
                // Why did we do this as a lite
                hypEditHRDataLink.Visible = true;
                hypEditHRDataLink.NavigateUrl = ConfigurationSettings.AppSettings["HR_NameServiceURL"] +
                    //http://ctripro.ucsd.edu/ProfilesCR/PersonalDataChangeRequest.php?id=" 
                UCSFIDSet.ByNodeId[this.Subject].UserName;
            }
        }

        protected void repPropertyGroups_OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.AlternatingItem || e.Item.ItemType == ListItemType.Item)
            {
                GridView grdSecurityGroups = (GridView)e.Item.FindControl("grdSecurityGroups");
                List<SecurityItem> si = (List<SecurityItem>)e.Item.DataItem;
                grdSecurityGroups.DataSource = si;
                grdSecurityGroups.DataBind();
                grdSecurityGroups.HeaderRow.Cells[0].Text = "<b>Category</b>: " + si[0].ItemLabel;
            }

        }
        protected void grdSecurityGroups_OnDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {

                DropDownList ddl = (DropDownList)e.Row.FindControl("ddlPrivacySettings");
                HiddenField hf = (HiddenField)e.Row.FindControl("hfPropertyURI");
                Label items = (Label)e.Row.FindControl("lblItems");
                Image lockimage = (Image)e.Row.FindControl("imgLock");
                Image blankimage = (Image)e.Row.FindControl("imgBlank");
                SecurityItem si = (SecurityItem)e.Row.DataItem;
                LinkButton lb = (LinkButton)e.Row.FindControl("lbUpdate");
                Literal litSetting = (Literal)e.Row.FindControl("litSetting");

                string objecttype = string.Empty;

                items.Text = si.ItemCount.ToString();

                if (!si.CanEdit)
                {
                    lockimage.Visible = true;
                    blankimage.Visible = true;
                }

                ddl.DataSource = this.Dropdown;
                ddl.DataTextField = "Text";
                ddl.DataValueField = "Value";
                ddl.DataBind();
                ddl.SelectedValue = si.PrivacyCode.ToString();
                ddl.Visible = false;

                // this is a double hack by UCSF 
                if (si.ItemURI.Equals("http://profiles.catalyst.harvard.edu/ontology/prns#hasGroupSettings"))
                {
                    SqlDataReader reader = new Profiles.Edit.Utilities.DataIO().GetGroup(Subject);
                    reader.Read();
                    litSetting.Text = reader["ViewSecurityGroupName"].ToString() + " " + String.Format("{0:M/d/yyyy}", Convert.ToDateTime(reader["EndDate"]));
                    reader.Close();
                }
                else if (si.ItemURI.Equals("http://profiles.catalyst.harvard.edu/ontology/prns#hasGroupManager") ||
                         si.ItemURI.Equals("http://vivoweb.org/ontology/core#contributingRole"))
                {
                    litSetting.Text = "";
                }
                else
                {
                    litSetting.Text = si.ItemCount > 0 ? si.PrivacyLevel : "Not Added";
                }

                //ddl.Attributes.Add("onchange", "JavaScript:showstatus()");
                hf.Value = si.ItemURI;
                if (si.ItemURI.StartsWith(Profiles.ORNG.Utilities.OpenSocialManager.ORNG_ONTOLOGY_PREFIX))
                {
                    ((Control)e.Row.FindControl("imgOrng")).Visible = true ;
                }


                switch (si.ObjectType)
                {
                    case "1":
                        objecttype = "Literal";
                        break;
                    case "0":
                        objecttype = "Entity";
                        break;
                }

                string editlink = "javascript:GoTo('" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + this.Subject.ToString() + "&predicateuri=" + hf.Value.Replace("#", "!") + "&module=DisplayItemToEdit&ObjectType=" + objecttype + "')";

                if (e.Row.RowState == DataControlRowState.Alternate)
                {
                    e.Row.Attributes.Add("onmouseover", "doListTableRowOver(this);");
                    e.Row.Attributes.Add("onmouseout", "doListTableRowOut(this,0);");
                    e.Row.Attributes.Add("onfocus", "doListTableRowOver(this);");
                    e.Row.Attributes.Add("onblur", "doListTableRowOut(this,0);");
                    e.Row.Attributes.Add("tabindex", "0");
                    e.Row.Attributes.Add("class", "evenRow");
                    e.Row.Attributes.Add("onclick", editlink);
                    e.Row.Attributes.Add("onkeypress", "if (event.keyCode == 13) " + editlink);
                    blankimage.ImageUrl = Brand.GetThemedDomain() + "/edit/images/icons_blankAlt.gif";
                    blankimage.Attributes.Add("style", "opacity:0.0;filter:alpha(opacity=0);");
                }
                else
                {
                    e.Row.Attributes.Add("onmouseover", "doListTableRowOver(this);");
                    e.Row.Attributes.Add("onmouseout", "doListTableRowOut(this,1);");
                    e.Row.Attributes.Add("onfocus", "doListTableRowOver(this);");
                    e.Row.Attributes.Add("onblur", "doListTableRowOut(this,1);");
                    e.Row.Attributes.Add("tabindex", "0");
                    e.Row.Attributes.Add("class", "oddRow");
                    e.Row.Attributes.Add("onclick", editlink);
                    e.Row.Attributes.Add("onkeypress", "if (event.keyCode == 13) " + editlink);
                    blankimage.ImageUrl = Brand.GetThemedDomain() + "/edit/images/icons_blankAlt.gif";
                    blankimage.Attributes.Add("style", "opacity:0.0;filter:alpha(opacity=0);");
                }

                e.Row.Cells[1].CssClass = "colItemCnt";
                e.Row.Cells[2].CssClass = "colSecurity";

            }

        }
        protected void BuildSecurityKey(List<GenericListItem> gli)
        {
            System.Text.StringBuilder table = new StringBuilder();                        
            
            //<AlternatingRowStyle CssClass="evenRow" />

            table.Append("<table style='width:100%;'>");
            table.Append("<tr class='EditMenuTopRow' ><td style='padding-left:10px;' align='right'><b>Level</b></td><td style='padding-left:10px;' align='left'><b>Description</b></td></tr>");

            foreach (GenericListItem item in gli)
            {
                table.Append("<tr>");
                table.Append("<td class='height25' style='padding-left:6px;white-space:nowrap'>");
                table.Append("<p align='right'>");
                table.Append("<b>");
                table.Append(item.Text);
                table.Append("</b>");
                table.Append("</p>");
                table.Append("</td>");
                table.Append("<td style='padding-left:10px;' align='left'>");
                table.Append(item.Value);
                table.Append("</td>");
                table.Append("</tr>");
            }

            table.Append("</table>");

            litSecurityKey.Text = table.ToString();

            //ddlSetAll.DataTextField = "Text";
            //ddlSetAll.DataValueField = "Value";
            //ddlSetAll.DataSource = this.Dropdown;            
            //ddlSetAll.DataBind();
            //ddlSetAll.Enabled = false;

            //ddlSetAll.Items.Insert(0, new ListItem("-- Select One --", String.Empty));
            //ddlSetAll.SelectedIndex = 0;

        }

        protected void ddlSetAll_IndexChanged(object sender, EventArgs e)
        {
            GridView gv;
            foreach (RepeaterItem item in repPropertyGroups.Items)
            {
                gv = (GridView)item.FindControl("grdSecurityGroups");

                foreach (GridViewRow gvr in gv.Rows)
                {
                    this.PredicateURI = ((HiddenField)gvr.FindControl("hfPropertyURI")).Value;
                    //  this.UpdateSecuritySetting(ddlSetAll.SelectedValue);
                }
            }

            Response.Redirect(Brand.GetThemedDomain() + "/edit/" + this.Subject.ToString());
        }
        protected void updateSecurity(object sender, EventArgs e)
        {
            GridViewRow grow = (GridViewRow)((Control)sender).NamingContainer;
            DropDownList hdn = (DropDownList)grow.FindControl("ddlPrivacySettings");
            HiddenField hf = (HiddenField)grow.FindControl("hfPropertyURI");
            this.PredicateURI = hf.Value;
            this.UpdateSecuritySetting(hdn.SelectedValue);
            Response.Redirect(Brand.GetThemedDomain() + "/edit/" + this.Subject.ToString());
        }

        private void UpdateSecuritySetting(string securitygroup)
        {
            Edit.Utilities.DataIO data = new Profiles.Edit.Utilities.DataIO();
            data.UpdateSecuritySetting(this.Subject, data.GetStoreNode(this.PredicateURI), Convert.ToInt32(securitygroup));
            //Framework.Utilities.Cache.AlterDependency(this.Subject.ToString());
        }

        private Int64 Subject { get; set; }
        private string PredicateURI { get; set; }


        private XmlDocument PropertyList { get; set; }
        private XmlDocument SecurityGroups { get; set; }
        private List<GenericListItem> Dropdown { get; set; }
    }

    public class SecurityItem
    {
        public SecurityItem(string itemlabel, string item, string itemuri, int itemcount, int privacycode, string privacylevel, string objecttype, bool canedit, string editLink)
        {
            
            this.ItemLabel = itemlabel;
            this.Item = item;
            this.ItemURI = itemuri;
            this.ItemCount = itemcount;
            this.PrivacyCode = privacycode;
            this.ObjectType = objecttype;
            this.CanEdit = canedit;
            this.PrivacyLevel = privacylevel;
            this.EditLink = editLink;

        }
        public string ItemLabel { get; set; }
        public string Item { get; set; }
        public string ItemURI { get; set; }
        public int ItemCount { get; set; }
        public int PrivacyCode { get; set; }
        public string PrivacyLevel { get; set; }
        public string ObjectType { get; set; }
        public bool CanEdit { get; set; }
        public string EditLink { get; set; }
    }
}
