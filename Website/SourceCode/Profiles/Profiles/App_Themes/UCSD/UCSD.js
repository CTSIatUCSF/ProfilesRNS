$(document).ready(function () {
	
    //Alumni badge 
    if ($('.education') && $('.education').length) {
        var inst = [ 'University of California, San Diego', 'University of California San Diego', 'University of California at San Diego', 'University of California in San Diego', 'UC, San Diego', 'UC San Diego', 'UCSD' ];
        $('.education table tr td:first-child').each(function () {
            if ($.inArray($(this).text(), inst) >= 0) {
                $('.profilesContentMain').addClass('alumni');
                return false;
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
