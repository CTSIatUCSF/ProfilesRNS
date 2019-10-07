using System;
using System.Configuration;
using System.IO;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public static class DebugLogging
    {

        private static bool LoggingIsEnabled()
        {
            return ("request".Equals(ConfigurationSettings.AppSettings["DEBUG"]) && HttpContext.Current != null && HttpContext.Current.Request != null &&
                "true".Equals(HttpContext.Current.Request.QueryString["DEBUG"])) || Convert.ToBoolean(ConfigurationSettings.AppSettings["DEBUG"]);
        }

        public static void Log(string msg)
        {
            //Each error that occurs will trigger this event.
            try
            {
                string path = string.Empty;


                if (LoggingIsEnabled())
                {
                    if (ConfigurationSettings.AppSettings["DEBUG_PATH"] != null)
                    {
                        path = ConfigurationSettings.AppSettings["DEBUG_PATH"];

                        using (StreamWriter w = File.AppendText(path))
                        {
                            // write a line of text to the file
                            w.WriteLine("\t" + msg.Trim() + " " + DateTime.Now.ToLongTimeString());
                            w.Close();
                        }
                    }

                }
            }
            catch (Exception ex)
            {

            }

        }
        public static void Log(string msg, RDFTriple triple)
        {
            //Each error that occurs will trigger this event.
            try
            {
                string path = string.Empty;

                if (LoggingIsEnabled())
                {
                    if (ConfigurationSettings.AppSettings["DEBUG_PATH"] != null)
                    {
                        path = ConfigurationSettings.AppSettings["DEBUG_PATH"];

                        using (StreamWriter w = File.AppendText(path))
                        {
                            if (triple.Subject == 0)
                            {
                                // write a line of text to the file
                                w.WriteLine("URI= " + triple.URI + "==>" + msg.Trim() + " at= " + DateTime.Now.ToLongTimeString());
                            }
                            else
                            {
                                // write a line of text to the file
                                w.WriteLine("SPO= " + triple.Subject.ToString() + " " + triple.Predicate.ToString() + " " + triple.Object.ToString() + "==>" + msg.Trim() + " at= " + DateTime.Now.ToLongTimeString());
                            }
                            w.Close();
                        }
                    }
                }
            }
            catch (Exception ex)
            {

            }

        }

    }
}
