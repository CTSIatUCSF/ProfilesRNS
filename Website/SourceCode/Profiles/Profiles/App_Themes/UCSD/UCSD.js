﻿$(document).ready(function () {
	
    //alumni badge 
	 if ($('.education') && $('.education').length) {
		$(".education:contains('University of California, San Diego')").addClass('alum');
		$(".education:contains('University of California San Diego')").addClass('alum');
		$(".education:contains('University of California at San Diego')").addClass('alum');
		$(".education:contains('University of California in San Diego')").addClass('alum');
		$(".education:contains('UC, San Diego')").addClass('alum');
		$(".education:contains('UC San Diego')").addClass('alum');
		$(".education:contains('UCSD')").addClass('alum');
		if ($('.alum') && $('.alum').length) $('.profilesContentMain').addClass('alumni');
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
 
});