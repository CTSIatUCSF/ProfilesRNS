using Profiles.Framework.Utilities;
using System;
using System.Collections.Generic;
using System.Xml;
using Newtonsoft.Json;
using System.Web.UI.WebControls;
using System.Text.RegularExpressions;
using Profiles.Profile.Modules;

namespace Profiles.Edit.Modules.CustomEditUCSFPlugIns
{
    public partial class GlobalHealthEquity : BaseUCSFModule
    {
        private string PlugInName = "GlobalHealthEquity";
        private string data = string.Empty;
        private GlobalHealthEquityData ghData = new GlobalHealthEquityData();

        private enum GlobalHealthEquityType
        {
            Interest,
            Location,
            Center,
            NONE
        }

        public GlobalHealthEquity() : base() { }
        public GlobalHealthEquity(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {

            SessionManagement sm = new SessionManagement();
            securityOptions.Subject = base.SubjectID;
            securityOptions.PredicateURI = base.PredicateURI.Replace("!", "#");
            securityOptions.PrivacyCode = Convert.ToInt32(base.PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@ViewSecurityGroup").Value);
            securityOptions.SecurityGroups = new XmlDocument();
            securityOptions.SecurityGroups.LoadXml(base.PresentationXML.DocumentElement.LastChild.OuterXml);
            securityOptions.BubbleClick += SecurityDisplayed;

            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);

            litBackLink.Text = "<a href='" + Brand.GetThemedDomain() + "/edit/default.aspx?subject=" + this.SubjectID + "'>Edit Menu</a> &gt; <b>" + PropertyListXML.SelectSingleNode("PropertyList/PropertyGroup/Property/@Label").Value + "</b>";
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            ReadJson();
            foreach (string s in this.GetRemainingOfType(GlobalHealthEquityType.Interest))
            {
                ddlInterests.Items.Add(s);
            }
            foreach (string s in this.GetRemainingOfType(GlobalHealthEquityType.Location))
            {
                ddlLocations.Items.Add(s);
            }
            foreach (string s in this.GetRemainingOfType(GlobalHealthEquityType.Center))
            {
                ddlCenters.Items.Add(s);
            }
            base.InitUpDownArrows(ref GridViewGlobalHealthInterests);
            base.InitUpDownArrows(ref GridViewGlobalHealthLocations);
            base.InitUpDownArrows(ref GridViewGlobalHealthCenters);
            upnlEditSection.Update();
        }

        private void SecurityDisplayed(object sender, EventArgs e)
        {

            if (Session["pnlSecurityOptions.Visible"] == null)
            {
                pnlAddEditInterest.Visible = true;
                pnlAddEditLocation.Visible = true;
                pnlAddEditCenter.Visible = true;
            }
            else
            {
                pnlAddEditInterest.Visible = false;
                pnlAddEditLocation.Visible = false;
                pnlAddEditCenter.Visible = false;
            }

            upnlEditSection.Update();
        }

        protected void btnAddEdit_OnClick(object sender, EventArgs e)
        {
            GlobalHealthEquityType type = GetTypeFromControl(sender);
            string sessionKey = "pnlGlobalHealth" + type.ToString() + "s.Visible";
            System.Web.UI.WebControls.Panel panel = (System.Web.UI.WebControls.Panel)GetControlMatchingType(type, pnlGlobalHealthInterests, pnlGlobalHealthLocations, pnlGlobalHealthCenters);
            ImageButton button = (ImageButton)GetControlMatchingType(type, imbAddArrowInterest, imbAddArrowLocation, imbAddArrowCenter);

            if (Session[sessionKey] == null)
            {
                panel.Visible = true;
                button.ImageUrl = "~/Framework/Images/icon_squareDownArrow.gif";

                phSecuritySettings.Visible = false;
                Session[sessionKey] = true;
            }
            else
            {
                panel.Visible = false;
                button.ImageUrl = "~/Framework/Images/icon_squareArrow.gif";
                Session[sessionKey] = null;
                phSecuritySettings.Visible = true;
            }
        }

        protected void btnInsert_OnClick(object sender, EventArgs e)
        {
            btnSaveAndClose_OnClick(sender, e);

            phSecuritySettings.Visible = false;
            GlobalHealthEquityType type = GetTypeFromControl(sender);
            WebControl pnlAddEdit = GetControlMatchingType(type, pnlAddEditInterest, pnlAddEditLocation, pnlAddEditCenter);
            WebControl pnlGlobalHealth = GetControlMatchingType(type, pnlGlobalHealthInterests, pnlGlobalHealthLocations, pnlGlobalHealthCenters);
            pnlAddEdit.Visible = false;
            pnlGlobalHealth.Visible = true;
        }

        protected void btnSaveAndClose_OnClick(object sender, EventArgs e)
        {
            GlobalHealthEquityType type = GetTypeFromControl(sender);
            DropDownList ddl = (DropDownList)GetControlMatchingType(type, ddlInterests, ddlLocations, ddlCenters);

            if (ddl.SelectedValue != string.Empty)
            {
                string search = string.Empty;

                if (type == GlobalHealthEquityType.Interest)
                {
                    if (ghData.interests == null) { ghData.interests = new List<string>(); }
                    ghData.interests.Add(ddl.SelectedValue);
                }
                else if (type == GlobalHealthEquityType.Location)
                {
                    if (ghData.locations == null) { ghData.locations = new List<string>(); }
                    ghData.locations.Add(ddl.SelectedValue);
                }
                else if (type == GlobalHealthEquityType.Center)
                {
                    if (ghData.centers == null) { ghData.centers = new List<string>(); }
                    ghData.centers.Add(ddl.SelectedValue);
                }
                Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());
            }
            ddl.Items.Remove(ddl.SelectedItem);
            ResetDisplay();
        }

