﻿using System;
using System.Collections.Generic;
using System.Web;
using System.Reflection;
using System.Web.UI;
using System.Xml;
using System.Web.UI.HtmlControls;

namespace Profiles.Framework.Utilities
{
    public class ModulesProcessing : System.Web.UI.MasterPage
    {

        public UserControl LoadControl(string UserControlPath,  Profiles.Framework.Template masterpage, params object[] constructorParameters)
        {
            List<Type> constParamTypes = new List<Type>();
            //UserControl ctl = masterpage.LoadControl(UserControlPath) as UserControl;
            UserControl ctl = masterpage.LoadControl(UserControlPath) as UserControl;

            foreach (object constParam in constructorParameters)
            {
                constParamTypes.Add(constParam.GetType());
            }

            // Find the relevant constructor
            ConstructorInfo constructor = ctl.GetType().BaseType.GetConstructor(constParamTypes.ToArray());

            //And then call the standard constructor
            if (constructor == null)
                throw new MemberAccessException("The requested constructor was not found on : " + ctl.GetType().BaseType.ToString());
            else
            {
                try
                {
                    constructor.Invoke(ctl, constructorParameters);
                }
                catch (Exception ex)
                {
                    if (ex.GetBaseException() != null)
                    {
                        DebugLogging.Log("Base exception invoking constructor for " + ctl.GetType().BaseType.ToString() + " : " + ex.GetBaseException().Message + " ++ " + ex.GetBaseException().StackTrace);
                    }
                    throw new MemberAccessException("Could not construct " + ctl.GetType().BaseType.ToString() + " from " + UserControlPath, ex);
                }
            }

            return ctl;
        }
        public List<Module> FetchModules(XmlNode property)
        {

            XmlDocument document = new XmlDocument();

            document.LoadXml(property.InnerXml);

            ModulesProcessing mp = new ModulesProcessing();
            return mp.LoadModules(document);
        }


        public List<Module> LoadModules(XmlDocument xml)
        {
            XmlNodeList modules;
            XmlNodeList paramlist;
            List<Module> modulelist = new List<Module>();
            List<ModuleParams> moduleparams;

            string key = string.Empty;
            string displayrule = string.Empty;


            modules = xml.GetElementsByTagName("Module");

            if (modules.Count == 0)
            {   //this is because the xml can have an empty FrameworkPanel node passed in with just attributes and no modules
                //If this is the case, we need to load up a blank module and then the page will display an empty col based on the Sort Attribute
                modulelist.Add(new Module("", "", null, ""));
            }
            else
            {
                for (int i = 0; i < modules.Count; i++)
                {
                    key = modules[i].Attributes["ID"].Value;

                    if (modules[i].Attributes["DisplayRule"] != null)
                        displayrule = modules[i].Attributes["DisplayRule"].Value;

                    moduleparams = new List<ModuleParams>();

                    for (int j = 0; j < modules[i].ChildNodes.Count; j++)
                    {
                        switch (modules[i].ChildNodes[j].Name)
                        {
                            case "ParamList":

                                paramlist = modules[i].ChildNodes[j].ChildNodes;

                                if (paramlist != null)
                                {
                                    if (paramlist.Count > 0)
                                    {
                                        for (int l = 0; l < paramlist.Count; l++)
                                        {
                                            if (paramlist[l].InnerXml != "")
                                                moduleparams.Add(new ModuleParams(paramlist[l]));
                                        }
                                    }
                                }
                                break;

                        }
                    }

                    if (ModuleCatalogueCache.Instance.GetModule(key) != null)
                    {


                        modulelist.Add(new Module(ModuleCatalogueCache.Instance.GetModule(key).Path, key, moduleparams, displayrule, ModuleCatalogueCache.Instance.GetModule(key).css));
                    }
                }
            }
            return modulelist;
        }

        public string RenderView(UserControl control, string theme)
        {
            Page pageHolder = new Page();
            // needed for Themes to work!
            pageHolder.Theme = theme;

            pageHolder.Controls.Add(new HtmlHead());
            pageHolder.Controls.Add(control);

            System.IO.StringWriter result = new System.IO.StringWriter();
            HttpContext.Current.Server.Execute(pageHolder, result, false);
            // remove the <head>stuff</head> section.
            // hate to do this as String vs XML but because HTMl can be messy, this is actually safer
            string retval = result.ToString();
            return retval.Remove(retval.IndexOf("<head>"), retval.IndexOf("</head>") - retval.IndexOf("<head>") + "</head>".Length);
        }
    }
}
