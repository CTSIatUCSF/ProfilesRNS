USCMentoring = {};

USCMentoring.init = function (data) {
    // replace \r\n or just \n with \\n
    USCMentoring.render(JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

// ========================================================================= //
USCMentoring.render = function (data) {
    $(document).ready(function () {
        if (data.availableFor && data.availableFor.length > 0) {
            $('.researcherprofiles--usc-mentoring--available-for').show();            
            let htmlstr = '<span class="detailtitle">Available to Mentor as: </span> ';
            for (const ci of data.availableFor) {
                htmlstr += '<span class="researcherprofiles--usc-mentoring--available-as">' + ci + '</span>';
            }
            $('.researcherprofiles--usc-mentoring--available-for').html(htmlstr);
        }

        if (data.contactPreferences && data.contactPreferences.length > 0) {
            $('.researcherprofiles--usc-mentoring--contact-preferences').show();
            let htmlstr = '<span class="detailtitle">Contact for Mentoring:</span>';
            for (const ci of data.contactPreferences) {
                htmlstr += '<span class="researcherprofiles--usc-mentoring--contact-preference">' + ci + '</span>';
            }
            $('.researcherprofiles--usc-mentoring--contact-preferences').html(htmlstr);
        }

        // Add last updated if it exists
        if (data.lastUpdated && data.lastUpdated.trim().length > 0) {
            $('.researcherprofiles--usc-mentoring--last-updated').show()
            $('.researcherprofiles--usc-mentoring--last-updated').html('Last updated: ' + data.lastUpdated);
        }
    });
};
