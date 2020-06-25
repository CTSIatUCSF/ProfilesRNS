$(document).ready(function () {

    //alumni badge 
    if ($('.education') && $('.education').length) {
        $(".education:contains('University of California, San Diego')").addClass('alum');
        $(".education:contains('University of California San Diego')").addClass('alum');
        $(".education:contains('University of California at San Diego')").addClass('alum');
        $(".education:contains('University of California in San Diego')").addClass('alum');
        $(".education:contains('UC, San Diego')").addClass('alum');
        $(".education:contains('UC San Diego')").addClass('alum');
        $(".education:contains('UCSD')").addClass('alum');
        if ($('.alum') && $('.alum').length) $('.profilesContentMain').prepend('<img style="float: right; valign: top;" src="/App_Themes/UCSD/Images/college-alumni.png" />');
    }

});
