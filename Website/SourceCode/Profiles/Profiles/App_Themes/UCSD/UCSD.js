$(document).ready(function () {
	
    //Alumni badge 
    if ($('.education') && $('.education').length) {
        $('.education tr td:first-child').each(function () {
            var alma = $(this).text();
			var inst1 = alma.includes('University of California, San Diego');
			var inst2 = alma.includes('University of California San Diego');
			var inst3 = alma.includes('University of California at San Diego');
			var inst4 = alma.includes('University of California in San Diego');
			var inst5 = alma.includes('UC, San Diego');
			var inst6 = alma.includes('UC San Diego');
			var inst7 = alma.includes('UCSD');
            if (inst1 + inst2 + inst3 + inst4 + inst5 + inst6 + inst7 > 0) {
                $('.profilesContentMain').addClass('alumni');
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
