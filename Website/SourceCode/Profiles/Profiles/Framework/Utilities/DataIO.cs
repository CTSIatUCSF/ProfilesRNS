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
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Xml;
using System.Configuration;
using System.Web;
using System.Diagnostics;
using System.Reflection;

namespace Profiles.Framework.Utilities
{
    /// <summary>
    ///     This class is used for all database IO of the web data layer of profiles.  
    ///     Plus contains generic data base IO methods for building Command Objects, Data Readers ect...
    /// 
    /// </summary>
    public partial class DataIO
    {
        public string _ErrorMsg = "";
        public string _ErrorNumber = "";

        public XmlDocument GetPropertyRangeList(string propertyuri)
        {
            string xmlstr = string.Empty;
            XmlDocument xmlrtn = new XmlDocument();
            string key = propertyuri;
            SessionManagement sm = new SessionManagement();

            if (Framework.Utilities.Cache.Fetch(key) == null)
            {
                try
                {
                    Framework.Utilities.DebugLogging.Log("{CLOUD} DATA BASE start GetPropertyRangeList(propertyuri)");
                    string connstr = GetConnectionString();

                    SqlConnection dbconnection = new SqlConnection(connstr);
                    SqlCommand dbcommand = new SqlCommand();

                    SqlDataReader dbreader;
                    dbconnection.Open();
                    dbcommand.CommandType = CommandType.StoredProcedure;

                    dbcommand.CommandTimeout = this.GetCommandTimeout();

                    dbcommand.CommandText = "[rdf.].getpropertyrangelist";

                    dbcommand.Parameters.Add(new SqlParameter("@PropertyURI", propertyuri));

                    dbcommand.Connection = dbconnection;

                    dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);
                    Framework.Utilities.DebugLogging.Log("{CLOUD} DATA BASE end GetPresentationData(rdf, presentation)");

                    while (dbreader.Read())
                    {
                        xmlstr += dbreader[0].ToString();
                    }

                    if (!dbreader.IsClosed)
                        dbreader.Close();

                    xmlrtn.LoadXml(xmlstr);

                    Framework.Utilities.Cache.Set(key, xmlrtn);
                    xmlstr = string.Empty;

                }
                catch (Exception e)
                {
                    Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
                    throw new Exception(e.Message);
                }
            }
            else
            {
                Framework.Utilities.DebugLogging.Log("{CLOUD} CACHE start GetPresentationData(rdf, presentation)");
                xmlrtn = Framework.Utilities.Cache.Fetch(key);
                Framework.Utilities.DebugLogging.Log("{CLOUD} CACHE end GetPresentationData(rdf, presentation)");
            }

            return xmlrtn;


        }


        #region "RESOLVE"


