using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using System.Xml.Xsl;

using Profiles.Framework.Utilities;
using System.Web.UI.WebControls;
using System.Web;

namespace Profiles.Profile.Modules.PassiveList
{
    public partial class PassiveList : BaseModule
    {
        passiveList pl;

        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }

        public PassiveList() { }

        public PassiveList(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
        }
        public void DrawProfilesModule()
        {
            DateTime d = DateTime.Now;

            //If your module performs a data request, based on the DataURI parameter then call ReLoadBaseData
            base.GetDataByURI();

            XmlDocument document = new XmlDocument();
            XsltArgumentList args = new XsltArgumentList();
            bool networkexists = false;

            pl = new global::passiveList();
            pl.InfoCaption = base.GetModuleParamString("InfoCaption");
            pl.TotalCount = CustomParse.Parse(base.GetModuleParamString("TotalCount"), base.BaseData, base.Namespaces);

            pl.Description = base.GetModuleParamString("Description");
            pl.ID = Guid.NewGuid().ToString();

            pl.MoreText = CustomParse.Parse(base.GetModuleParamString("MoreText"), base.BaseData, base.Namespaces);                       
            pl.MoreURL = CustomParse.Parse(base.GetModuleParamString("MoreURL"), base.BaseData, base.Namespaces).Replace("amp;","");
            string path = base.GetModuleParamString("ListNode");

            try
            {
                XmlNodeList items = this.BaseData.SelectNodes(path, this.Namespaces);
                pl.ItemList = new List<itemList>();
                int remainingItems = Convert.ToInt16(base.GetModuleParamString("MaxDisplay"));
                foreach (XmlNode i in items)
                {
                    if (remainingItems == 0) break;
                    remainingItems--;

                    XmlNode networknode = this.BaseData.SelectSingleNode("rdf:RDF/rdf:Description[@rdf:about=\"" + i.Value + "\"]", this.Namespaces);

                    string itemurl =CustomParse.Parse(base.GetModuleParamString("ItemURL"), networknode, this.Namespaces);
                    string itemurltext = CustomParse.Parse(base.GetModuleParamString("ItemURLText"), networknode, this.Namespaces);
                    string item = CustomParse.Parse(base.GetModuleParamString("ItemText"), networknode, this.Namespaces);
                    networkexists = true;

                    if (base.GetModuleParamString("ItemURL") != string.Empty)
                    {
                        if (itemurltext.Equals("")) itemurltext = CustomParse.Parse("{{{//rdf:Description[@rdf:about='" + itemurl + "']/rdfs:label}}}", this.BaseData, this.Namespaces);

                        networkexists = true;
                        pl.ItemList.Add(new itemList { ItemURL = itemurl, ItemURLText = itemurltext, Item = item, ID = pl.ID });
                    }
                }
            }
            catch (Exception ex) { Framework.Utilities.DebugLogging.Log("Passive List died " + ex.Message + " ++ " + ex.StackTrace); }


            if (networkexists)
            {
                passiveList.DataSource = pl.ItemList;
                passiveList.DataBind();
            }
        }

