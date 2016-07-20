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
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Xsl;
using System.Data.SqlClient;
using System.Configuration;

using Profiles.History.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.History.Modules.HistoryActivity
{
    public partial class HistoryActivity : BaseModule
    {
        
        protected void Page_Load(object sender, EventArgs e)
        {
            
            //ItemsGet();
        }

        public HistoryActivity() { }
        public HistoryActivity(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            DrawProfilesModule(); 
        }

        public void DrawProfilesModule()
        {
            linkSeeMore.Visible = "True".Equals(base.GetModuleParamString("SeeMore"));
            linkPrev.Visible = "True".Equals(base.GetModuleParamString("Paging"));
            linkNext.Visible = "True".Equals(base.GetModuleParamString("Paging"));

            // grab a bunch of activities from the Database
            Profiles.History.Utilities.DataIO data = new Profiles.History.Utilities.DataIO();
            List<Activity> activities = data.GetActivity();
            DeclumpedActivityList list = new DeclumpedActivityList();
            list.AddRange(activities);
            list.Clump();
            rptHistoryActivity.DataSource = list.TakeUnclumped(Convert.ToInt32(base.GetModuleParamString("Show")));
            rptHistoryActivity.DataBind();
        }

        public int CurrentPage
        {
            get
            {
                // look for current page in ViewState
                object o = this.ViewState["_CurrentPage"];
                if (o == null)
                    return 0;   // default to showing the first page
                else
                    return (int)o;
            }

            set
            {
                this.ViewState["_CurrentPage"] = value;
            }
        }

        /**
       
        protected void ItemsGet()
        {
            linkSeeMore.Visible = "True".Equals(base.GetModuleParamString("SeeMore"));
            linkPrev.Visible = "True".Equals(base.GetModuleParamString("Paging"));
            linkNext.Visible = "True".Equals(base.GetModuleParamString("Paging"));
            // Populate the repeater control with the Items DataSet
            PagedDataSource objPds = new PagedDataSource();
            DrawProfilesModule2();

            objPds.DataSource = statact;
 
            objPds.AllowPaging = true;
            //objPds.AllowCustomPaging = true;
            objPds.PageSize = Convert.ToInt32(base.GetModuleParamString("Show"));//3;

            CurrentPage = 1;
            if (Request.QueryString["page"] != null)
                {
                    CurrentPage = Int32.Parse(Request.QueryString["page"]);
                }
                else
                {
                    CurrentPage = 1;
                }

            objPds.CurrentPageIndex = CurrentPage - 1;
                
            if (!objPds.IsLastPage)
            {
                    Label4.Text = "    See more details on next page";
            }
            else
            {
                    Label4.Text = "                                 ";
            }

            if (!objPds.IsFirstPage)
            {
                    linkPrev.NavigateUrl = Request.CurrentExecutionFilePath + "?page=" + (CurrentPage - 1);
            }

            if (!objPds.IsLastPage)
            {
                    linkNext.NavigateUrl = Request.CurrentExecutionFilePath + "?page=" + (CurrentPage + 1);
            }
            rptHistoryActivity.DataSource = objPds;
            rptHistoryActivity.DataBind();

         }
         * **/

        /***
        private void DrawProfilesModule2()
        {
          if (statact == null ||statact.Count==0 ) {
            string cacheCapacity = ConfigurationManager.AppSettings["cacheCapacity"];
            cacheCapacity = "100";
            int recount = Convert.ToInt32(cacheCapacity);
            List<ShowActivities.Model.Activity> liact = new List<ShowActivities.Model.Activity>();
            List<ShowActivities.Model.Activity> limoreact = new List<ShowActivities.Model.Activity>();

            string sql;
            sql = "SELECT top " + cacheCapacity + "  i.activityLogID,i.privacyCode," +
                            "ISNULL(p.InternalUserName, ip.internalusername) as internalusername," +
                            "p.personid,p.firstname,p.lastname," +
                            "i.methodName,i.property,cp._PropertyLabel as propertyLabel,i.param1,i.param2,i.createdDT,externalMessage = 0 " +
                            "FROM [UCSF.].[ActivityLog] i " +
                            "LEFT OUTER JOIN [Profile.Data].[Person] p ON i.personId = p.personID " +
                            "LEFT OUTER JOIN [Profile.Import].[Person] ip " +
                                "on i.personId = [UCSF.].fnGeneratePersonID(ip.internalusername) " +
                            "LEFT OUTER JOIN [Ontology.].[ClassProperty] cp ON cp.Property = i.property " +
                            "where p.IsActive=1 " +
                                " --and p.PersonId=5248457 or p.lastname='Khoury'" +
                            "order by i.createdDT desc, i.activityLogID desc ";
            using (SqlDataReader reader = data.GetQueryOutputReader(sql))
            {
                while (reader.Read())
                {
                    string param1 = reader["param1"].ToString();
                    string param2 = reader["param2"].ToString();
                    string activityLogId = reader["activityLogId"].ToString();
                    string internalusername = reader["internalusername"].ToString();
                    string createdDT = reader["createdDT"].ToString();
                    string privacyCode = reader["privacyCode"].ToString();
                    string propertyLabel = reader["propertyLabel"].ToString();
                    string personid = reader["personid"].ToString();
                    string firstname = reader["firstname"].ToString();
                    string lastname = reader["lastname"].ToString();
                    string methodName = reader["methodName"].ToString();
                    string externalMessage = reader["externalMessage"].ToString();
                    string journalTitle = "";
                    string url = "";
                    bool isExternalMessage = false;
                    if (externalMessage.CompareTo("1") == 0) isExternalMessage = true;
                    string queryTitle = "";
                    string title = "";
                    string body = "";
                    if (param1 == "PMID")
                    {
                        url = "http://www.ncbi.nlm.nih.gov/pubmed/" + param2;
                        queryTitle = "SELECT JournalTitle FROM [Profile.Data].[Publication.PubMed.General] " +
                        "WHERE PMID = cast(" + param2 + " as int)";
                        journalTitle = data.GetStringValue(queryTitle, "JournalTitle");
                        isExternalMessage = true;
                    }
                    if (privacyCode.CompareTo("-1") == 0)
                    {
                        if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddPublication") == 0)
                        {
                            title = "added a PubMed publication";
                            body = "added a publication from: " + journalTitle;
                        }
                        else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.AddCustomPublication") == 0)
                        {
                            title = "added a custom publication";
                            body = "added \"" + param1 + "\" into " + propertyLabel +
                                " section : " + param2;
                        }
                        else if (methodName.CompareTo("Profiles.Edit.Utilities.DataIO.UpdateSecuritySetting") == 0)
                        {
                            title = "made a section visible";
                            body = "made \"" + propertyLabel + "\"public";
                        }
                        else if (methodName.IndexOf("Profiles.Edit.Utilities.DataIO.Add") == 0)
                        {
                            title = "added an item";
                            if (param1.Length != 0)
                            {
                                body = body = "added \"" + param1 + "\" into " + propertyLabel + " section";
                            }
                            else
                            {
                                body = "added \"" + propertyLabel + "\" section";
                            }

                        }
                        else if (methodName.IndexOf("Profiles.Edit.Utilities.DataIO.Update") == 0)
                        {
                            title = "updated an item";
                            if (param1.Length != 0)
                            {
                                body = "updated \"" + param1 + "\" in " + propertyLabel + " section";
                            }
                            else
                            {
                                body = "updated \"" + propertyLabel + "\" section";
                            }
                        }
                    }
                    else if (methodName.CompareTo("ProfilesGetNewHRAndPubs.Disambiguation") == 0)
                    {
                        title = "has a new PubMed publication";
                        body = "has a new publication listed from: " + journalTitle;
                    }
                    else if (methodName.CompareTo("ProfilesGetNewHRAndPubs.AddedToProfiles") == 0)
                    {
                        title = "added to Profiles";
                        body = "now has a Profile page";
                    }
                    if (title.CompareTo("") != 0)
                    {

                        ShowActivities.Model.Activity act = new ShowActivities.Model.Activity
                        {
                            Id = activityLogId,
                            Message = body,
                            LinkUrl = url,
                            Title = title,
                            CreatedDT = Convert.ToDateTime(reader["CreatedDT"]),
                            CreatedById = activityLogId,
                            Type = ShowActivities.Model.ActivityType.ActualActivity,
                            Parent = new ShowActivities.Model.User
                            {
                                Id = internalusername, //record.ParentId,
                                Name = firstname + " " + lastname, //record.Parent.User__r.Name,
                                FirstName = firstname,
                                LastName = lastname,
                                PersonId = Convert.ToInt32(personid)

                            }
                        };
                        liact.Add(act);
                    }
                }
                recount = liact.Count;
                string headay = "";
                List<ShowActivities.Model.Activity> dateList = null;
                foreach (ShowActivities.Model.Activity activity in liact)
                {
                     if (activity.Type == ShowActivities.Model.ActivityType.ActualActivity)
                    {
                        if (headay != activity.Date)
                        {
                            if (dateList != null)
                            {
                                ShowActivities.Model.DeclumpedList act4clump = new ShowActivities.Model.DeclumpedList();
                                act4clump.AddRange(dateList);
                                act4clump.Clump();
                                ShowActivities.Model.Activity[] retact = act4clump.TakeUnclumped(recount).ToArray();
                                statact.AddRange(retact);
                            }
                            dateList = new List<ShowActivities.Model.Activity>();
                            headay = activity.Date;
                        }
                        dateList.Add(activity);
                    }
                }
            }
          }
 
        }
        **/

        public void rptHistoryActivity_OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            Activity activity = (Activity)e.Item.DataItem;
            if (activity != null)
            {
                HyperLink linkThumbnail = (HyperLink)e.Item.FindControl("linkThumbnail");
                HyperLink linkProfileURL = (HyperLink)e.Item.FindControl("linkProfileURL");
                Literal litDate = (Literal)e.Item.FindControl("litDate");
                Literal litMessage = (Literal)e.Item.FindControl("litMessage");

                linkThumbnail.ImageUrl = "~/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?person=" + activity.Profile.PersonId + "&Thumbnail=True&Width=45";
                linkThumbnail.NavigateUrl = activity.Profile.URL;
                linkProfileURL.NavigateUrl = activity.Profile.URL;
                linkProfileURL.Text = activity.Profile.Name;

                litDate.Text = activity.Date;
                litMessage.Text = activity.Message;
            }
        }
    }
}