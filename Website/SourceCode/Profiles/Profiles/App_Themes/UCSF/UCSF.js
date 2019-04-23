$(document).ready(function () {
	
     // alumni badge
	 if ($('.education') && $('.education').length) {
		$(".education:contains('University of California, San Francisco')").addClass('alum');
		$(".education:contains('University of California San Francisco')").addClass('alum');
		$(".education:contains('University of California at San Francisco')").addClass('alum');
		$(".education:contains('University of California in San Francisco')").addClass('alum');
		$(".education:contains('UC, San Francisco')").addClass('alum');
		$(".education:contains('UC San Francisco')").addClass('alum');
		$(".education:contains('UCSF')").addClass('alum');
		if ($('.alum') && $('.alum').length) $('.profilesContentMain').addClass('alumni');
	 }
	
    // altmetrics, don't attempt to load till after 7 seconds, which is 7000 milliseconds
    setTimeout(function () {
        if ($('#publicationListAll') && $('#publicationListAll').length) {
            $("#publicationListAll li a:contains('PubMed')").each(function () {
                var pmid = $(this).attr('href').match(/pubmed\/(\d+)$/);
                if (pmid && pmid[1]) {
                    $(this).parent().append(
                        " <span class='altmetric-embed' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-pmid='" +
                        pmid[1] + "'></span>" +  // also add dimensions
                        "<span class='__dimensions_badge_embed__' data-hide-zero-citations='true' data-style='small_rectangle' data-pmid='" +
                        pmid[1] + "'></span>")
                }
            });
            $.getScript('https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js');
            $.getScript('https://badge.dimensions.ai/badge.js');
        }
    }, 7000);

  //Search Form: clone clinical trials checkbox for promotion; call buildGadgetAds
    if ($('#trOtherOptions') && $('#trOtherOptions').length) {
		$("#divOtherOptions label[for='ctcFirst_rMaster_ctl00_rDetail_ctl00_checkDetailText']").parent().addClass('trials1');
		$('.trials2').click(function() { 
			if ($('.trials2').is(':checked')) {
				$('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", true)[0].onclick();
			} else {
				$('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", false)[0].onclick(); 
			}
		});
		buildGadgetAds();
	}
	
	if ($('.searchForm') && $('.searchForm').length) {
//        var hero = 'hero-photos' + Math.floor((Math.random() * 21));
//        $('#page-container').addClass(hero);
        $('#page-container').addClass("hero-women");
        var herolink = "<p style='position:absolute;top:170px;margin-left:24px;line-height:34px;background-color:#fafbfb;'><a href='../women-in-science/'><span style='font-size:32px'>Women in</span><br /><span style='font-size:38px'>Science</span><br /><span style='color:#F26D04;line-height:20px;' class='dblarrow'>Learn more</span></a></p>";
        $('.hero-women .profiles').prepend(herolink);
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