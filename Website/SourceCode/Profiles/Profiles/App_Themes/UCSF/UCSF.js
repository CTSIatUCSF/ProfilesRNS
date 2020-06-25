$(document).ready(function () {

    // alumni badge
    if ($('.education') && $('.education').length) {
        var ucsfSpellings = ["University of California, San Francisco",
            "University of California San Francisco'",
            "University of California at San Francisco",
            "University of California in San Francisco",
            "University of California, San Francisco, CA",
            "UC, San Francisco",
            "UC San Francisco",
            "UCSF"];
        var i;
        for (i = 0; i < ucsfSpellings.length; ++i) {
            var ndx = 0;
            while (ndx > -1) {
                ndx = $('.education').html().indexOf(ucsfSpellings[i], ndx);
                if (ndx > -1) {
                    // they have a UCSF listed entry, make sure it contains a degree
                    var degreeStartNdx = $('.education').html().indexOf('<td>', ndx + ucsfSpellings[i].length) + 4;
                    var degree = $('.education').html().substring(degreeStartNdx, $('.education').html().indexOf('</td>', degreeStartNdx));
                    if (degree.trim().length > 0) {
                        $('.profilesContentMain').prepend('<img style="float: right; valign: top;" src="/App_Themes/UCSF/Images/UCSF_alumni_badge_500x500.png" width="50"/>');
                        i = ucsfSpellings.length;
                        break;
                    }
                    ndx += ucsfSpellings[i].length;
                }
            }
        }
    }	

    // dei-champion badge
    if ($('.education') && $('.education').length) {
        $(".education:contains('Diversity, Equity, and Inclusion Champion Training')").addClass('dei-champ');
        $(".education:contains('Diversity, Equity & Inclusion Training')").addClass('dei-champ');
        $(".education:contains('Diversity, Equity and Inclusion Training')").addClass('dei-champ');
        $(".education:contains('Diversity, Equity, and Inclusion Training')").addClass('dei-champ');
        if ($('.dei-champ') && $('.dei-champ').length) $('.profilesContentMain').prepend('<a href="https://differencesmatter.ucsf.edu/diversity-equity-and-inclusion-champion-training" style="float: right; valign: top;" target="_blank"><img src="/App_Themes/UCSF/Images/dei-champ_large.png" width="50"/></a>');
    }	 

    /* Commented out by Eric on 6/23/2021 because this is now all in the c# code
    // altmetrics, don't attempt to load till after 7 seconds, which is 7000 milliseconds
	setTimeout(function ()
	{
		if ($('#publicationListAll') && $('#publicationListAll').length) {
			$("#publicationListAll li a:contains('PubMed'),a:contains('Publisher Site')").each(function () {
				var url = $(this).attr('href');
				var ID = null;
				var TYPE = null;
				var idarr = null;
				if (url.indexOf("dx.doi.org") > 0) {
					idarr = url.split("dx.doi.org\/");
					ID = idarr[1];
					TYPE = "doi";
				}
				if (url.indexOf("ncbi.nlm.nih.gov/pubmed") > 0) {
					idarr = url.split("ncbi.nlm.nih.gov\/pubmed\/");
					ID = idarr[1];
					TYPE = "pmid";
				}
                if (ID) {
                    // just dimensions now
					var span = "<span class='__dimensions_badge_embed__' data-hide-zero-citations='true' data-style='small_circle' data-" + TYPE + "=" + '"' +
						ID + '"' + "></span>";
				}
				$(this).parent().append(span);
			});
			$.getScript('https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js');
			$.getScript('https://badge.dimensions.ai/badge.js');
		}
	}, 7000);

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
			} 
			,$("#publicationListAll li a:contains('Publisher Site')").each(function () {
				var url = $(this).attr('href');
				var doi = null;
				if (url.indexOf("dx.doi.org")){
					var doiarr = url.split("dx.doi.org\/");
					doi = doiarr[1];
				}
				if (doi) {
					$(this).parent().append(
						" <span class='altmetric-embed' data-badge-popover='bottom' data-badge-type='4' data-hide-no-mentions='true' data-doi='" +
								doi + "'></span>" +  // also add dimensions
						"<span class='__dimensions_badge_embed__' data-hide-zero-citations='true' data-style='small_rectangle' data-doi='" +
								doi + "'></span>")
					}
			}));
            $.getScript('https://d1bxh8uas1mnw7.cloudfront.net/assets/embed.js');
            $.getScript('https://badge.dimensions.ai/badge.js');
        }
    }, 7000);
*/
  //Search Form: clone clinical trials checkbox for promotion; call buildGadgetAds 
    if ($('#selOtherOptions') && $('#selOtherOptions').length) {
		$("#divMaster_CTC1 label:contains('Clinical Trials')").parent().addClass('trials1');
		$('.trials2').click(function() { 
			if ($('.trials2').is(':checked')) {
				$('.trials1 input:checkbox').attr("checked", true)[0].onclick();
			} else {
				$('.trials1 input:checkbox').attr("checked", false)[0].onclick(); 
			}
		});
	}
	
  //Photo display - comment out 1st & 2nd OR 3rd through 5th lines within condition, to display regular or women in science photos
	if ($('.searchForm') && $('.searchForm').length) {
        var hero = 'hero-photos' + Math.floor((Math.random() * 21));
        $('#page-container').addClass(hero);
//        $('#page-container').addClass("hero-women");
//        var herolink = "<p style='position:absolute;top:170px;margin-left:24px;line-height:34px;background-color:#fafbfb;'><a href='../women-in-science/'><span style='font-size:32px'>Women in</span><br /><span style='font-size:38px'>Science</span><br /><span style='color:#F26D04;line-height:20px;' class='dblarrow'>Learn more</span></a></p>";
//        $('.hero-women .profiles').prepend(herolink);
	}
 
});
