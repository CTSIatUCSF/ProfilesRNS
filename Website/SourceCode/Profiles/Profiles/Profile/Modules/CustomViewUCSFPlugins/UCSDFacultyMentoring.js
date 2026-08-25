UCSDFacultyMentoring = {};

UCSDFacultyMentoring.init = function (data) {
    UCSDFacultyMentoring.render(JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

UCSDFacultyMentoring.render = function (data) {
    $(document).ready(function () {

        if (data.narrative && data.narrative.trim().length > 0) {
            $('.researcherprofiles--ucsdfacultymentoring--narrative')
                .html(data.narrative)
                .show();
        }

        if (data.availableToMentor && data.availableToMentor.length > 0) {
            let html = '';
            for (const item of data.availableToMentor) {
                html += '<li class="researcherprofiles--ucsdfacultymentoring--availabletomentor--item">' + item.trim() + '</li>';
            }
            $('.researcherprofiles--ucsdfacultymentoring--availabletomentor').html(html);
            $('.researcherprofiles--ucsdfacultymentoring--available-section').show();
        }

        if (data.contactPreferences && data.contactPreferences.length > 0) {
            let html = '';
            for (const pref of data.contactPreferences) {
                if (pref === 'Assistant') {
                    let parts = [];
                    if (data.assistantName && data.assistantName.trim().length > 0) parts.push(data.assistantName.trim());
                    if (data.assistantEmail && data.assistantEmail.trim().length > 0) parts.push(data.assistantEmail.trim());
                    if (data.assistantPhone && data.assistantPhone.trim().length > 0) parts.push(data.assistantPhone.trim());
                    html += '<li class="researcherprofiles--ucsdfacultymentoring--contactformentoring--item">Via my assistant';
                    if (parts.length > 0) {
                        html += '<span class="researcherprofiles--ucsdfacultymentoring--assistant-details"><span class="sr-only">Assistant: </span>' + parts.join(' · ') + '</span>';
                    }
                    html += '</li>';
                } else {
                    html += '<li class="researcherprofiles--ucsdfacultymentoring--contactformentoring--item">' + pref + '</li>';
                }
            }
            $('.researcherprofiles--ucsdfacultymentoring--contactformentoring').html(html);
            $('.researcherprofiles--ucsdfacultymentoring--contact-section').show();
        }

        if (data.lastUpdated && data.lastUpdated.trim().length > 0) {
            $('.researcherprofiles--ucsdfacultymentoring--last-updated')
                .html('Last updated: ' + data.lastUpdated)
                .show();
        }

    });
};
