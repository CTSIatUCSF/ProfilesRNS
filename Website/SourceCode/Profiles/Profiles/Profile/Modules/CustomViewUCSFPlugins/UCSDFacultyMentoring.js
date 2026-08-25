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
            let labels = [];
            let assistantParts = [];
            for (const pref of data.contactPreferences) {
                if (pref === 'Assistant') {
                    labels.push('Via my assistant');
                    if (data.assistantName && data.assistantName.trim().length > 0) assistantParts.push(data.assistantName.trim());
                    if (data.assistantEmail && data.assistantEmail.trim().length > 0) assistantParts.push(data.assistantEmail.trim());
                    if (data.assistantPhone && data.assistantPhone.trim().length > 0) assistantParts.push(data.assistantPhone.trim());
                } else {
                    labels.push(pref);
                }
            }
            $('.researcherprofiles--ucsdfacultymentoring--contactformentoring').html(
                labels.map(function (l) {
                    return '<span class="researcherprofiles--ucsdfacultymentoring--contactformentoring--item">' + l + '</span>';
                }).join(' &middot; ')
            );
            if (assistantParts.length > 0) {
                $('.researcherprofiles--ucsdfacultymentoring--assistant-details')
                    .html('Assistant: ' + assistantParts.join(' · '))
                    .show();
            }
            $('.researcherprofiles--ucsdfacultymentoring--contact-section').show();
        }

        if (data.lastUpdated && data.lastUpdated.trim().length > 0) {
            $('.researcherprofiles--ucsdfacultymentoring--last-updated')
                .html('Last updated: ' + data.lastUpdated)
                .show();
        }

    });
};
