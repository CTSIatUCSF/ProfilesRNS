using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles.Framework.Utilities
{
    public class Institution
    {
        private static Dictionary<string, Institution> ByAbbreviation = new Dictionary<string, Institution>();
        private static Dictionary<string, Institution> ByURI = new Dictionary<string, Institution>();

        public static Institution GetByAbbreviation(string Abbreviation) 
        {
            return String.IsNullOrEmpty(Abbreviation) ? null : ByAbbreviation[Abbreviation];
        }
        public static List<Institution> GetAll()
        {
            return ByAbbreviation.Values.ToList();
        }

        private int Id;
        private string Name;
        private string Abbreviation;
        private Int64 NodeID;
        private string URI;
        private string ShibbolethIdP;
        private string ShibbolethUserNameHeader;
        private string ShibbolethDisplayNameHeader;

        public Institution(int Id, string Name, string Abbreviation, Int64 NodeID, string URI, string ShibbolethIdP, string ShibbolethUserNameHeader, string ShibbolethDisplayNameHeader)
        {
            this.Id = Id;
            this.Name = Name;
            this.Abbreviation = Abbreviation;
            this.NodeID = NodeID;
            this.URI = URI;
            this.ShibbolethIdP = ShibbolethIdP;
            this.ShibbolethUserNameHeader = ShibbolethUserNameHeader;
            this.ShibbolethDisplayNameHeader = ShibbolethDisplayNameHeader;
            ByAbbreviation.Add(Abbreviation, this);
            ByURI.Add(URI, this);
        }

        public int GetId()
        {
            return Id;
        }

        public string GetName()
        {
            return Name;
        }

        public string GetAbbreviation()
        {
            return Abbreviation;
        }

        public Int64 GetNodeID()
        {
            return NodeID;
        }

        public string GetURI()
        {
            return URI;
        }

        public string GetShibbolethIdP()
        {
            return ShibbolethIdP;
        }

        // OK to just hard code this 
        public string GetTwitterHandle()
        {
            switch (Abbreviation)
            {
                case "UCSF":
                    return "@UCSF";
                case "UC Davis":
                    return "@UCDavis";
                case "UCI":
                    return "@UCIrvine";
                case "UCLA":
                    return "@UCLA";
                case "UCSD":
                    return "@UCSanDiego";
                case "USC":
                    return "@@USC";
            }
            return "";
        }

        public static bool IsPluginAllowedFor(String plugin, Institution inst)
        {
            // make fanicer and even DB driven if ever needed
            if ("GlobalHealthEquity".Equals(plugin))
            {
                return "UCSF".Equals(inst.GetAbbreviation());
            }
            else if ("Mentoring".Equals(plugin))
            {
                return "UC Davis".Equals(inst.GetAbbreviation()) || "UCSF".Equals(inst.GetAbbreviation());
            }
            else if ("Identity".Equals(plugin))
            {
                return "UCSF".Equals(inst.GetAbbreviation());
            }
            else if ("CollaborationInterests".Equals(plugin))
            {
                return "UCSF".Equals(inst.GetAbbreviation());
            }
            return true;
        }

        public string GetShibbolethUserNameHeader()
        {
            return ShibbolethUserNameHeader;
        }
        public string GetShibbolethDisplayNameHeader()
        {
            return ShibbolethDisplayNameHeader;
        }
    }
}