        protected void btnDeleteCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }
        protected void btnCancel_OnClick(object sender, EventArgs e)
        {
            ResetDisplay();
        }

        private void ResetDisplay()
        {
            phSecuritySettings.Visible = true;

            pnlAddEditInterest.Visible = true;
            pnlAddEditLocation.Visible = true;
            pnlAddEditCenter.Visible = true;

            Session["pnlGlobalHealthInterests.Visible"] = null;
            Session["pnlGlobalHealthLocations.Visible"] = null;
            Session["pnlGlobalHealthCenters.Visible"] = null;

            ddlInterests.SelectedIndex = 0;
            ddlLocations.SelectedIndex = 0;
            ddlCenters.SelectedIndex = 0;

            this.data = string.Empty;
            this.ghData = null;

            this.data = Profiles.Framework.Utilities.GenericRDFDataIO.GetSocialMediaPlugInData(this.SubjectID, this.PlugInName);
            
            ReadJson();            
            upnlEditSection.Update();
        }

        private bool HasNoGlobalHealthEquityData()
        {
            return ghData == null || (ghData.interests.Count == 0 && ghData.locations.Count == 0 && ghData.centers.Count == 0);
        }

        private void ReadJson()
        {
            this.ghData = JsonConvert.DeserializeObject<GlobalHealthEquityData>(this.data);
            if (this.ghData == null)
            {
                this.ghData = new GlobalHealthEquityData();
            }

            if (HasNoGlobalHealthEquityData())
            {
                divNoGlobalHealthEquity.Visible = true;
                GridViewGlobalHealthInterests.Visible = false;
                GridViewGlobalHealthLocations.Visible = false;
                GridViewGlobalHealthCenters.Visible = false;
            }
            else
            {
                divNoGlobalHealthEquity.Visible = false;

                GridViewGlobalHealthInterests.Visible = true;
                GridViewGlobalHealthInterests.DataSource = ghData.interests;
                GridViewGlobalHealthInterests.DataBind();
                base.InitUpDownArrows(ref GridViewGlobalHealthInterests);

                GridViewGlobalHealthLocations.Visible = true;
                GridViewGlobalHealthLocations.DataSource = ghData.locations;
                GridViewGlobalHealthLocations.DataBind();
                base.InitUpDownArrows(ref GridViewGlobalHealthLocations);

                GridViewGlobalHealthCenters.Visible = true;
                GridViewGlobalHealthCenters.DataSource = ghData.centers;
                GridViewGlobalHealthCenters.DataBind();
                base.InitUpDownArrows(ref GridViewGlobalHealthCenters);
            }
        }
        private string SerializeJson()
        {
            return JsonConvert.SerializeObject(this.ghData);
        }

