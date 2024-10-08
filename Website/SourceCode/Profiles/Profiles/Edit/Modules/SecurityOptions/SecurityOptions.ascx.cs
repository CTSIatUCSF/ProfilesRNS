﻿/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.Xml;

namespace Profiles.Edit.Modules.SecurityOptions
{
    public partial class SecurityOptions : System.Web.UI.UserControl
    {
        public event EventHandler BubbleClick;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                Session["pnlSecurityOptions.Visible"] = null;

            DrawProfilesModule();
        }

        private void DrawProfilesModule()
        {
            List<SecurityItem> si = new List<SecurityItem>();

            foreach (XmlNode securityitem in this.SecurityGroups.SelectNodes("SecurityGroupList/SecurityGroup"))
            {
                si.Add(new SecurityItem(securityitem.SelectSingleNode("@Label").Value,
                    securityitem.SelectSingleNode("@Description").Value,
                    Convert.ToInt32(securityitem.SelectSingleNode("@ID").Value)));
            }

            grdSecurityGroups.DataSource = si;
            grdSecurityGroups.DataBind();
        }
        protected void grdSecurityGroups_OnDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                SecurityItem si = (SecurityItem)e.Row.DataItem;
                RadioButton rb = (RadioButton)e.Row.FindControl("rdoSecurityOption");
                HiddenField hf = (HiddenField)e.Row.FindControl("hdnPrivacyCode");
                RadioButton rdoSecurityOption = (RadioButton)e.Row.FindControl("rdoSecurityOption");
                Literal l = (Literal) e.Row.FindControl("rdoSecurityOptionLabel");
                HiddenField hl = (HiddenField)e.Row.FindControl("hdnLabel");

                rdoSecurityOption.GroupName = "SecurityOption";

                hf.Value = si.PrivacyCode.ToString();
                l.Text = "<label for=\"" + rb.UniqueID.Replace("$", "_") + "\">" + si.Label + "</label>";
                hl.Value = si.Label;

                if (si.PrivacyCode == this.PrivacyCode)
                {
                    rb.Checked = true;
                    litVisibility.Text = "(" + si.Label + ")";
                }
                else
                {
                    rb.Checked = false;
                }
            }
        }
        protected void imbSecurityOptions_OnClick(object sender, EventArgs e)
        {
            if (Request.Form["enterkey"] != "")
            {
                Session["pnlSecurityOptions.Visible"] = true;
            }

            ToggleDisplay();

            if (BubbleClick != null)
                BubbleClick(this, e);
        }

        private void ToggleDisplay()
        {
            if (Session["pnlSecurityOptions.Visible"] == null)
            {
                pnlSecurityOptions.Visible = true;
                Session["pnlSecurityOptions.Visible"] = true;
            }
            else
            {
                pnlSecurityOptions.Visible = false;
                Session["pnlSecurityOptions.Visible"] = null;
            }
        }

        protected void rdoSecurityOption_OnCheckedChanged(object sender, EventArgs e)
        {
            Session["pnlSecurityOptions.Visible"] = null;

            //Clear the existing selected row 
            foreach (GridViewRow oldrow in grdSecurityGroups.Rows)
            {
                ((RadioButton)oldrow.FindControl("rdoSecurityOption")).Checked = false;
            }

            //Set the new selected row
            RadioButton rb = (RadioButton)sender;
            GridViewRow row = (GridViewRow)rb.NamingContainer;  
            ((RadioButton)row.FindControl("rdoSecurityOption")).Checked = true;

            litVisibility.Text = "(" + ((HiddenField)row.Cells[0].FindControl("hdnLabel")).Value + ")";
            UpdateSecuritySetting(((HiddenField)row.Cells[0].FindControl("hdnPrivacyCode")).Value);
        }

        private void UpdateSecuritySetting(string securitygroup)
        {
            Edit.Utilities.DataIO data = new Profiles.Edit.Utilities.DataIO();
            if(this.PredicateURI.Equals("http://profiles.catalyst.harvard.edu/ontology/prns#hasGroupSettings"))
            {
                data.UpdateGroupSecurity(this.Subject, Convert.ToInt32(securitygroup));
            }
            else if (this.PredicateURI.Equals("http://profiles.catalyst.harvard.edu/ontology/prns#emailEncrypted"))
            {
                if (Convert.ToInt32(securitygroup) >= -10 && Convert.ToInt32(securitygroup) < 0)
                    data.UpdateSecuritySetting(this.Subject, data.GetStoreNode("http://vivoweb.org/ontology/core#email"), -20);
                else
                    data.UpdateSecuritySetting(this.Subject, data.GetStoreNode("http://vivoweb.org/ontology/core#email"), Convert.ToInt32(securitygroup));
            }
            data.UpdateSecuritySetting(this.Subject, data.GetStoreNode(this.PredicateURI), Convert.ToInt32(securitygroup)); 
        }

        public XmlDocument SecurityGroups { get; set; }

        public Int64 Subject { get; set; }
        public string PredicateURI { get; set; }
        public int PrivacyCode { get; set; }

        public class SecurityItem
        {
            public SecurityItem(string label, string description, int privacycode)
            {
                this.Label = label;
                this.Description = description;
                this.PrivacyCode = privacycode;
            }

            public string Label { get; set; }
            public string Description { get; set; }
            public int PrivacyCode { get; set; }
        }
    }
}