        protected void passiveList_OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {


            switch (e.Item.ItemType)
            {

                case ListItemType.Header:
                    Literal infocaption = (Literal)e.Item.FindControl("InfoCaption");
                    Literal TotalCount = (Literal)e.Item.FindControl("TotalCount");

                    Literal divstart = (Literal)e.Item.FindControl("divStart");
                    Literal divend = (Literal)e.Item.FindControl("divEnd");
                    Literal Description = (Literal)e.Item.FindControl("Description");

                    divstart.Text = "<div id='" + pl.ID + "' class='passiveSectionHeadDescription' style='display: block;'>";
                    Description.Text = "<div>" + pl.Description + "</div>";
                    divend.Text = "</div>";
                    if (pl.TotalCount != string.Empty)
                    {
                        TotalCount.Text = "(" + pl.TotalCount + ")";
                    }
                    infocaption.Text = pl.InfoCaption;
                    break;
                case ListItemType.Footer:
                    HyperLink moreurl = (HyperLink)e.Item.FindControl("moreurl");
                    if (pl.MoreURL.Trim() != string.Empty)
                    {
                        moreurl.NavigateUrl = Brand.CleanURL(pl.MoreURL);
                        // for compliance
                        moreurl.Attributes.Add("aria-label", "Explore " + pl.InfoCaption.ToLower());
                    }
                    else
                    {
                        moreurl.Visible = false;
                    }
                    // UCSF Hack for UC Davis
                    if ("People".Equals(base.GetModuleParamString("InfoCaption")) && !Brand.GetCurrentBrand().IsMultiInstitutional())
                    {
                        if (pl.MoreURL.Trim() != string.Empty)
                        {
                            HyperLink moreurlInst = (HyperLink)e.Item.FindControl("moreurlInst");
                            moreurlInst.NavigateUrl = Brand.CleanURL(pl.MoreURL) + "&institution=" + Brand.GetCurrentBrand().GetInstitution().GetURI();
                            moreurlInst.Text = "@" + Brand.GetCurrentBrand().GetInstitution().GetAbbreviation();
                            moreurlInst.Visible = true;
                        }
                    }
                    break;

                default:
                    itemList il = (itemList)e.Item.DataItem;

                    HyperLink itemurl = (HyperLink)e.Item.FindControl("itemUrl");
                    Literal ucsfCustomItem = (Literal)e.Item.FindControl("ucsfCustomItem");

                    // UCSF. Need to set HTML, not Text! May need to swap in a literal
                    string personUrl = Brand.CleanURL(il.ItemURL);
                    if (UCSFIDSet.ByPrettyURL.ContainsKey(personUrl))
                    {
                        itemurl.Visible = false;
                        long nodeId = UCSFIDSet.ByPrettyURL[personUrl].NodeId;
                        Institution inst = UCSFIDSet.ByPrettyURL[personUrl].Institution;

                        ucsfCustomItem.Text = "<a href = '" + personUrl + "'>" +
                            "<div class='thumbnail'><img src = '" + Brand.GetByPrimaryInstituion(inst).BasePath +
                            "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=" + nodeId + "&Thumbnail=True&Width=15' width='15' height='30' alt=''/></div>" +
                            il.ItemURLText +
                            "<span class='researcherprofiles--institution-name-associated-with-researcher'>" + inst.GetAbbreviation() + "</span></a>";
                    }
                    // UCSF. Considered this for UC Davis  but came up with different solution
                    //else if ("Concepts".Equals(base.GetModuleParamString("InfoCaption"))  && !Brand.GetCurrentBrand().IsMultiInstitutional()) // UCSF hack to make UC Davis happy, and it is a good idea
                    //{
                    //    itemurl.Visible = false;
                    //    String searchURL = Brand.GetThemedDomain() + "/search/default.aspx?searchtype=people&searchfor=" + HttpUtility.UrlEncode(il.ItemURLText) +
                    //            "&exactphrase=true&institution=" + Brand.GetCurrentBrand().GetInstitution().GetURI() + "&showcolumns=10&new=true&perpage=15&offset=0";
                    //    ucsfCustomItem.Text = "<a href = '" + il.ItemURL + "'>" + il.ItemURLText + "</a>" + "&nbsp;" +
                    //        "<a href = '" + searchURL + "'>@" + Brand.GetCurrentBrand().GetInstitution().GetAbbreviation() + "</a>";
                    //}
                    else
                    {
                        ucsfCustomItem.Visible = false;
                        itemurl.NavigateUrl = Brand.CleanURL(il.ItemURL);  // go ahead and brand things like Concept pages, why not?
                        itemurl.Text = il.ItemURLText;
                    }
                    break;

            }
        }
    }



}
public class passiveList
{
    
    public string InfoCaption { get; set; }
    public string TotalCount { get; set; }
    public string Description { get; set; }
    public string ID { get; set; }
    public string MoreText { get; set; }
    public string MoreURL { get; set; }
    public List<itemList> ItemList { get; set; }


}
public class itemList
{
    public string ItemURL { get; set; }
    public string ItemURLText { get; set; }
    public string Item { get; set; }

    public string ID { get; set; }
}
