        private string GetSearchData()
        {
            string search = "Global Health Equity";
            foreach (string v in this.ghData.interests)
            {
                search += " " + v;
            }
            foreach (string v in this.ghData.locations)
            {
                search += " " + v;
            }
            foreach (string v in this.ghData.centers)
            {
                search += " " + v;
            }
            return search;
        }

        private List<string> GetRemainingOfType(GlobalHealthEquityType type)
        {
            List<string> retval = new List<string>();
            retval.AddRange(GetAllOfType(type));
            foreach (string item in getGHDataOfType(type))
            {
                retval.Remove(item);
            }
            return retval;
        }

        List<string> getGHDataOfType(GlobalHealthEquityType type)
        {
            if (type == GlobalHealthEquityType.Interest)
            {
                return this.ghData.interests;
            }
            else if (type == GlobalHealthEquityType.Location)
            {
                return this.ghData.locations;
            }
            else if (type == GlobalHealthEquityType.Center)
            {
                return this.ghData.centers;
            }
            return null;
        }

        private List<string> GetAllOfType(GlobalHealthEquityType type)
        {
            List<string> retval = new List<string>();
            if (type == GlobalHealthEquityType.Interest)
            {   //=CONCATENATE("retval.Add(""", TRIM(A1), """);")
                retval.Add("Cardiovascular health");
                retval.Add("Child & adolescent health");
                retval.Add("Chronic respiratory disease");
                retval.Add("Climate change");
                retval.Add("COVID-19");
                retval.Add("Diabetes");
                retval.Add("Diagnostics & Laboratory Medicine");
                retval.Add("Diarrheal disease");
                retval.Add("Disaster relief");
                retval.Add("Education");
                retval.Add("Emergency & critical care");
                retval.Add("Epidemiology & surveillance");
                retval.Add("Ocular health");
                retval.Add("Reproductive health");
                retval.Add("Guideline development & reviews");
                retval.Add("Health economics");
                retval.Add("HIV/AIDS");
                retval.Add("Human rights & refugee health");
                retval.Add("Immunization & immunology");
                retval.Add("Implementation science");
                retval.Add("Infectious disease");
                retval.Add("Injury & violence");
                retval.Add("Malaria");
                retval.Add("Maternal health");
                retval.Add("Memory & aging");
                retval.Add("Mental health");
                retval.Add("Neglected Tropical Diseases");
                retval.Add("Newborn & infant health");
                retval.Add("Non-communicable diseases");
                retval.Add("Nursing");
                retval.Add("Nutrition & food security");
                retval.Add("Oncology");
                retval.Add("Oral health");
                retval.Add("Pandemic response & preparedness");
                retval.Add("Pharmacology");
                retval.Add("Policy & standards of care");
                retval.Add("Primary care");
                retval.Add("Reproductive health");
                retval.Add("Smoking & Tobacco");
                retval.Add("Substance abuse");
                retval.Add("Surgery, anesthesia & pain");
                retval.Add("Technology innovation");
                retval.Add("Tuberculosis");
                retval.Add("Women's health");
                retval.Add("Zoonosis & emerging diseases");
            }
            else if (type == GlobalHealthEquityType.Location)
            {
                retval.Add("California");
                retval.Add("Rural United States");
                retval.Add("East Asia");
                retval.Add("Europe and Central Asia");
                retval.Add("Latin America and the Caribbean");
                retval.Add("Middle East and North Africa");
                retval.Add("South Asia");
                retval.Add("Western Pacific");
                retval.Add("Sub-Saharan Africa");
                retval.Add("Afghanistan");
                retval.Add("Akrotiri");
                retval.Add("Albania");
                retval.Add("Algeria");
                retval.Add("American Samoa");
                retval.Add("Andorra");
                retval.Add("Angola");
                retval.Add("Anguilla");
                retval.Add("Antarctica");
                retval.Add("Antigua and Barbuda");
                retval.Add("Argentina");
                retval.Add("Armenia");
                retval.Add("Aruba");
                retval.Add("Ashmore and Cartier Islands");
                retval.Add("Australia");
                retval.Add("Austria");
                retval.Add("Azerbaijan");
                retval.Add("Bahamas, The");
                retval.Add("Bahrain");
                retval.Add("Bangladesh");
                retval.Add("Barbados");
                retval.Add("Bassas da India");
                retval.Add("Belarus");
                retval.Add("Belgium");
                retval.Add("Belize");
                retval.Add("Benin");
                retval.Add("Bermuda");
                retval.Add("Bhutan");
                retval.Add("Bolivia");
                retval.Add("Bosnia and Herzegovina");
                retval.Add("Botswana");
                retval.Add("Bouvet Island");
                retval.Add("Brazil");
                retval.Add("British Indian Ocean Territory");
                retval.Add("British Virgin Islands");
                retval.Add("Brunei");
                retval.Add("Bulgaria");
                retval.Add("Burkina Faso");
                retval.Add("Burma");
                retval.Add("Burundi");
                retval.Add("Cambodia");
                retval.Add("Cameroon");
                retval.Add("Canada");
                retval.Add("Cape Verde");
                retval.Add("Cayman Islands");
                retval.Add("Central African Republic");
                retval.Add("Chad");
                retval.Add("Chile");
                retval.Add("China");
                retval.Add("Christmas Island");
                retval.Add("Clipperton Island");
                retval.Add("Cocos (Keeling) Islands");
                retval.Add("Colombia");
                retval.Add("Comoros");
                retval.Add("Congo, Democratic Republic of the");
                retval.Add("Congo, Republic of the");
                retval.Add("Cook Islands");
                retval.Add("Coral Sea Islands");
                retval.Add("Costa Rica");
                retval.Add("Cote d'Ivoire");
                retval.Add("Croatia");
                retval.Add("Cuba");
                retval.Add("Cyprus");
                retval.Add("Czech Republic");
                retval.Add("Denmark");
                retval.Add("Dhekelia");
                retval.Add("Djibouti");
                retval.Add("Dominica");
                retval.Add("Dominican Republic");
                retval.Add("Ecuador");
                retval.Add("Egypt");
                retval.Add("El Salvador");
                retval.Add("Equatorial Guinea");
                retval.Add("Eritrea");
                retval.Add("Estonia");
                retval.Add("Ethiopia");
                retval.Add("Europa Island");
                retval.Add("Falkland Islands (Islas Malvinas)");
                retval.Add("Faroe Islands");
                retval.Add("Fiji");
                retval.Add("Finland");
                retval.Add("France");
                retval.Add("French Guiana");
                retval.Add("French Polynesia");
                retval.Add("French Southern and Antarctic Lands");
                retval.Add("Gabon");
                retval.Add("Gambia, The");
                retval.Add("Gaza Strip");
                retval.Add("Georgia");
                retval.Add("Germany");
                retval.Add("Ghana");
                retval.Add("Gibraltar");
                retval.Add("Glorioso Islands");
                retval.Add("Greece");
                retval.Add("Greenland");
                retval.Add("Grenada");
                retval.Add("Guadeloupe");
                retval.Add("Guam");
                retval.Add("Guatemala");
                retval.Add("Guernsey");
                retval.Add("Guinea");
                retval.Add("Guinea-Bissau");
                retval.Add("Guyana");
                retval.Add("Haiti");
                retval.Add("Heard Island and McDonald Islands");
                retval.Add("Holy See (Vatican City)");
                retval.Add("Honduras");
                retval.Add("Hong Kong");
                retval.Add("Hungary");
                retval.Add("Iceland");
                retval.Add("India");
                retval.Add("Indonesia");
                retval.Add("Iran");
                retval.Add("Iraq");
                retval.Add("Ireland");
                retval.Add("Isle of Man");
                retval.Add("Israel");
                retval.Add("Italy");
                retval.Add("Jamaica");
                retval.Add("Jan Mayen");
                retval.Add("Japan");
                retval.Add("Jersey");
                retval.Add("Jordan");
                retval.Add("Juan de Nova Island");
                retval.Add("Kazakhstan");
                retval.Add("Kenya");
                retval.Add("Kiribati");
                retval.Add("Korea, North");
                retval.Add("Korea, South");
                retval.Add("Kuwait");
                retval.Add("Kyrgyzstan");
                retval.Add("Laos");
                retval.Add("Latvia");
                retval.Add("Lebanon");
                retval.Add("Lesotho");
                retval.Add("Liberia");
                retval.Add("Libya");
                retval.Add("Liechtenstein");
                retval.Add("Lithuania");
                retval.Add("Luxembourg");
                retval.Add("Macau");
                retval.Add("Macedonia");
                retval.Add("Madagascar");
                retval.Add("Malawi");
                retval.Add("Malaysia");
                retval.Add("Maldives");
                retval.Add("Mali");
                retval.Add("Malta");
                retval.Add("Marshall Islands");
                retval.Add("Martinique");
                retval.Add("Mauritania");
                retval.Add("Mauritius");
                retval.Add("Mayotte");
                retval.Add("Mexico");
                retval.Add("Micronesia, Federated States of");
                retval.Add("Moldova");
                retval.Add("Monaco");
                retval.Add("Mongolia");
                retval.Add("Montserrat");
                retval.Add("Morocco");
                retval.Add("Mozambique");
                retval.Add("Namibia");
                retval.Add("Nauru");
                retval.Add("Navassa Island");
                retval.Add("Nepal");
                retval.Add("Netherlands");
                retval.Add("Netherlands Antilles");
                retval.Add("New Caledonia");
                retval.Add("New Zealand");
                retval.Add("Nicaragua");
                retval.Add("Niger");
                retval.Add("Nigeria");
                retval.Add("Niue");
                retval.Add("Norfolk Island");
                retval.Add("Northern Mariana Islands");
                retval.Add("Norway");
                retval.Add("Oman");
                retval.Add("Pakistan");
                retval.Add("Palau");
                retval.Add("Panama");
                retval.Add("Papua New Guinea");
                retval.Add("Paracel Islands");
                retval.Add("Paraguay");
                retval.Add("Peru");
                retval.Add("Philippines");
                retval.Add("Pitcairn Islands");
                retval.Add("Poland");
                retval.Add("Portugal");
                retval.Add("Puerto Rico");
                retval.Add("Qatar");
                retval.Add("Reunion");
                retval.Add("Romania");
                retval.Add("Russia");
                retval.Add("Rwanda");
                retval.Add("Saint Helena");
                retval.Add("Saint Kitts and Nevis");
                retval.Add("Saint Lucia");
                retval.Add("Saint Pierre and Miquelon");
                retval.Add("Saint Vincent and the Grenadines");
                retval.Add("Samoa");
                retval.Add("San Marino");
                retval.Add("Sao Tome and Principe");
                retval.Add("Saudi Arabia");
                retval.Add("Senegal");
                retval.Add("Serbia and Montenegro");
                retval.Add("Seychelles");
                retval.Add("Sierra Leone");
                retval.Add("Singapore");
                retval.Add("Slovakia");
                retval.Add("Slovenia");
                retval.Add("Solomon Islands");
                retval.Add("Somalia");
                retval.Add("Somaliland");
                retval.Add("South Africa");
                retval.Add("South Georgia and the South Sandwich Islands");
                retval.Add("South Sudan");
                retval.Add("Spain");
                retval.Add("Spratly Islands");
                retval.Add("Sri Lanka");
                retval.Add("Sudan");
                retval.Add("Suriname");
                retval.Add("Svalbard");
                retval.Add("Swaziland");
                retval.Add("Sweden");
                retval.Add("Switzerland");
                retval.Add("Syria");
                retval.Add("Taiwan");
                retval.Add("Tajikistan");
                retval.Add("Tanzania");
                retval.Add("Thailand");
                retval.Add("Timor-Leste");
                retval.Add("Togo");
                retval.Add("Tokelau");
                retval.Add("Tonga");
                retval.Add("Trinidad and Tobago");
                retval.Add("Tromelin Island");
                retval.Add("Tunisia");
                retval.Add("Turkey");
                retval.Add("Turkmenistan");
                retval.Add("Turks and Caicos Islands");
                retval.Add("Tuvalu");
                retval.Add("Uganda");
                retval.Add("Ukraine");
                retval.Add("United Arab Emirates");
                retval.Add("United Kingdom");
                retval.Add("United States");
                retval.Add("Uruguay");
                retval.Add("Uzbekistan");
                retval.Add("Vanuatu");
                retval.Add("Venezuela");
                retval.Add("Vietnam");
                retval.Add("Virgin Islands");
                retval.Add("Wake Island");
                retval.Add("Wallis and Futuna");
                retval.Add("West Bank");
                retval.Add("Western Sahara");
                retval.Add("Yemen");
                retval.Add("Zambia");
                retval.Add("Zimbabwe");
            }
            else if (type == GlobalHealthEquityType.Center)
            {
                retval.Add("IGHS - Center for Pandemic Preparedness & Response");
                retval.Add("IGHS - Center for Health Equity in Surgery & Anesthesia");
                retval.Add("IGHS - Center for Global Maternal, Newborn & Child Health");
                retval.Add("IGHS - Center for Global Health Diplomacy, Delivery & Economics");
                retval.Add("IGHS - Center for Infectious and Parasitic Diseases");
                retval.Add("IGHS - Center for Strategic Information and Public Health Practice");
                retval.Add("Institute for Global Health Sciences");
                retval.Add("HEAL Initiative");
                retval.Add("WHO Collaborating Center for Emergency, Critical & Operative Care");
                retval.Add("WHO Collaborating Center on Tobacco Control");
                retval.Add("Health & Human Rights Initiative");
                retval.Add("Global Disaster Assistance Committee (GDAC)");
                retval.Add("PRISE Center");
                retval.Add("IGOT");
                retval.Add("Center for Health Equity");
                retval.Add("Center for Vulnerable Populations");
                retval.Add("BALANCE (GloBAL Neurology, NeuroinfeCtious Diseases, and Health Equity)");
                retval.Add("International Research Support Operations (IRSO)");
                retval.Add("UCSF Center for Tuberculosis");

            }
            return retval;
        }

