/*  
 
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
  
*/
using System;
using ProfilesSearchAPI.Utilities;


namespace Profiles.Utilities
{
    /// <summary>
    ///     This class stores the Profiles custom session state
    /// 
    /// </summary>
    public class Session
    {
        private bool _canedit;
        private DateTime _logoutdate;
        public Session()
        {
            
        }
        public string SessionID { get; set; }
        public string SessionSequence { get; set; }
        public string CreateDate { get; set; }
        public DateTime LastUsedDate { get; set; }
        public DateTime LoginDate { get; set; }
        public DateTime LogoutDate { get; set; }
        public string RequestIP { get; set; }
        public string HostName { get; set; }
        public int UserID { get; set; }
        public int PersonID { get; set; }
        public Int64 NodeID { get; set; }
        public string PersonURI { get; set; }
        public string UserAgent { get; set; }

    }
    public class SessionHistory
    {
        public string SessionID { get; set; }
        public string PageURL { get; set; }
        public string PageName { get; set; }
        public string PageType { get; set; }
        public string PageID { get; set; }
        public bool IsVisible { get; set; }

    }

    /// <summary>
    ///     This Class is used to manage the custom Profiles session data and processes
    ///         
    /// 
    ///         
    /// 
    /// 
    /// 
    /// 
    /// </summary>
    public class SessionManagement
    {
        //ZAP - I need some type of redreict in this class for when session has expired
        public SessionManagement() { }

        /// <summary>
        /// Public method used to get the custom Profiles session object.  The object is stored in the current users session and can be accessed with the "PROFILES_SESSION" key.
        /// 
        /// If the session does not exist then this method will create the session by calling this.SessionCreate();
        /// </summary>
        /// <returns></returns>
        public string Session()
        {
            return this.SessionCreate();
        }
        public void SessionDistroy()
        {
            
        }

        // UCSF, from https://stackoverflow.com/questions/735350/how-to-get-a-users-client-ip-address-in-asp-net
        protected string GetIPAddress()
        {
            try
            {
                System.Web.HttpContext context = System.Web.HttpContext.Current;
                string ipAddress = context.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];

                if (!string.IsNullOrEmpty(ipAddress))
                {
                    string[] addresses = ipAddress.Split(',');
                    if (addresses.Length != 0)
                    {
                        return addresses[0];
                    }
                }
                return context.Request.ServerVariables["REMOTE_ADDR"];
            }
            catch (Exception e)
            {
                DebugLogging.Log(e.Message + " " + e.StackTrace);
            }
            return "unknown";
        }
        /// <summary>
        ///     Public method used to create an instance of the custom Profiles session object.
        /// </summary>
        public string SessionCreate()
        {
         
            ProfilesSearchAPI.Utilities.DataIO dataio = new ProfilesSearchAPI.Utilities.DataIO();

            Session session = new Session();

            session.RequestIP = GetIPAddress();
            session.HostName = System.Net.Dns.GetHostName();
            session.UserAgent = "Search API";
            
            dataio.SessionCreate(ref session);
            
            //Store the object in the current session of the user.
            return session.SessionID;
        }

            
       
    }

}
