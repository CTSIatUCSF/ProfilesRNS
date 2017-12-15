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

        public Institution(int Id, string Name, string Abbreviation, Int64 NodeID, string URI, string ShibbolethIdP)
        {
            this.Id = Id;
            this.Name = Name;
            this.Abbreviation = Abbreviation;
            this.NodeID = NodeID;
            this.URI = URI;
            this.ShibbolethIdP = ShibbolethIdP;
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
    }
}