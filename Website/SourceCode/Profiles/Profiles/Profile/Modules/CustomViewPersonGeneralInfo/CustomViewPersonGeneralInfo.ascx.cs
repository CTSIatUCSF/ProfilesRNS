using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Xml;
using System.Xml.Xsl;

using Profiles.Framework.Utilities;
using Profiles.ORNG.Utilities;

namespace Profiles.Profile.Modules.CustomViewPersonGeneralInfo
{
    public partial class CustomViewPersonGeneralInfo : BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }

        public CustomViewPersonGeneralInfo() : base() { }
        public CustomViewPersonGeneralInfo(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            base.RDFTriple = new RDFTriple(Convert.ToInt64(Request.QueryString["Subject"]));

        }
        private void DrawProfilesModule()
        {

            XsltArgumentList args = new XsltArgumentList();
            XslCompiledTransform xslt = new XslCompiledTransform();
            SessionManagement sm = new SessionManagement();

            Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            string email = string.Empty;
            //string imageemailurl = string.Empty;
            string emailPlainText = string.Empty;
            string audioemailurl = string.Empty;
            if (this.BaseData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/prns:emailEncrypted", this.Namespaces) != null &&
                this.BaseData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/vivo:email", this.Namespaces) == null)
            {
                email = this.BaseData.SelectSingleNode("rdf:RDF[1]/rdf:Description[1]/prns:emailEncrypted", this.Namespaces).InnerText;
                //imageemailurl = string.Format(Brand.GetDomain() + "/profile/modules/CustomViewPersonGeneralInfo/" + "EmailHandler.ashx?msg={0}", HttpUtility.UrlEncode(email));
                emailPlainText = getEmailPlainText(email);
                audioemailurl = string.Format(Brand.GetThemedDomain() + "/profile/modules/CustomViewPersonGeneralInfo/" + "EmailAudioHandler.ashx?msg={0}", HttpUtility.UrlEncode(email));
            }
            
            args.AddParam("root", "", Brand.GetThemedDomain());
            if (email != string.Empty)
            {
                //args.AddParam("email", "", imageemailurl);
                args.AddParam("email", "", emailPlainText);
                args.AddParam("emailAudioImg", "", Brand.GetThemedDomain() + "/Framework/Images/listen.jpg");
            }
            args.AddParam("imgguid", "", Guid.NewGuid().ToString());



            if (base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/vivo:orcidId", base.Namespaces) != null) // Only show ORCID if security settings allow it
            {
                args.AddParam("orcid", "", base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/vivo:orcidId", base.Namespaces).InnerText);
                args.AddParam("orcidurl", "", Profiles.ORCID.Utilities.config.ORCID_URL + "/" + base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/vivo:orcidId", base.Namespaces).InnerText);
                string infosite;
                if (Profiles.ORCID.Utilities.config.InfoSite == null) infosite = Root.Domain + "/about/default.aspx?tab=orcid";
                else if (Profiles.ORCID.Utilities.config.InfoSite.Equals("")) infosite = Root.Domain + "/about/default.aspx?tab=orcid";
                else infosite = Profiles.ORCID.Utilities.config.InfoSite;
                args.AddParam("orcidimage", "", Brand.GetThemedDomain() + "/Framework/Images/orcid_16x16(1).gif");
                args.AddParam("orcidinfosite", "", infosite);
                args.AddParam("orcidimageguid", "", Guid.NewGuid().ToString());
            }
            else if (Profiles.ORCID.Utilities.config.ShowNoORCIDMessage && Profiles.ORCID.Utilities.config.Enabled)
            {
                    // Check for an ORCID
                string internalUsername = new Profiles.ORCID.Utilities.ProfilesRNSDLL.BLL.Profile.Data.Person().GetInternalUsername(Convert.ToInt64(Request.QueryString["Subject"]));
                Profiles.ORCID.Utilities.ProfilesRNSDLL.BO.ORCID.Person orcidPerson = new Profiles.ORCID.Utilities.ProfilesRNSDLL.BLL.ORCID.Person().GetByInternalUsername(internalUsername);
                if (!orcidPerson.Exists || orcidPerson.ORCIDIsNull)
                {
                    //args.AddParam("orcid", "", "No ORCID id has been created for this user");
                    args.AddParam("orcid", "", "Login to create your ORCID iD");
                    args.AddParam("orcidinfosite", "", Profiles.ORCID.Utilities.config.InfoSite);
                    string qs = HttpUtility.UrlEncode("predicateuri=http%3a%2f%2fvivoweb.org%2fontology%2fcore!orcidId&module=DisplayItemToEdit&ObjectType=Literal");
                    args.AddParam("orcidurl", "", Brand.GetThemedDomain() + "/login/default.aspx?method=login&edit=true&editparams=" + qs);
                    args.AddParam("orcidimage", "", Brand.GetThemedDomain() + "/Framework/Images/orcid_16x16(1).gif");
                    args.AddParam("orcidimageguid", "", Guid.NewGuid().ToString());
                   }
            }
            args.AddParam("nodeid", "", Request.QueryString["Subject"]);
            litPersonalInfo.Text = XslHelper.TransformInMemory(Server.MapPath("~/Profile/Modules/CustomViewPersonGeneralInfo/CustomViewPersonGeneralInfo.xslt"), args, base.BaseData.OuterXml);

            if (base.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[1]/prns:mainImage/@rdf:resource", base.Namespaces) != null)
            {
                string imageurl = base.BaseData.SelectSingleNode("//rdf:RDF/rdf:Description[1]/prns:mainImage/@rdf:resource", base.Namespaces).Value;
                imgPhoto.ImageUrl = imageurl + "&cachekey=" + Guid.NewGuid().ToString();
            }
            else
            {
                imgPhoto.Visible = false;
            }

            // OpenSocial.  Allows gadget developers to show test gadgets if you have them installed
            string uri = this.BaseData.SelectSingleNode("rdf:RDF/rdf:Description/@rdf:about", base.Namespaces).Value;
            OpenSocialManager om = OpenSocialManager.GetOpenSocialManager(uri, Page);
            if (om.IsVisible()) 
            {
                if (om.GetUnrecognizedGadgets().Count > 0) 
                {
                    pnlSandboxGadgets.Visible = true;
                    litSandboxGadgets.Visible = true;
                    string sandboxDivs = "" ;
                    foreach (PreparedGadget gadget in om.GetUnrecognizedGadgets())
                    {
                        sandboxDivs += "<div id='" + gadget.GetChromeId() + "' class='gadgets-gadget-parent'></div>";
                    }
                    litSandboxGadgets.Text = sandboxDivs;
                    om.LoadAssets();
                }
            }
        }

        // UCSF
        static internal string getEmailPlainText(String emailEncrypted)
        {
            Utilities.DataIO data = new Profiles.Profile.Utilities.DataIO();
            SqlDataReader reader;

            SqlCommand cmd = new SqlCommand("SELECT [Utility.Application].[fnDecryptBase64RC4] ( '" + emailEncrypted + "',   (Select [value] from [Framework.].parameter with(nolock) where ParameterID = 'RC4EncryptionKey'))");
            reader = data.GetSQLDataReader(cmd);
            reader.Read();

            string emailPlain = reader[0].ToString();
            reader.Close();
            return emailPlain;
        }
    }

}