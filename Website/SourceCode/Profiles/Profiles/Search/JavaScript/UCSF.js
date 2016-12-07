$(document).ready(function(){
  // Focus on topics search
  $("#txtSearchFor").focus();

  // hide researcher type list when user clicks outside of it
  $("body").click(function() {
      $("#divChkList").hide();
  });
  $("#ddlChkList").click(function(e) {
      e.stopPropagation();
  });
  $("#divChkList").click(function(e) {
      e.stopPropagation();
  });
  
  // open Other Options checkbox list
	$('#selOtherOptions').click(function() {
		$('#ctcFirst_rMaster_ctl00_divDetail').show();
	});		
  
  //search results adjustments
  if ($('#tblSearchResults') && $('#tblSearchResults').length) {
    $('#tblSearchResults tr').find('td:eq(0)').addClass('linky');
    $('#ctl00_ContentMain_rptMain_ctl00_ctl00_gvIndirectConnectionDetails td:last-child').addClass('linky');
    $('#ctl00_ContentMain_rptMain_ctl00_ctl00_gvConnectionDetails td:last-child').addClass('linky');
    $("th:contains('Why')").css("text-align","center");
    $("#tblSearchResults th:contains('Type')").css("text-align","center");
    $("#tblSearchResults th:contains('Researcher Type')").css("text-align","left");
  }
  
});