        /// <summary>
        ///     Method used to resolve the RESTful URL for Entities and Relationships.  The Profiles framwork contains a database stored procedure that is used to process
        ///   the application and 9 URL parameters in the RESTful URL Pattern that is defined in the RegisterRoutes method of the Global.asax file.
        ///   
        /// </summary>
        /// <param name="applicaitonname"> the applictionname is Param0 in the RESTful URL pattern in the Global.asax file.  The default install of Profiles has an application name of "profile"</param>
        /// <param name="param1">Param1 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param2">Param2 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param3">Param3 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param4">Param4 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param5">Param5 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param6">Param6 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param7">Param7 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param8">Param8 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="param9">Param9 in the RESTful URL pattern in the RegisterRoutes method of the Global.asax file</param>
        /// <param name="sessionid">The Profiles custom SessionID used to track the users navigation and activity that is stored as a Profiles Network.</param>
        /// <returns></returns>
        public URLResolve GetResolvedURL(string applicationname,
                                        string param1,
                                        string param2,
                                        string param3,
                                        string param4,
                                        string param5,
                                        string param6,
                                        string param7,
                                        string param8,
                                        string param9,
                                        string sessionid,
                                        string resturl,
                                        string useragent,
                                        string contenttype)
        {

            //Add the URL from the browser and then the full

            URLResolve rtn = null;

            try
            {
                SqlParameter[] param = new SqlParameter[14];
                param[0] = new SqlParameter("@ApplicationName", applicationname);
                param[1] = new SqlParameter("@param1", param1);
                param[2] = new SqlParameter("@param2", param2);
                param[3] = new SqlParameter("@param3", param3);
                param[4] = new SqlParameter("@param4", param4);
                param[5] = new SqlParameter("@param5", param5);
                param[6] = new SqlParameter("@param6", param6);
                param[7] = new SqlParameter("@param7", param7);
                param[8] = new SqlParameter("@param8", param8);
                param[9] = new SqlParameter("@param9", param9);
                param[10] = new SqlParameter("@SessionID", sessionid);
                param[11] = new SqlParameter("@resturl", resturl);
                param[12] = new SqlParameter("@useragent", useragent);
                param[13] = new SqlParameter("@ContentType", contenttype);

                using (SqlDataReader dbreader = GetSQLDataReader(GetDBCommand("", "[Framework.].[ResolveURL]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param)))
                {
                    dbreader.Read();

                    rtn = new URLResolve(Convert.ToBoolean(dbreader["Resolved"]), dbreader["ErrorDescription"].ToString(), dbreader["ResponseURL"].ToString(),
                        dbreader["ResponseContentType"].ToString(), dbreader["ResponseStatusCode"].ToString(), Convert.ToBoolean(dbreader["ResponseRedirect"]), Convert.ToBoolean(dbreader["ResponseIncludePostData"]));
                }
            }
            catch (Exception ex)
            {
                if (rtn == null)
                {
                    rtn = new URLResolve(false, "error with data", "", "", "", false, false);
                }
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace);
            }



            return rtn;
        }



        #endregion

        #region "REST"

        public SqlDataReader GetRESTApplications()
        {

            string sql = "Select * from [Framework.].RestPath with(nolock) order by len(ApplicationName) desc";

            SqlDataReader sqldr = this.GetSQLDataReader("", sql, CommandType.Text, CommandBehavior.CloseConnection, null);

            return sqldr;
        }

        public string GetRESTBasePath()
        {
            string rtn = string.Empty;

            if (Framework.Utilities.Cache.FetchObject("GetRESTBasePath") == null)
            {

                string sql = "exec [FRAMEWORK.].[GetBasePath]";

                using (SqlDataReader sqldr = this.GetSQLDataReader(sql, CommandType.Text, CommandBehavior.CloseConnection, null))
                {

                    while (sqldr.Read())
                    {
                        rtn = sqldr[0].ToString();
                    }

                    if (!sqldr.IsClosed)
                        sqldr.Close();

                }
                Framework.Utilities.Cache.Set("GetRESTBasePath", rtn);
            }
            else
            {
                rtn = (string)Framework.Utilities.Cache.FetchObject("GetRESTBasePath");
            }

            return rtn;
        }


        public string GetRESTBaseURI()
        {
            string rtn = string.Empty;

            if (Framework.Utilities.Cache.FetchObject("GetRESTBaseURI") == null)
            {

                string sql = "exec [FRAMEWORK.].[GetBaseURI]";

                using (SqlDataReader sqldr = this.GetSQLDataReader(sql, CommandType.Text, CommandBehavior.CloseConnection, null))
                {

                    while (sqldr.Read())
                    {
                        rtn = sqldr[0].ToString();
                    }

                    if (!sqldr.IsClosed)
                        sqldr.Close();
                }
                Framework.Utilities.Cache.Set("GetRESTBaseURI", rtn);
            }
            else
            {
                rtn = (string)Framework.Utilities.Cache.FetchObject("GetRESTBaseURI");
            }

            return rtn;
        }
        #endregion

        public Int64 GetSessionSecurityGroup()
        {

            string connstr = GetConnectionString();
            SessionManagement sm = new SessionManagement();

            SqlConnection dbconnection = new SqlConnection(connstr);
            Int64 accesscode = 0;

            SqlParameter[] param;

            param = new SqlParameter[4];

            SqlCommand dbcommand = new SqlCommand();

            dbconnection.Open();

            dbcommand.CommandTimeout = this.GetCommandTimeout();

            param[0] = new SqlParameter("@SessionID", sm.Session().SessionID);
            param[1] = new SqlParameter("@securitygroupid", 0);
            param[1].Direction = ParameterDirection.Output;
            param[2] = new SqlParameter("@hasspecialviewaccess", 0);
            param[2].Direction = ParameterDirection.Output;
            param[3] = new SqlParameter("@hasspecialeditaccess", 0);
            param[3].Direction = ParameterDirection.Output;

            dbcommand.Connection = dbconnection;

            try
            {
                //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                ExecuteSQLDataCommand(GetDBCommand(ref dbconnection, "[RDF.Security].[GetSessionSecurityGroup]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param));


            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace);
            }

            dbcommand.Connection.Close();
            if (param[1] != null)
                accesscode = Convert.ToInt64(param[1].Value);

            return accesscode;


        }

        public string GetConnectionString()
        {

            //Need to test for IsBot in session
            string connstr = string.Empty;

            try
            {
                if (this.Session != null)
                {
                    if (this.Session.IsBot)
                        connstr = ConfigurationManager.ConnectionStrings["ProfilesBOTDB"].ConnectionString;
                    else
                        connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

                }
                else
                    connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

            }
            catch (Exception ex)
            {//An error will kick in if this is an Application level request for the rest path data because a session does not exist. If no session exists
                Framework.Utilities.DebugLogging.Log("Exception in BOT determination! " + connstr + " CONNECTION USED" + "\r\n");
                connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;
            }

            Framework.Utilities.DebugLogging.Log(connstr + " CONNECTION USED" + "\r\n");

            return connstr;
        }

        public List<string> GetEagleI(Int64 subject)
        {


            List<string> html = new List<string>();

            try
            {


                string connstr = this.GetConnectionString();
                SqlConnection dbconnection = new SqlConnection(connstr);

                dbconnection.Open();

                SqlCommand dbcommand = new SqlCommand();
                dbcommand.CommandType = CommandType.Text;
                dbcommand.CommandText = "Select * from [Profile.Data].[EagleI.HTML] with(nolock) where nodeid = " + subject.ToString();
                dbcommand.CommandTimeout = this.GetCommandTimeout();

                dbcommand.Connection = dbconnection;
                using (SqlDataReader dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (dbreader.Read())
                        html.Add(dbreader["HTML"].ToString());

                    if (!dbreader.IsClosed)
                        dbreader.Close();
                }




            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
            return html;

        }



        #region "DB SQL.NET Methods"

        /// <summary>
        /// returns sqlconnection object
        /// </summary>
        /// <param name="Connectionstring"></param>
        /// <returns></returns>
        public SqlConnection GetDBConnection(string Connectionstring)
        {
            if (Connectionstring.CompareTo("") == 0)
                Connectionstring = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;
            else
            {
                if (Connectionstring.Length < 25)
                    Connectionstring = ConfigurationManager.ConnectionStrings[Connectionstring].ConnectionString;
            }
            SqlConnection dbsqlconnection = new SqlConnection(Connectionstring);
            try
            {
                dbsqlconnection.Open();
               
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message);
                Framework.Utilities.DebugLogging.Log(ex.StackTrace);
            }
            return dbsqlconnection;
        }

        public SqlCommand GetDBCommand(SqlConnection sqlcn, String CmdText, CommandType CmdType, CommandBehavior CmdBehavior, SqlParameter[] sqlParam)
        {
            SqlCommand sqlcmd = null;

            try
            {
                sqlcmd = new SqlCommand(CmdText, sqlcn);
                sqlcmd.CommandType = CmdType;

                sqlcmd.CommandTimeout = GetCommandTimeout();

                Framework.Utilities.DebugLogging.Log("CONNECTION STRING " + sqlcn.ConnectionString);
                Framework.Utilities.DebugLogging.Log("COMMAND TEXT " + CmdText);
                Framework.Utilities.DebugLogging.Log("COMMAND TYPE " + CmdType.ToString());
                if (sqlParam != null)
                {
                    Framework.Utilities.DebugLogging.Log("NUMBER OF PARAMS " + sqlParam.Length);
                    AddSQLParameters(sqlcmd, sqlParam);
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message);
                Framework.Utilities.DebugLogging.Log(ex.StackTrace);
            }
            return sqlcmd;
        }

        public SqlCommand GetDBCommand(String CmdText, CommandType CmdType, CommandBehavior CmdBehavior, SqlParameter[] sqlParam)
        {

            SqlCommand sqlcmd = null;

            try
            {
                string Connectionstring = this.GetConnectionString();
                sqlcmd = new SqlCommand(CmdText, GetDBConnection(Connectionstring));
                sqlcmd.CommandType = CmdType;
                sqlcmd.CommandTimeout = GetCommandTimeout();
                Framework.Utilities.DebugLogging.Log("CONNECTION STRING " + Connectionstring);
                Framework.Utilities.DebugLogging.Log("COMMAND TEXT " + CmdText);
                Framework.Utilities.DebugLogging.Log("COMMAND TYPE " + CmdType.ToString());
                if (sqlParam != null)
                    Framework.Utilities.DebugLogging.Log("NUMBER OF PARAMS " + sqlParam.Length);


                if (sqlParam != null)
                    AddSQLParameters(sqlcmd, sqlParam);


            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message);
                Framework.Utilities.DebugLogging.Log(ex.StackTrace);
            }
            return sqlcmd;
        }

