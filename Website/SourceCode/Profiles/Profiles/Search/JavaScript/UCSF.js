$(document).ready(function(){
  // Focus on topics search
  $("#txtSearchFor").focus();

  //manage Researcher Type display
    $("#ddlChkList").removeAttr('onclick').removeAttr('onkeypress');  
	$('#ddlChkList').focus(function() {
	  if ($('#divChkList').is(":hidden")){
		$('#ddlChkList').click();
        $("#divChkList").css('display','block');
	  } else {
        $("#divChkList").css('display','none');		  
	  }
    });
    $(document).click(function(evt) {
        if ($("#divChkList").is(":visible")) {
            switch (evt.target.id) {
                case "ddlChkList":
                case "divChkList":
                    break;
                default:
                    var tmp = evt.target;
                    while (tmp.parentNode) {
                        tmp = tmp.parentNode;
                        if (tmp.id == "divChkList") { return true; }
                    }
                    $("#divChkList").hide();
            }
        }
    });
    
  // open Other Options checkbox list (including Safari); hide Researcher Type for IE11 glitch
  $('#selOtherOptions').focus(function() {
      $('#divOtherOptions').show();
	  $("#divChkList").hide();
      $('#ctcFirst_rMaster_ctl00_divDetail').show();
	  $('#ctcFirst_rMaster_ctl00_rDetail_ctl00_checkDetailText').focus();
  });	
  if ($('#divOtherOptions') && $('#divOtherOptions').length) {
    if (navigator.userAgent.indexOf('Safari') != -1 && navigator.userAgent.indexOf('Chrome') == -1)   
	  $('#divOtherOptions').css("padding-top","20px");
  }
  
  //search results adjustments
  if ($('#tblSearchResults') && $('#tblSearchResults').length) {
    $('#tblSearchResults tr').find('td:eq(0)').addClass('linky');
    $('#ctl00_ContentMain_rptMain_ctl00_ctl00_gvIndirectConnectionDetails td:last-child').addClass('linky');
    $('#ctl00_ContentMain_rptMain_ctl00_ctl00_gvConnectionDetails td:last-child').addClass('linky');
  }
  
});