        private WebControl GetControlMatchingType(GlobalHealthEquityType type, WebControl wc1, WebControl wc2, WebControl wc3)
        {
            if (GetTypeFromControl(wc1) == type)
            {
                return wc1;
            }
            else if (GetTypeFromControl(wc2) == type)
            {
                return wc2;
            }
            else if (GetTypeFromControl(wc3) == type)
            {
                return wc3;
            }
            return null;
        }

        #region "Grid"
        private GlobalHealthEquityType GetTypeFromControl(object sender)
        {
            if (((WebControl)sender).ID.Contains("Interest"))
            {
                return GlobalHealthEquityType.Interest;
            }
            else if (((WebControl)sender).ID.Contains("Location"))
            {
                return GlobalHealthEquityType.Location;
            }
            else if (((WebControl)sender).ID.Contains("Center"))
            {
                return GlobalHealthEquityType.Center;
            }
            else if (((ImageButton)sender).DataItemContainer.NamingContainer.ID.Contains("Interest"))
            {
                return GlobalHealthEquityType.Interest;
            }
            else if (((ImageButton)sender).DataItemContainer.NamingContainer.ID.Contains("Location"))
            {
                return GlobalHealthEquityType.Location;
            }
            else if (((ImageButton)sender).DataItemContainer.NamingContainer.ID.Contains("Center"))
            {
                return GlobalHealthEquityType.Center;
            }
            return GlobalHealthEquityType.NONE;
        }

