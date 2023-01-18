/*  
 
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
using System.Configuration;
using Profiles.Search.Utilities;
using Profiles.Framework.Utilities;

namespace Profiles.Search.Modules.ModernSearch
{
    public partial class ModernSearch : BaseModule
    {
                
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Brand.GetCurrentBrand().GetInstitution() != null)
            {
                BrandName = Brand.GetCurrentBrand().GetInstitution().GetAbbreviation();
            }
            else if (Brand.GetCurrentBrand() != Brand.getDefault())
            {
                BrandName = Brand.GetCurrentBrand().Theme;
            }
            else
            {
                BrandName = "";
            }
            DrawProfilesModule();       
        
        }

        public ModernSearch() : base() { }

        public ModernSearch(XmlDocument pagedata, List<ModuleParams> moduleparams, XmlNamespaceManager pagenamespaces)
        {
        }
        private void DrawProfilesModule()
        {
        }

        public string GetThemedDomain()
        {
            return Brand.GetThemedDomain();
        }

        public string GetInstitutionURI()
        {
            return Brand.GetCurrentBrand().IsMultiInstitutional() ? "" : Brand.GetCurrentBrand().GetInstitution().GetURI();
        }

        public string GetOtherFilters()
        {
                return Brand.GetCurrentBrand().IsMultiInstitutional() ? Brand.GetCurrentBrand().PersonFilter : "";
        }

        public string BrandName { get; set; }
    }
}