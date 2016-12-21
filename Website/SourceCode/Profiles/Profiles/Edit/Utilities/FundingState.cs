using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Profiles.Edit.Utilities
{
    public class FundingState : IComparable 
    {
        private string _startdate;
        private string _enddate;

        public Guid FundingRoleID { get; set; }
        public int PersonID { get; set; }
        public long SubjectID { get; set; }
        public string Source { get; set; }
        public string FundingID { get; set; }
        public string CoreProjectNum { get; set; }
        public string FullFundingID { get; set; }
        public string RoleLabel { get; set; }
        public string RoleDescription { get; set; }
        public string AgreementLabel { get; set; }
        public string SponsorAwardID { get; set; }
        public string GrantAwardedBy { get; set; }
        public string StartDate
        {
            get
            {
                DateTime dt;
                if (!DateTime.TryParse(_startdate, out dt))
                    return "?";
                if (dt == DateTime.Parse("1/1/1900"))
                    return "?";
                return _startdate;
            }
            set { _startdate = value; }
        }
        public string EndDate
        {
            get
            {
                DateTime dt;
                if (!DateTime.TryParse(_enddate, out dt))
                    return "?";
                if (dt == DateTime.Parse("1/1/1900"))
                    return "?";
                return _enddate;
            }
            set { _enddate = value; }
        }

        public string PrincipalInvestigatorName { get; set; }
        public string PIID { get; set; }
        public string Abstract { get; set; }
        public string SubProjectID { get; set; }
        public List<FundingState> SubFundingState { get; set; }

        private DateTime GetStartDateTime()
        {
            DateTime dt;
            if (!DateTime.TryParse(_startdate, out dt))
                return DateTime.Parse("1/1/1900");
            return dt;
        }

        private DateTime GetEndDateTime()
        {
            DateTime dt;
            if (!DateTime.TryParse(_enddate, out dt))
                return DateTime.Parse("1/1/1900");
            return dt;
        }

        public bool hasData
        {
            get
            {
                return (!String.IsNullOrEmpty(FundingID) || !String.IsNullOrEmpty(CoreProjectNum)
                    || !String.IsNullOrEmpty(FullFundingID) || !String.IsNullOrEmpty(RoleLabel)
                    || !String.IsNullOrEmpty(RoleDescription) || !String.IsNullOrEmpty(AgreementLabel)
                    || !String.IsNullOrEmpty(PrincipalInvestigatorName) || !String.IsNullOrEmpty(PIID)
                    || !String.IsNullOrEmpty(Abstract) || !String.IsNullOrEmpty(SubProjectID)
                    || !String.IsNullOrEmpty(SponsorAwardID) || !String.IsNullOrEmpty(GrantAwardedBy)
                    || SubFundingState != null);
            }
        }

        public int CompareTo(object obj)
        {
            if (obj == null) return 1;

            FundingState other = obj as FundingState;
            if (other != null)
            {
                int compare = -GetStartDateTime().CompareTo(other.GetStartDateTime());
                if (compare == 0)
                {
                    compare = -GetEndDateTime().CompareTo(other.GetEndDateTime());
                    if (compare == 0 && !String.IsNullOrEmpty(FundingID) && !String.IsNullOrEmpty(other.FundingID))
                    {
                        compare = FundingID.CompareTo(other.FundingID);
                    }
                }
                return compare;
            }
            else
                throw new ArgumentException("Object is not a FundingState");
        }



    }


}