        protected void GridViewGlobalHealth_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            GlobalHealthEquityType type = GetTypeFromControl(sender);

            if (type == GlobalHealthEquityType.Interest)
            {
                this.ghData.interests.RemoveAt(e.RowIndex);
            }
            else if (type == GlobalHealthEquityType.Location)
            {
                this.ghData.locations.RemoveAt(e.RowIndex);
            }
            else if (type == GlobalHealthEquityType.Center)
            {
                this.ghData.centers.RemoveAt(e.RowIndex);
            }

            //this needs to be the json desz'd
            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            if (HasNoGlobalHealthEquityData()) //they just deleted their last row
            {
                Profiles.Framework.Utilities.GenericRDFDataIO.RemovePluginData(this.PlugInName, this.SubjectID);
            }

            ResetDisplay();
            if (type == GlobalHealthEquityType.Interest)
            {
                base.InitUpDownArrows(ref GridViewGlobalHealthInterests);
            }
            else if (type == GlobalHealthEquityType.Location)
            {
                base.InitUpDownArrows(ref GridViewGlobalHealthLocations);
            }
            else if (type == GlobalHealthEquityType.Center)
            {
                base.InitUpDownArrows(ref GridViewGlobalHealthCenters);
            }
            upnlEditSection.Update();
        }
        protected void ibUp_Click(object sender, EventArgs e)
        {

            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;
            GlobalHealthEquityType type = GetTypeFromControl(sender);

            if (type == GlobalHealthEquityType.Interest)
            {
                GridViewGlobalHealthInterests.EditIndex = -1;
                int newIndex = row.RowIndex - 1;
                int oldIndex = row.RowIndex;

                var item = this.ghData.interests[oldIndex];

                this.ghData.interests.RemoveAt(oldIndex);
                this.ghData.interests.Insert(newIndex, item);
            }
            else if (type == GlobalHealthEquityType.Location)
            {
                GridViewGlobalHealthLocations.EditIndex = -1;
                int newIndex = row.RowIndex - 1;
                int oldIndex = row.RowIndex;

                var item = this.ghData.locations[oldIndex];

                this.ghData.locations.RemoveAt(oldIndex);
                this.ghData.locations.Insert(newIndex, item);
            }
            else if (type == GlobalHealthEquityType.Center)
            {
                GridViewGlobalHealthCenters.EditIndex = -1;
                int newIndex = row.RowIndex - 1;
                int oldIndex = row.RowIndex;

                var item = this.ghData.centers[oldIndex];

                this.ghData.centers.RemoveAt(oldIndex);
                this.ghData.centers.Insert(newIndex, item);
            }

            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            SerializeJson();
            ResetDisplay();

        }
        protected void ibDown_Click(object sender, EventArgs e)
        {
            GridViewRow row = ((ImageButton)sender).DataItemContainer as GridViewRow;
            GlobalHealthEquityType type = GetTypeFromControl(sender);

            if (type == GlobalHealthEquityType.Interest)
            {
                GridViewGlobalHealthInterests.EditIndex = -1;

                int newIndex = row.RowIndex + 1;
                int oldIndex = row.RowIndex;

                var item = this.ghData.interests[oldIndex];

                this.ghData.interests.RemoveAt(oldIndex);
                this.ghData.interests.Insert(newIndex, item);
            }
            else if (type == GlobalHealthEquityType.Location)
            {
                GridViewGlobalHealthLocations.EditIndex = -1;

                int newIndex = row.RowIndex + 1;
                int oldIndex = row.RowIndex;

                var item = this.ghData.locations[oldIndex];

                this.ghData.locations.RemoveAt(oldIndex);
                this.ghData.locations.Insert(newIndex, item);
            }
            else if (type == GlobalHealthEquityType.Center)
            {
                GridViewGlobalHealthCenters.EditIndex = -1;

                int newIndex = row.RowIndex + 1;
                int oldIndex = row.RowIndex;

                var item = this.ghData.centers[oldIndex];

                this.ghData.centers.RemoveAt(oldIndex);
                this.ghData.centers.Insert(newIndex, item);
            }

            Profiles.Framework.Utilities.GenericRDFDataIO.AddEditPluginData(this.PlugInName, this.SubjectID, this.SerializeJson(), GetSearchData());

            ResetDisplay();
        }
        #endregion
    }

    public class GlobalHealthEquityData
    {
        public GlobalHealthEquityData()
        {
            interests = new List<string>();
            locations = new List<string>();
            centers = new List<string>();
        }
        public List<string> interests { get; set; }
        public List<string> locations { get; set; }
        public List<string> centers { get; set; }
    }
}