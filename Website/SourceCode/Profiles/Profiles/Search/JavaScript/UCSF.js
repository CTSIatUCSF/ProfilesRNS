$(document).ready(function(){
// HP placeholder text (not used)
  function initiateSearchText(){
    $(".keywordsName").css('color','#999');
    $(".keywordsName").attr('value','e.g. latina HIV or John Smith');
  }
//  initiateSearchText();

    var default_value = $(".keywordsName").value;
    $(".keywordsName").focus(function() {
        if($(".keywordsName").value == default_value) {
            this.value = '';
            $(this).css('color','#000');
        }
    });
    $(".keywordsName").blur(function() {
        if($(".keywordsName").value == '') {
            $(".keywordsName").css('color','#999');
            $(".keywordsName").value = default_value;
        }
  });

  // Skip placeholder & just focus
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

  // open Other Options list 
  $('#ctcFirst_rMaster_ctl00_imgExpand').click();
  
  //search results adjustments
  $('#tblSearchResults tr').find('td:eq(0)').addClass('linky');
  $('#ctl00_ContentMain_rptMain_ctl00_ctl00_gvIndirectConnectionDetails td:last-child').addClass('linky');
  $('#ctl00_ContentMain_rptMain_ctl00_ctl00_gvConnectionDetails td:last-child').addClass('linky');
  $("th:contains('Why')").css("text-align","center");
  $("#tblSearchResults th:contains('Type')").css("text-align","center");
  $("#tblSearchResults th:contains('Researcher Type')").css("text-align","left");
  
  //clone clinical trials checkbox for promotion
  $("#divOtherOptions label[for='ctcFirst_rMaster_ctl00_rDetail_ctl09_checkDetailText']").parent().addClass('trials1');
  $('.trials2').click(function() { 
     if ($('.trials2').is(':checked')) {
        $('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", true)[0].onclick();
     } else {
        $('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", false)[0].onclick(); 
     }
  });
  
  });

  
function UrlExists(url)
{
    var http = new XMLHttpRequest();
    http.open('HEAD', url, false);
    http.send();
    return http.status!=404;
}

function buildGadgetAds() {
    //Gadget ads buildGadgetAds(linksCount) 
	var mentor = "<li><div class='badge'>"
		+ "<h2 style='margin-bottom:5px'>Passionate about Mentoring?</h2>"
		+ "<p><a href='" + _rootDomain + "/login/default.aspx?method=login&amp;edit=true'>Let others know. Add to your UCSF Profile.</a></p>";
	var mentorpage = _rootDomain + "/mitchell.feldman";
	var mentorphoto = _rootDomain + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=367209";
	var mentorimage = "";
	if (UrlExists(mentorphoto)) {
		mentorimage =  "<img src='" + mentorphoto 
			+ "' alt='Mitch Feldman' width='62' style='float:left;padding-right:5px;' />";
	}
	if (UrlExists(mentorpage)) {
		mentor = mentor + "<p style='height:62px;overflow-y:hidden;'>" + mentorimage
			+ "<strong><a href='" + mentorpage 
			+ "'>Mitch Feldman</a></strong><br /> is a Faculty Mentor!</p></div></li>";
	} else {
		mentor = mentor + "</div></li>";
	}
    var videointro = "<li><a href='https://www.youtube.com/watch?v=YCOA2GWyplY' target='_blank'>"
            + "<div class='badge'><p style='padding-left:3px'>"
            + "<img src='" + _rootDomain + "/framework/images/video-ad.png' /></p>"
            + "<p><strong>Watch UCSF Profiles video introduction!</strong></p></div></a></li>";
    // for search form pages
    if ($('.nonavbar').length && !$('#FSSiteDescription').length) {
        var badge = "<ul id='badge'>" + mentor + videointro + "</ul>";
        $(badge).insertAfter('.profilesContentPassive');
        var login = $('#signinlink').attr('href');
        $("#badge li").hide();
        randomtip();
    }
    if ($('.mainmenu li').last().text() == 'Sign out') {
        $("#badge").hide();
    }

}

        this.randomtip = function () {
            var length = $("#badge li").length;
            var ran = Math.floor(Math.random() * length) + 1;
            $("#badge li:nth-child(" + ran + ")").show();
        };
