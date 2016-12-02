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
	
});