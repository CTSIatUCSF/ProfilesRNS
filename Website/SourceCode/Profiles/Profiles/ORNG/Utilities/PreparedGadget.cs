using System;
using System.Web;
using System.Text;
using Profiles.Framework.Utilities;


namespace Profiles.ORNG.Utilities
{

    public class PreparedGadget : IComparable<PreparedGadget>
    {
        private GadgetSpec gadgetSpec;
        private OpenSocialManager openSocialManager;
        private string securityToken;
        private string view;
        private string optParams;
        private string chromeId;

        // tool gadgets
        public PreparedGadget(GadgetSpec gadgetSpec, OpenSocialManager openSocialManager)
        {
            this.gadgetSpec = gadgetSpec;
            this.openSocialManager = openSocialManager;
            this.securityToken = openSocialManager.GetSecurityToken(GetGadgetURL());

            // look at the view requirements and what page we are on to set some things
            GadgetViewRequirements viewReqs = GetGadgetViewRequirements();
            if (viewReqs != null)
            {
                this.view = viewReqs.GetView();
                this.chromeId = viewReqs.GetChromeIdBase() + "-" + GetAppId();
                this.optParams = viewReqs.GetOptParams();
            }
            else  // must be a sandbox gadget
            {
                this.view = "sandbox";
                this.chromeId = "gadgets-sandbox-" + GetAppId();
                this.optParams = "{}";
            }
        }

        // OntologyGadgets
        public PreparedGadget(GadgetSpec gadgetSpec, OpenSocialManager openSocialManager, string view, string optParams)
        {
            this.gadgetSpec = gadgetSpec;
            this.openSocialManager = openSocialManager;
            this.securityToken = openSocialManager.GetSecurityToken(GetGadgetURL());
            this.view = view;
            this.chromeId ="gadgets-ontology-" + GetAppId();
            this.optParams = optParams == null || optParams.Trim() == string.Empty ? "{}" : optParams;
        }

        public int CompareTo(PreparedGadget other)
        {
            GadgetViewRequirements gvr1 = this.GetGadgetViewRequirements();
            GadgetViewRequirements gvr2 = other.GetGadgetViewRequirements();
            return ("" + this.GetChromeId() + (gvr1 != null ? 1000 + gvr1.GetDisplayOrder() : Int32.MaxValue)).CompareTo("" + other.GetChromeId() + (gvr2 != null ? 1000 + gvr2.GetDisplayOrder() : Int32.MaxValue));
        }

        private GadgetViewRequirements GetGadgetViewRequirements() 
        {
            return gadgetSpec.GetGadgetViewRequirements(openSocialManager.GetPageName());
        }

        public string GetSecurityToken()
        {
            return securityToken;
        }

        public string GetChromeId()
        {
            return chromeId;
        }

        public string GetView()
        {
            return view;
        }

        public string GetOptParams()
        {
            return optParams;
        }

        // passthroughs
        public int GetAppId()
        {
            return gadgetSpec.GetAppId();
        }

        public string GetLabel()
        {
            return gadgetSpec.GetLabel();
        }

        public string GetGadgetURL()
        {
            Brand brand = Brand.GetCurrentBrand();
            return gadgetSpec.GetGadgetURL(brand != null ? brand.GetInstitution() : null);
        }

        public bool Unrecognized()
        {
            return gadgetSpec.Unrecognized();
        }

    }

}