UCSDFacultyMentoring = {};

UCSDFacultyMentoring.init = function (data) {
    // replace \r\n or just \n with \\n
    UCSDFacultyMentoring.render(JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

// ========================================================================= //
UCSDFacultyMentoring.render = function (data) {
    $(document).ready(function () {
        // Add last updated if it exists
        if (data.lastUpdated && data.lastUpdated.trim().length > 0) {
            $('.researcherprofiles--ucsdfacultymentoring--last-updated').show()
            $('.researcherprofiles--ucsdfacultymentoring--last-updated').html('Last updated: ' + data.lastUpdated);
        }

        if (data.availableToMentor && data.availableToMentor.length > 0) {
            $('.researcherprofiles--ucsdfacultymentoring--availabletomentor').show();            
            let htmlstr = '';
            for (const ci of data.availableToMentor) {
                htmlstr += '<span class="researcherprofiles--ucsdfacultymentoring--availabletomentor">' + ci + '</span>';
            }
            $('.researcherprofiles--ucsdfacultymentoring--availabletomentor').html(htmlstr);
        }

        if (data.contactPreferences && data.contactPreferences.length > 0) {
            $('.researcherprofiles--ucsdfacultymentoring--contactformentoring').show();
            let htmlstr = '';
            for (const ci of data.contactPreferences) {
                if ("Assistant" === ci) {
                    htmlstr += '<span class="researcherprofiles--ucsdfacultymentoring--contactformentoring">' + ci + '</span>';
                    if (data.assistantName && data.assistantName.trim().length > 0) {
                        htmlstr += '&nbsp;Name: ' + data.assistantName;
                    }
                    if (data.assistantEmail && data.assistantEmail.trim().length > 0) {
                        htmlstr += '&nbsp;Email: ' + data.assistantEmail;
                    }
                    if (data.assistantPhone && data.assistantPhone.trim().length > 0) {
                        htmlstr += '&nbsp;Phone: ' + data.assistantPhone;
                    }
                }
                else {
                    htmlstr += '<span class="researcherprofiles--ucsdfacultymentoring--contactformentoring">' + ci + ' (see above)</span>';
                }
            }
            $('.researcherprofiles--ucsdfacultymentoring--contactformentoring').html(htmlstr);
        }

        // Add narrative if it exists
        if (data.narrative && data.narrative.trim().length > 0) {
            $('.researcherprofiles--collaboration-interests--narrative').show();            
            $('.researcherprofiles--collaboration-interests--narrative').html(data.narrative);
        }

    });
};