        public SqlCommand GetDBCommand(string SqlConnectionString, String CmdText, CommandType CmdType, CommandBehavior CmdBehavior, SqlParameter[] sqlParam)
        {

            SqlCommand sqlcmd = null;

            try
            {
                sqlcmd = new SqlCommand(CmdText, GetDBConnection(SqlConnectionString));
                sqlcmd.CommandType = CmdType;
                sqlcmd.CommandTimeout = GetCommandTimeout();
                /********** Commented out by UCSF
                Framework.Utilities.DebugLogging.Log("CONNECTION STRING " + SqlConnectionString);
                Framework.Utilities.DebugLogging.Log("COMMAND TEXT " + CmdText);
                Framework.Utilities.DebugLogging.Log("COMMAND TYPE " + CmdType.ToString());
                if (sqlParam != null)
                    Framework.Utilities.DebugLogging.Log("NUMBER OF PARAMS " + sqlParam.Length);
                ********************************/

                if (sqlParam != null)
                    AddSQLParameters(sqlcmd, sqlParam);


            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message);
                Framework.Utilities.DebugLogging.Log(ex.StackTrace);
            }
            return sqlcmd;
        }

        public SqlCommand GetDBCommand(ref SqlConnection cn, String CmdText, CommandType CmdType, CommandBehavior CmdBehavior, SqlParameter[] sqlParam)
        {

            cn = GetDBConnection("");
            SqlCommand sqlcmd = null;

            try
            {
                sqlcmd = new SqlCommand(CmdText, cn);
                sqlcmd.CommandType = CmdType;
                sqlcmd.CommandTimeout = GetCommandTimeout();
                if (sqlParam != null)
                    AddSQLParameters(sqlcmd, sqlParam);

            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message);
                Framework.Utilities.DebugLogging.Log(ex.StackTrace);
            }

            return sqlcmd;
        }

        public void AddSQLParameters(SqlCommand sqlcmd, SqlParameter[] sqlParam)
        {
	        foreach (SqlParameter sqlParameter in sqlParam.Where(s => s != null))
		        sqlcmd.Parameters.Add(sqlParameter);
        }

        public SqlDataReader GetSQLDataReader(SqlCommand sqlcmd)
        {
            SqlDataReader sqldr = null;
            try
            {

                if (sqlcmd.Connection == null)
                {
                    sqlcmd.Connection = this.GetDBConnection("");
                }
                else if (sqlcmd.Connection.State == ConnectionState.Closed)
                {
                    sqlcmd.Connection = this.GetDBConnection("");
                }

                sqldr = sqlcmd.ExecuteReader(CommandBehavior.CloseConnection);

            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.Message);
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.StackTrace);
            }
            return sqldr;

        }


        public SqlDataReader GetSQLDataReader(String CmdText, CommandType CmdType, CommandBehavior CmdBehavior, SqlParameter[] sqlParam)
        {
            return GetSQLDataReader("ProfilesDB", CmdText, CmdType, CmdBehavior, sqlParam);
        }

        public SqlDataReader GetSQLDataReader(string ConnectionString, String CmdText, CommandType CmdType, CommandBehavior CmdBehavior, SqlParameter[] sqlParam)
        {

            SqlDataReader sqldr = null;
            try
            {

                sqldr = this.GetSQLDataReader(this.GetDBCommand(ConnectionString, CmdText, CmdType, CmdBehavior, sqlParam));


            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.Message);
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.StackTrace);
            }
            return sqldr;
        }

        public void ExecuteSQLDataCommand(SqlCommand sqlcmd)
        {
            try
            {
                sqlcmd.ExecuteNonQuery();
                sqlcmd.Dispose();
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.Message);
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.StackTrace);
                throw ex;

            }
        }

        public void ExecuteSQLDataCommand(string sqltext)
        {

            using (SqlConnection conn = GetDBConnection(""))
            {
                SqlCommand sqlcmd = new SqlCommand(sqltext, conn);
                sqlcmd.CommandType = CommandType.Text;
                sqlcmd.CommandTimeout = GetCommandTimeout();
                sqlcmd.ExecuteNonQuery();
            }
        }


        public void ExecuteSQLDataCommand(SqlCommand sqlcmd, object o)
        {

            try
            {
                o = sqlcmd.ExecuteScalar();
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.Message);
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.StackTrace);
            }

            sqlcmd.Dispose();


        }

        public int GetCommandTimeout()
        {
            return Convert.ToInt32(ConfigurationSettings.AppSettings["COMMANDTIMEOUT"]);

        }

        #endregion

        #region "SESSION"
        /// <summary>
        ///     Used to create a custom Profiles Session instance.  This instance is used to track and store user activity as a form of Profiles Network.
        /// </summary>
        /// <param name="session">ref of Framework.Session object that stores the state of a Profiles user session</param>
        public void SessionCreate(ref Session session)
        {
            SqlParameter[] param = new SqlParameter[4];
            param[0] = new SqlParameter("@RequestIP", session.RequestIP);
            param[1] = new SqlParameter("@HostName", session.HostName);
            param[2] = new SqlParameter("@UserAgent", session.UserAgent);
            param[3] = new SqlParameter("@IsBot", session.IsBot);

            using (SqlDataReader dbreader = GetSQLDataReader(GetDBCommand("","[User.Session].[CreateSession]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param)))
            {
                if (dbreader != null)

                {
                    if (dbreader.Read()) //Returns a data ready with one row of user Session Info. {Profiles Session Info, not IIS}
                    {
                        session.SessionID = dbreader["SessionID"].ToString();
                        session.CreateDate = dbreader["CreateDate"].ToString();
                        session.LastUsedDate = Convert.ToDateTime(dbreader["LastUsedDate"].ToString());
                        session.ViewSecurityGroup = Convert.ToInt64(dbreader["SecurityGroupID"]);

                        Utilities.DebugLogging.Log("Session object created:" + session.SessionID + " On " + session.CreateDate + " with " + session.RequestIP);
                    }
                }
                else
                {
                    session = null;

                }
            }
        }



        /// <summary>
        ///     Used to create a custom Profiles Session instance.  This instance is used to track and store user activity as a form of Profiles Network.
        /// </summary>
        /// <param name="session">ref of Framework.Session object that stores the state of a Profiles user session</param>
        public void SessionUpdate(ref Session session)
        {

            string connstr = this.GetConnectionString();
            SessionManagement sm = new SessionManagement();

            SqlConnection dbconnection = new SqlConnection(connstr);

            SqlParameter[] param;

            param = new SqlParameter[8];

            SqlCommand dbcommand = new SqlCommand();

            dbconnection.Open();

            dbcommand.CommandTimeout = this.GetCommandTimeout();

            param[0] = new SqlParameter("@SessionID", session.SessionID);

            param[1] = session.UserID > 0 ? new SqlParameter("@UserID", session.UserID) : new SqlParameter("@UserID", SqlDbType.Int);
            param[1].Direction = ParameterDirection.InputOutput;

            param[2] = new SqlParameter("@LastUsedDate", session.LastUsedDate);


            param[3] = new SqlParameter("@SessionPersonNodeID", 0);
            param[3].Direction = ParameterDirection.Output;

            param[4] = new SqlParameter("@SessionPersonURI", SqlDbType.VarChar, 400);
            param[4].Direction = ParameterDirection.Output;

            // UCSF
            param[5] = new SqlParameter("@UserURI", SqlDbType.VarChar, 400);
            param[5].Direction = ParameterDirection.Output;

            // UCSF
            param[6] = String.IsNullOrEmpty(session.DisplayName) ? new SqlParameter("@DisplayName", SqlDbType.VarChar, 255) : new SqlParameter("@DisplayName", session.DisplayName);
            param[6].Direction = ParameterDirection.InputOutput;

            if (session.LogoutDate > DateTime.Now.AddDays(-5))
            {
                param[7] = new SqlParameter("@LogoutDate", session.LogoutDate.ToString());
            }

            dbcommand.Connection = dbconnection;

            try
            {
                //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                ExecuteSQLDataCommand(GetDBCommand(ref dbconnection, "[User.Session].[UpdateSession]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param));
            }
            catch (Exception ex) 
            {
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.StackTrace);
            }

            try
            {
                dbcommand.Connection.Close();
                if (param[1].Value != null && param[1].Value != DBNull.Value)
                {
                    session.UserID = Convert.ToInt32(param[1].Value);
                }
                if (param[3].Value != null && param[3].Value != DBNull.Value)
                {
                    session.NodeID = Convert.ToInt64(param[3].Value);
                }
                if (param[4].Value != null && param[4].Value != DBNull.Value)
                {
                    session.PersonURI = param[4].Value.ToString();
                }
                session.UserURI = param[5].Value.ToString();
                session.DisplayName = param[6].Value.ToString();

                // set the view security group if the user is logged in. Hack by UCSF to match a harvard hack!
                if (session.IsLoggedIn())
                {
                    session.LoginDate = DateTime.Now;
                }
                if (session.UserID > 0)
                {
                    session.ViewSecurityGroup = -20;
                }
            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log("ERROR" + ex.StackTrace);
            }
        }

        //cache the session state local so you can test if this is a bot or now for the different data connections.
        private Session Session
        {
            get { return (Session)(HttpContext.Current.Session["PROFILES_SESSION"]); }
            set { HttpContext.Current.Session["PROFILES_SESSION"] = value; }
        }
        #endregion

        #region "ActiveNetwork"
        public SqlDataReader GetActiveNetwork(Int64 subject, bool details)
        {
            SqlDataReader dbreader = null;
            SessionManagement sm = new SessionManagement();
            XmlDocument data = new XmlDocument();
            try
            {
                SqlParameter[] param = new SqlParameter[3];
                param[0] = new SqlParameter("@SessionID", sm.Session().SessionID);

                param[1] = new SqlParameter("@Details", details);

                if (subject == 0)
                    param[2] = new SqlParameter("@Subject", DBNull.Value);
                else
                    param[2] = new SqlParameter("@Subject", subject);

                dbreader = GetSQLDataReader(GetDBCommand("", "[user.account].[relationship.getrelationship]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param));

            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace);
            }

            return dbreader;
        }

        public void SetActiveNetwork(Int64 subject, string relationshiptype, bool settoexists)
        {
            SessionManagement sm = new SessionManagement();

            try
            {

                SqlParameter[] param = new SqlParameter[4];
                param[0] = new SqlParameter("@SessionID", sm.Session().SessionID);
                param[1] = new SqlParameter("@Subject", subject);

                if (relationshiptype == null)
                    param[2] = new SqlParameter("@RelationshipType", DBNull.Value);
                else
                    param[2] = new SqlParameter("@RelationshipType", relationshiptype);

                param[3] = new SqlParameter("@SetToExists", settoexists);


                GetDBCommand("", "[user.account].[relationship.setrelationship]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param).ExecuteNonQuery();

            }
            catch (Exception ex)
            {
                Framework.Utilities.DebugLogging.Log(ex.Message + " ++ " + ex.StackTrace);
            }



        }


        #endregion

        #region "ERROR MESSAGES"

        /// <summary>
        /// Property: error message
        /// </summary>
        public string ErrorMessage
        {
            get { return _ErrorMsg; }
            set { _ErrorMsg = value; }
        }

        public string ErrorNumber
        {
            get { return _ErrorNumber; }
            set { _ErrorNumber = value; }
        }

        #endregion

        #region "Activity Log"

        public void SessionActivityLog()
        {
            Session session = new SessionManagement().Session();
            Cache.AlterDependency(session.SessionID);
            ActivityLog(0, session.PersonID, null, 0, null, null, null);
        }

        protected void EditActivityLog(long subjectID, string property, string privacyCode)
        {
            Cache.AlterDependency(subjectID.ToString());
            ActivityLog(subjectID, 0, property, 0, privacyCode, null, null);
        }

        protected void EditActivityLog(long subjectID, long propertyID, string privacyCode)
        {
            Cache.AlterDependency(subjectID.ToString());
            ActivityLog(subjectID, 0, null, propertyID, privacyCode, null, null);
        }

        protected void EditActivityLog(long subjectID, string property, string privacyCode, string param1, string param2)
        {
            Cache.AlterDependency(subjectID.ToString());
            ActivityLog(subjectID, 0, property, 0, privacyCode, param1, param2);
        }

        private void ActivityLog(long subjectID, int personId, string property, long propertyID, string privacyCode, string param1, string param2)
        {
            int userId = new SessionManagement().Session().UserID;
            int i = 1;
            string message = null;
            do
            {
                StackFrame frame = new StackFrame(i++);
                MethodBase method = frame.GetMethod();
                message = String.Format("{0}.{1}", method.DeclaringType.FullName, method.Name);
            } while (message.IndexOf("ActivityLog") != -1);

            // lookup 
            //Console.WriteLine(message);
            List<SqlParameter> param = new List<SqlParameter>();
            if (userId > 0)
                param.Add(new SqlParameter("@userId", userId));
            else
                param.Add(new SqlParameter("@userId", DBNull.Value));
            if (personId > 0)
                param.Add(new SqlParameter("@personId", personId));
            else
            {
                param.Add(new SqlParameter("@personId", DBNull.Value));
                param.Add(new SqlParameter("@subjectId", subjectID));
            }
            param.Add(new SqlParameter("@methodName", message));

            if (property != null)
                param.Add(new SqlParameter("@property", property));
            else
                param.Add(new SqlParameter("@property", DBNull.Value));
            if (propertyID > 0)
                param.Add(new SqlParameter("@propertyID", propertyID));
            if (privacyCode != null)
                param.Add(new SqlParameter("@privacyCode", Convert.ToInt32(privacyCode)));
            else
                param.Add(new SqlParameter("@privacyCode", DBNull.Value));
            if (param1 != null)
                param.Add(new SqlParameter("@param1", param1));
            else
                param.Add(new SqlParameter("@param1", DBNull.Value));
            if (param2 != null)
                param.Add(new SqlParameter("@param2", param2));
            else
                param.Add(new SqlParameter("@param2", DBNull.Value));

            using (SqlCommand comm = GetDBCommand("", "[Framework.].[Log.AddActivity]", CommandType.StoredProcedure, CommandBehavior.CloseConnection, param.ToArray()))
            {
                ExecuteSQLDataCommand(comm);
            }
         }

        public string GetProperty(Int64 predicateId)
        {
            SessionManagement sm = new SessionManagement();
            string connstr = GetConnectionString();

            SqlConnection dbconnection = new SqlConnection(connstr);
            SqlDataReader reader = null;
            string property = null;

            try
            {

                dbconnection.Open();


                //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                reader = GetDBCommand(dbconnection, "select Property FROM [Ontology.].[ClassProperty] where (Class = 'http://xmlns.com/foaf/0.1/Person' or Class = 'http://xmlns.com/foaf/0.1/Agent') and _PropertyNode = " + predicateId.ToString(), CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader();
                while (reader.Read())
                {
                    property = reader[0].ToString();
                }
            }
            catch (Exception e)
            {
                Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
                throw new Exception(e.Message);
            }
            finally
            {
                if (reader != null && !reader.IsClosed)
                    reader.Close();

                if (dbconnection.State != ConnectionState.Closed)
                    dbconnection.Close();
            }


            return property;
        }


        #endregion
        // UCSF
        public void LoadBrands()
        {
            // add the default
            //new Brand(Brand.DefaultBrandName, Brand.GetSystemTheme(), null, GetRESTBasePath(), true);

            using (SqlDataReader reader = GetDBCommand(ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString,
                "select Theme, BasePath, GATrackingID, PersonFilter from [UCSF.].[Brand]", CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader())
            {
                while (reader.Read())
                {
                    new Brand(reader[0].ToString(), reader[1].ToString(), reader[2].ToString(), reader[3].ToString(), LoadInstitutionsForTheme(reader[0].ToString()));
                }
            }
        }

        private List<Institution> LoadInstitutionsForTheme(string theme)
        {
            List<Institution> institutions = new List<Institution>();
            using (SqlDataReader reader = GetDBCommand(ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString,
                "SELECT InstitutionAbbreviation FROM [UCSF.].[Theme2Institution] WHERE Theme = '" + theme + "'", CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader())
            {
                while (reader.Read())
                {
                    institutions.Add(Institution.GetByAbbreviation(reader[0].ToString()));
                }
            }
            return institutions;
        }

        // Load all the ID's for people so we don't have to hit the DB all the time
        public void LoadUCSFIdSet()
        {
            string IDSetSQL = "select p.personid, p.nodeid, p.prettyurl, u.internalusername, p.InstitutionAbbreviation from [UCSF.].vwPerson p join [User.Account].[User] u on p.UserID = u.UserID";

            using (SqlDataReader reader = GetDBCommand(ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString,
                IDSetSQL, CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader())
            {
                while (reader.Read())
                {
                    new UCSFIDSet(Convert.ToInt32(reader[0]), Convert.ToInt64(reader[1]), reader[2].ToString(), reader[3].ToString(), Institution.GetByAbbreviation(reader[4].ToString()));
                }
            }
        }

        public void LoadInstitutions()
        {
            using (SqlDataReader reader = GetDBCommand(ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString,
                "EXEC [Profile.Data].[Organization.GetInstitutions]", CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader())
            {
                while (reader.Read())
                {
                    new Institution(Convert.ToInt32(reader[0]), reader[1].ToString(), reader[2].ToString(), Convert.ToInt64(reader[3]), reader[4].ToString(), reader[5].ToString(), reader[6].ToString(), reader[7].ToString());
                }
            }
        }
        

        #region "Groups"
        public bool IsGroupAdmin(int UserID)
        {
            SessionManagement sm = new SessionManagement();
            string connstr = ConfigurationManager.ConnectionStrings["ProfilesDB"].ConnectionString;

            SqlConnection dbconnection = new SqlConnection(connstr);
            SqlDataReader reader = null;
            int property = 0;

            try
            {

                dbconnection.Open();


                //For Output Parameters you need to pass a connection object to the framework so you can close it before reading the output params value.
                reader = GetDBCommand(dbconnection, "select Count(*) from [Profile.Data].[Group.Admin] where UserID = " + UserID, CommandType.Text, CommandBehavior.CloseConnection, null).ExecuteReader();
                while (reader.Read())
                {
                    property = reader.GetInt32(0);
                }
            }
            catch (Exception e)
            {
                Framework.Utilities.DebugLogging.Log(e.Message + e.StackTrace);
                throw new Exception(e.Message);
            }
            finally
            {
                if (reader != null && !reader.IsClosed)
                    reader.Close();

                if (dbconnection.State != ConnectionState.Closed)
                    dbconnection.Close();
            }
            return property > 0;
        }


        #endregion
        
    }
}
