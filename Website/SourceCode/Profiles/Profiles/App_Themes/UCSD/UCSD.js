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
        if ($('.alum') && $('.alum').length) $('.profilesContentMain').prepend('<div class="researcherprofiles--researcher-badge"><img src="/App_Themes/UCSD/Images/college-alumni.png" height="50" width="50" alt="UCSD Alumni"></div>');
    }

});
