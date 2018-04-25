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
        private static Dictionary<Int32, Institution> ById= new Dictionary<Int32, Institution>();

        public static Institution GetByAbbreviation(string Abbreviation) 
        {
            return String.IsNullOrEmpty(Abbreviation) ? null : ByAbbreviation[Abbreviation];
        }

        public static Institution GetByID(Int32 Id)
        {
            return ById[Id];
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
            ById.Add(Id, this);
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