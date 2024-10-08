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
using System.Xml;
using System.Xml.Xsl;

using Profiles.Framework.Utilities;

namespace Profiles.Framework.Modules.ApplyXSLT
{
    public partial class ApplyXSLT : Framework.Utilities.BaseModule
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DrawProfilesModule();
        }

        public ApplyXSLT() : base() { }
        public ApplyXSLT(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {


        }
        public void DrawProfilesModule()
        {

            XsltArgumentList args = new XsltArgumentList();
            args.AddParam("root", "", Brand.GetThemedDomain());

            //If your module performs a data request, based on the DataURI parameter then call ReLoadBaseData
            base.GetDataByURI();

            DateTime d = DateTime.Now;

            Framework.Utilities.DebugLogging.Log("{ApplyXSLT Start} " + base.GetModuleParamString("XSLTPath"));          


            XslCompiledTransform xslt = new XslCompiledTransform();

            // Eric Meeks, theme work
            litGeneric.Text = Utilities.XslHelper.TransformInMemory(Server.MapPath(base.GetModuleParamString("XSLTPath")), args, base.BaseData.OuterXml).Replace(Root.Domain, Brand.GetThemedDomain());            
            Framework.Utilities.DebugLogging.Log("{ApplyXSLT End} Milliseconds:" + (DateTime.Now - d).TotalMilliseconds);

        }
      
    }


}