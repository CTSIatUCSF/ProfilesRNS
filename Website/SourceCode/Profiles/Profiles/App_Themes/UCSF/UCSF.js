$(document).ready(function () {
	
    //Education badge (adjust alma var & alumnibadge img filename for inst)
    if ($('.education') && $('.education').length) {
        $('.education tr td:first-child').each(function () {
            var alma = $(this).text();
            if (alma == 'University of California, San Francisco' ||
		    alma == 'University of California San Francisco' ||
		    alma == 'University of California at San Francisco' ||
		    alma == 'University of California in San Francisco' ||
		    alma == 'UC, San Francisco' ||
		    alma == 'UC San Francisco' ||
		    alma == 'UCSF') {
                $('.profilesContentMain').addClass('alumni');
				var alumnibadge = "url(" + _rootDomain + "/App_Themes/UCSF/Images/ucsf_alumni_blue.jpg)";
				$('.alumni').css('background-image',alumnibadge);
			}
        });
    }
	
    // altmetrics, don't attempt to load till after 7 seconds, which is 7000 milliseconds
    setTimeout(function () {
      if ($('#publicationListAll') && $('#publicationListAll').length) {
        $("#publicationListAll li a:contains('PubMed')").each(function () {
            var pmid = $(this).attr('href').match(/(\d+)$/);
            if (pmid && pmid[0]) {
                $(this).parent().append(
                " <span class='altmetric-embed' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-pmid='" +
                pmid[0] + "'></span>")
            }
        });
        $.getScript('http://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js');
      }
    }, 7000);

  //Search Form: clone clinical trials checkbox for promotion; call buildGadgetAds
    if ($('#trOtherOptions') && $('#trOtherOptions').length) {
		$("#divOtherOptions label[for='ctcFirst_rMaster_ctl00_rDetail_ctl09_checkDetailText']").parent().addClass('trials1');
		$('.trials2').click(function() { 
			if ($('.trials2').is(':checked')) {
				$('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", true)[0].onclick();
			} else {
				$('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", false)[0].onclick(); 
			}
		});
		buildGadgetAds();
	}
 
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