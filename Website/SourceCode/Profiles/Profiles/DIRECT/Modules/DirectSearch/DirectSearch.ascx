﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DirectSearch.ascx.cs" Inherits="Profiles.DIRECT.Modules.DirectSearch.DirectSearch" %>
 
    <script language="javascript" type="text/javascript">

function NoEnter(){
    if (window.event && window.event.keyCode == 13)
      document.getElementById('btnsearch').click();
    return true;
 }
    
//****** List Table JavaScript

	var hasClickedListTable = false;
	function doListTableRowOver(x) {
	
		x.className = 'overRow';
		// x.style.backgroundColor = '#5A719C';
		x.style.color = '#000';
		for (var i=0; i<x.childNodes.length; i++) {
			if (x.childNodes[i].childNodes.length > 0) {
				if (x.childNodes[i].childNodes[0].className == 'listTableLink') {
					x.childNodes[i].childNodes[0].style.color = '#178CCB';
				}
			}
		}
	}
	function doListTableRowOut(x,eo) {
		if (eo==1) {
			x.className = 'oddRow';
			x.style.backgroundColor = '#FFFFFF';
		} else {
			x.className = 'evenRow';
			x.style.backgroundColor = '#F7F7F8';
		}
		x.style.color = '';
		for (var i=0; i<x.childNodes.length; i++) {
			if (x.childNodes[i].childNodes.length > 0) {
				if (x.childNodes[i].childNodes[0].className == 'listTableLink') {
					x.childNodes[i].childNodes[0].style.color = '#178CCB';
				}
			}
		}
	}
	function doListTableCellOver(x) {
		x.className = 'listTableLinkOver';
	}
	function doListTableCellOut(x) {
		x.className = 'listTableLink';
		x.style.backgroundColor = '';
	}
	function doListTableCellClick(x) {
		hasClickedListTable = true;
	}

	//****** Federated Search (DIRECT) JavaScript

	var fsObject = [];
	var dsLoading = 0;

	function siteResult(SiteID,ResultError,ResultCount,ResultDetailsURL,ResultPopType,ResultPrevURL,FSID) {
	    
		var el1 = document.getElementById('SITE_STATUS_'+SiteID);
		
		var el2 = el1.childNodes[0];
		if ((ResultError == 0)&&(ResultCount!='')) {
			el2.innerHTML = ResultCount;
			var el3 = document.createElement("div");			
			
		} else {
			ResultPopType = 'No results were returned by this institution.';
			el2.innerHTML = '0';
		}

		for (var i=0; i<fsObject.length; i++) {
			if (fsObject[i].SiteID == SiteID) {
				fsObject[i].ResultPopType = ResultPopType;
				fsObject[i].ResultDetailsURL = ResultDetailsURL;
				fsObject[i].FSID = FSID;
			}
		}
	}
	function doLocalPersonSearch(directserviceURL, SiteID) {
		for (var i=0; i<fsObject.length; i++) {
			if (fsObject[i].SiteID == SiteID) {
				if ((fsObject[i].ResultCount != '')&&(fsObject[i].ResultDetailsURL != '')&&(fsObject[i].FSID != '')) {
					window.open(directserviceURL + '?request=outgoingdetails&fsid=' + fsObject[i].FSID);
				}
			}
		}
	}
	function doSiteHoverOver(SiteID) {
	
		document.getElementById('FSSiteDescription').innerHTML = '';
		
		for (var i=0; i<fsObject.length; i++) {
			if (fsObject[i].SiteID == SiteID) {
				document.getElementById('FSSiteDescription').innerHTML = fsObject[i].ResultPopType;
				document.getElementById('FSSiteDescription').style.display = "";
				
			}
		}
		for (var i=0; i<fsObject.length; i++) {
			var el = document.getElementById('SITE_PREVIEW_'+fsObject[i].SiteID);
			if (el) {el.style.display = 'none';}
		}
		
		var el = document.getElementById('SITE_PREVIEW_'+SiteID);
		if (el) {el.style.display = '';}
	}
	function doSiteHoverOut(SiteID) {
		document.getElementById('FSSiteDescription').innerHTML = 'Important information about an institution\'s data will appear here when you place your mouse over the institution\'s name.';
	}
	
	function doDirectSearch() {		 
		
		for (var i=0; i<fsObject.length; i++) {
			fsObject[i].ResultPopType = 'Please wait while this institution processes the request.';
			fsObject[i].ResultDetailsURL = '';
			document.getElementById('SITE_STATUS_'+fsObject[i].SiteID).childNodes[0].innerHTML = '<img src="<%Response.Write(DirectWaitingImageURL());%>" alt="Loading" border="0" style="position:relative;top:-2px;" />';
		}	
	
	    try{
		document.getElementById('FSResultsBox').style.display='block';
		}catch(err){}
		try{
		document.getElementById('FSPassiveResultsBox').style.display='block';
		}catch(err){}
		try{
		//document.getElementById('sitePreview').innerHTML = '';
		}catch(err){}
		
		var f = document.getElementById("FSSearchPhrase");
		
		var s = f.value;
		
		var m = Math.random();
		
		
		var u = '<%Response.Write(DirectServiceURL());%>?blank=N&request=outgoingcount&SearchPhrase='+s+'&r='+m;
		
		document.getElementById('FSAJAXFrame').src = u;
	
	}
	function doAuto() {	
		<%
			if( GetKeywordString() != ""){
				Response.Write("var f = document.getElementById('FSSearchPhrase');");				
				Response.Write("f.value = " + cs(GetKeywordString()) + ";");
				Response.Write("doDirectSearch();");
			}
		%>
	}

    </script>
 <div class="searchForm">      
        <div class="pageSubTitleCaption">This tool, called
            <a href="http://direct2experts.org/" title="Distributed Interoperable Research Experts Collaboration Tool"  target="_blank">DIRECT</a>, 
             finds experts at multiple institutions. <a href="../">Return to regular Profiles search</a><br /><br />
        </div>
        <div class="searchForm nonavbar">

            <input type="hidden" name="request" value="outgoingcount" />
            <%
                Int64 rnd = 0;
                Random r = new Random();
                rnd = r.Next();      
            %>
            <input type="hidden" name="r" value="<%=rnd%>" />
            <div class="searchSection" style="width: 600px;">
                <table>
                    <tr>
                        <th>
                            Keywords
                        </th>
                        <td  class="fieldMain">
                            <input type='text' name="SearchPhrase" id="FSSearchPhrase" value="<%Response.Write(GetSearchPhrase()); %>"
                                class="inputText" title="Search Phrase" />
                        </td>
                        <td class="fieldOptions">
                            <a class="search-button"
                                onclick="JavaScript:doDirectSearch();" />Search</a>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div id="siteDesc" style="display: none">
            <div style="padding: 0px 2px">
                Details</div>
            <div id="siteDescText">
                testing</div>
        </div>
        <div id="FSResultsBox" style="margin-top: 20px; display: none;">
            <div style="margin-bottom: 15px;">
                Below are the number of matching people at participating institutions. Click an
                institution name to view the list of people. As you move your mouse over the different
                institution names, you will see important notes about that institution's data on
                the right.
<!-- and a preview/summary of the matching people at the bottom of this page. -->
            </div>
            <%Response.Write(DrawMyTable()); %>
           <asp:HtmlIframe> <iframe name="FSAJAXFrame" id="FSAJAXFrame" src="<%Response.Write(DirectServiceURL());%>?request=outgoingcount&blank=y&r=rnd"
                frameborder="0" scrolling="no" style="width: 0px; height: 0px;" title="Preview"/>
            </iframe> </asp:HtmlIframe>
        </div>
    </div>

    <script type="text/javascript">        doAuto();</script>