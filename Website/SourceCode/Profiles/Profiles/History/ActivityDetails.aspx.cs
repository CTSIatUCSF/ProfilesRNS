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
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Web.UI.HtmlControls;
using Profiles.Profile.Utilities;
using Profiles.Framework.Utilities;
using System.Web.Script.Serialization;
using Profiles.History.Utilities;

namespace Profiles.History
{
    public partial class ActivityDetails : System.Web.UI.Page
    {
         private Profiles.Framework.Template masterpage;

        protected void Page_Load(object sender, EventArgs e)
        {
            masterpage = (Framework.Template)base.Master;

            this.LoadAssets();

            this.LoadPresentationXML();

            masterpage.Tab = Request.QueryString["tab"];
            masterpage.PresentationXML = this.PresentationXML;
        }

        private void LoadAssets()
        {
            HtmlGenericControl body = (HtmlGenericControl)Page.Master.FindControl("bodyMaster");
            body.Attributes.Add("class", "history");
        }

        public void LoadPresentationXML()
        {
            string presentationxml = string.Empty;

            presentationxml = System.IO.File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + "/History/PresentationXML/ActivityDetails.xml");
            
            this.PresentationXML = new XmlDocument();
            this.PresentationXML.LoadXml(presentationxml);
            Framework.Utilities.DebugLogging.Log(presentationxml);

        }
        public XmlDocument PresentationXML { get; set; }

        [System.Web.Services.WebMethod]
        public static string GetActivities(Int64 referenceActivityId, int count, bool newActivities)
        {
            Profiles.History.Utilities.DataIO data = new Profiles.History.Utilities.DataIO();
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            List<Activity> activities = null;
            if (newActivities)
            {
                // get the latest and remove any that we already have
                activities = new List<Activity>();
                // we should probably make the data function smart enough to not return a bunch we already have
                // to save the loop
                foreach (Activity activity in data.GetActivity(-1, count, true))
                {
                    if (activity.Id > referenceActivityId)
                    {
                        activities.Add(activity);
                    }
                }
            }
            else
            {
                activities = data.GetActivity(referenceActivityId, count, true);
            }
            return serializer.Serialize(activities);
        }
    
    }
    
}
