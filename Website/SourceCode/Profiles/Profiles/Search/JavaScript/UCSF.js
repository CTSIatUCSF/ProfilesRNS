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

function buildGadgetAds() {
    //Gadget ads buildGadgetAds(linksCount) 
    var ads = [];
    var adndx;
    var videointro = "<li><a href='https://www.youtube.com/watch?v=YCOA2GWyplY' target='_blank'>"
			+ "<div class='badge'><p style='padding-left:3px'>"
			+ "<img src='" + _rootDomain + "/framework/images/video-ad.png' /></p>"
			+ "<p><strong>Watch UCSF Profiles video introduction!</strong></p></div></a></li>";
    ads.push(videointro);

    var mentor = "<li><div class='badge'>"
		+ "<h2 style='margin-bottom:5px'>Passionate about Mentoring?</h2>"
		+ "<p><a href='" + _rootDomain + "/login/default.aspx?method=login&amp;edit=true'>Let others know. Add to your UCSF Profile.</a></p>";
    var mentorpage = _rootDomain + "/mitchell.feldman";
    var mentorphoto = _rootDomain + "/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID=367209";
    var mentorimage = "";

    $.ajax({
        type: 'HEAD',
        url: mentorphoto,
        success: function () {
            mentorPhoto();
        },
        error: function () {
            // oh well, show what we can
            renderAds();
        }
    });

    function mentorPhoto() {
        mentorimage = "<img src='" + mentorphoto
			+ "' alt='Mitch Feldman' width='62' style='float:left;padding-right:5px;' />";
        // ok, we now have the image. Now we need to see if the page is valid
        $.ajax({
            type: 'HEAD',
            url: mentorpage,
            success: function () {
                mentorPerson();
            },
            error: function () {
                // oh well, show what we can
                renderAds();
            }
        });
    }

    function mentorPerson() {
        mentor = mentor + "<p style='height:62px;overflow-y:hidden;'>" + mentorimage
			+ "<strong><a href='" + mentorpage
			+ "'>Mitch Feldman</a></strong><br /> is a Faculty Mentor!</p></div></li>";
        ads.push(mentor);
        // now render the ads
        renderAds();
    }

    function renderAds() {
        // rotate through the ads at some frequency
        setInterval(nexttip, 30000);

        // for search form pages
        if ($('.nonavbar').length && !$('#FSSiteDescription').length && $('.mainmenu li').last().text() != 'Sign out') {
            var badge = "<ul id='badge'>" + ads.join('') + "</ul>";
            $(badge).insertAfter('.profilesContentPassive');
            $("#badge li").hide();
            randomtip();
        }
    }

    function randomtip() {
        var length = $("#badge li").length;
        adndx = Math.floor(Math.random() * length) + 1;
        $("#badge li:nth-child(" + adndx + ")").show();
    }

    function nexttip() {
        $("#badge li:nth-child(" + adndx + ")").fadeOut("slow", function () {
            adndx = adndx >= $("#badge li").length ? 1 : adndx + 1;
            $("#badge li:nth-child(" + adndx + ")").fadeIn("slow");
        });
    }

}