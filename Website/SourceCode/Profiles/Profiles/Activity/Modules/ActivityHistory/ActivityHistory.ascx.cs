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
using System.Xml;
using Profiles.Framework.Utilities;
using System.Web.UI.HtmlControls;

namespace Profiles.Activity.Modules.ActivityHistory
{
    public partial class ActivityHistory : BaseModule
    {
        
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public ActivityHistory() { }

        public ActivityHistory(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            DrawProfilesModule();
        }

        public void setModuleParams(List<ModuleParams> moduleparams)
        {
            base.ModuleParams = moduleparams;
        }

        public void DrawProfilesModule()
        {
            LoadAssets();
            int count = Convert.ToInt32(base.GetModuleParamString("Show"));
            linkSeeMore.Visible = "True".Equals(base.GetModuleParamString("SeeMore"));
            if ("True".Equals(base.GetModuleParamString("Scrolling"))) 
            {
                pnlActivities.ScrollBars = ScrollBars.Vertical;
                pnlActivities.Height = 7 * count;
                pnlActivities.Attributes.Add("onscroll", "ScrollAlert()");
            }
            else 
            {
                pnlActivities.ScrollBars = ScrollBars.None;
            }

            // GetActivity reads from the shared activity cache and only goes back to the
            // database when the cache does not contain enough records. The cache contains
            // activities from the whole Profiles network, so the first batch is deliberately
            // larger than the number of rows that will be displayed below.
            Profiles.Activity.Utilities.DataIO data = new Profiles.Activity.Utilities.DataIO();
            List<Profiles.Activity.Utilities.Activity> activities = new List<Profiles.Activity.Utilities.Activity>();
            try
            {
                // Fetching ten times the display count, with a floor of 30 records, gives an
                // institution-scoped brand a reasonable pool of recent network activity from
                // which to select its own updates. This is intentionally an in-memory
                // prioritization step; it does not change the shared activity query or cache.
                int activityFetchCount = Math.Max(count * 10, 30);
                activities.AddRange(data.GetActivity(-1, activityFetchCount, true));

                // A brand with exactly one configured institution represents an institution-
                // specific site such as UCSF or UCSD. A brand with zero or multiple configured
                // institutions is intentionally left as a network-wide feed.
                Brand currentBrand = Brand.GetCurrentBrand();
                if (currentBrand != null && currentBrand.GetInstitution() != null)
                {
                    string currentInstitution = currentBrand.GetInstitution().GetAbbreviation();
                    List<Profiles.Activity.Utilities.Activity> scopedActivities = new List<Profiles.Activity.Utilities.Activity>();
                    List<Profiles.Activity.Utilities.Activity> fallbackActivities = new List<Profiles.Activity.Utilities.Activity>();

                    // GetActivity returns records newest-first. Keeping each list in that
                    // original order means the matching records remain newest-first, as do the
                    // fallback records that may be used to fill any remaining display slots.
                    foreach (Profiles.Activity.Utilities.Activity activity in activities)
                    {
                        if (currentInstitution.Equals(activity.Profile.InstitutionAbbreviation))
                        {
                            scopedActivities.Add(activity);
                        }
                        else
                        {
                            fallbackActivities.Add(activity);
                        }
                    }

                    // Prefer updates belonging to the current brand. If there are not enough
                    // matching updates to fill the widget, append other network updates rather
                    // than leaving the widget empty or showing fewer rows than configured.
                    activities = new List<Profiles.Activity.Utilities.Activity>();
                    activities.AddRange(scopedActivities);
                    activities.AddRange(fallbackActivities);
                }

                // The larger fetch is only a candidate pool; render no more than the number of
                // activities configured by the presentation XML (for the search page, three).
                if (activities.Count > count)
                {
                    activities.RemoveRange(count, activities.Count - count);
                }
            }
            catch (Exception e)
            {
                Framework.Utilities.DebugLogging.Log("Error in ActivityHistory data.GetActivity " + e.Message + "; " + e.StackTrace);
            }

            rptActivityHistory.DataSource = activities;
            rptActivityHistory.DataBind();
        }

        public void rptActivityHistory_OnItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            Profiles.Activity.Utilities.Activity activity = (Profiles.Activity.Utilities.Activity)e.Item.DataItem;
            if (activity != null)
            {
                HyperLink linkThumbnail = (HyperLink)e.Item.FindControl("linkThumbnail");
                HyperLink linkProfileURL = (HyperLink)e.Item.FindControl("linkProfileURL");
                Literal litDate = (Literal)e.Item.FindControl("litDate");
                Literal litMessage = (Literal)e.Item.FindControl("litMessage");
                Literal litId = (Literal)e.Item.FindControl("litId");

                linkThumbnail.ImageUrl = activity.Profile.Thumbnail;
                linkThumbnail.NavigateUrl = activity.Profile.URL;
                linkProfileURL.NavigateUrl = activity.Profile.URL;
                linkProfileURL.Text = activity.Profile.Name;
                linkProfileURL.Text += "<span class=\"researcherprofiles--institution-name-associated-with-researcher\">" + activity.Profile.InstitutionAbbreviation + "</span>";

                litDate.Text = activity.Date;
                litMessage.Text = activity.Message;
                litId.Text = "" + activity.Id;
            }
        }

        // return an empty string for false so that Javscript will interpret it correctly
        public string FixedSize()
        {
            return "True".Equals(base.GetModuleParamString("Scrolling")) ? "" : "True";
        }

        public string GetThemedDomain()
        {
            return Brand.GetThemedDomain();
        }

        private void LoadAssets()
        {
            HtmlLink Searchcss = new HtmlLink();
            //Searchcss.Href = Brand.GetThemedDomain() + "/Activity/CSS/activity.css";
            Searchcss.Attributes["rel"] = "stylesheet";
            Searchcss.Attributes["type"] = "text/css";
            Searchcss.Attributes["media"] = "all";
            Page.Header.Controls.Add(Searchcss);

            // Inject script into HEADER
            Literal script = new Literal();
            script.Text = "<script>var _path = \"" + Brand.GetThemedDomain() + "\";</script>";
            Page.Header.Controls.Add(script);
        }
    }
}
