<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ModernSearch.ascx.cs"
    Inherits="Profiles.Search.Modules.ModernSearch.ModernSearch" %>
<%--
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
 --%>

<script type="text/javascript">


    function runScript(e) {
       
        if (e.keyCode == 13) {
            search();
            return false;
        }
        return true;
    }


    function search() {
        var keyword = document.getElementById("txtKeyword").value;
        var institution = '<%=GetInstitutionURI()%>';        
        var otherfilters = '<%=GetOtherFilters()%>';        
        var classuri = 'http://xmlns.com/foaf/0.1/Person';
		var showcolumns = institution != '' ? '10' : '9'; 

        document.location.href = '<%=GetThemedDomain()%>/search/default.aspx?searchtype=people&searchfor=' + keyword + '&exactphrase=false&institution=' + institution +
            '&classuri=' + classuri + '&otherfilters=' + otherfilters + '&showcolumns=' + showcolumns + '&new=true&perpage=15&offset=0';
        return false;
    }

    
</script>

<div class="activeContainer researcherprofiles--primary-search--search-form--container" id="modernsearch">
    <div class="activeContainerTop">
	Find <%=this.BrandName %> experts on…
    </div>	
	  <div class="activeContainerCenter">
		<div class="researcherprofiles--primary-search--search-box--input-group" onkeypress="JavaScript:runScript(event);" class="searchForm" width="100%">
		  <input type="text" name="txtKeyword" id="txtKeyword" title="keyword">
		  <a href="JavaScript:search();" class="researcherprofiles--primary-search--search-box--search-button">Search</a>
		</div>
	  </div>
    <div class="activeContainerBottom">
    </div>
</div>
