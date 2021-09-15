using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using Profiles.Framework.Utilities;

namespace Profiles.Profile.Modules
{
    public class BaseUCSFModule : BaseModule
    {
        private Profiles.Profile.Utilities.DataIO propdata;
        public BaseUCSFModule()
        {
        }
        public BaseUCSFModule(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
            : base(pagedata, moduleparams, pagenamespaces)
        {
            this.Init();
            this.LoadRawQueryString();
            this.BaseData = pagedata;
            this.ModuleParams = moduleparams;
            this.Namespaces = pagenamespaces;

            this.PropertyListXML = propdata.GetPropertyList(pagedata, base.PresentationXML, this.PredicateURI, false, true, false);
        }
        private new void Init()
        {

            if (Request.QueryString["subject"] != null)
                this.SubjectID = Convert.ToInt64(Request.QueryString["subject"]);
            else if (base.GetRawQueryStringItem("subject") != null)
                this.SubjectID = Convert.ToInt64(base.GetRawQueryStringItem("subject"));

            //name of the class that owns this class;
            if (Request.QueryString["predicateuri"] != null)
                this.PredicateURI = Request.QueryString["predicateuri"];
            else if (base.GetRawQueryStringItem("subject") != null)
                this.PredicateURI = base.GetRawQueryStringItem("predicateuri");


            this.propdata = new Profiles.Profile.Utilities.DataIO();
        }
        public long SubjectID { get; set; }
        public Int32 PersonID { get; set; }
        string _predicateuri = string.Empty;
        public string PredicateURI
        {
            get { return _predicateuri.Replace("!", "#"); }
            set { _predicateuri = value; }
        }
        public XmlDocument PropertyListXML { get; set; }

    }
}