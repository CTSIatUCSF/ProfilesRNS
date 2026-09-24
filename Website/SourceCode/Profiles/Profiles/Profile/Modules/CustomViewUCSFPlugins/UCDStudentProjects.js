UCDStudentProjects = {};

UCDStudentProjects.init = function (data) {
    UCDStudentProjects.render(JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

UCDStudentProjects.render = function (data) {
    $(document).ready(function () {

        if (data.typeOfResearch && data.typeOfResearchOther.trim()) {
            data.typeOfResearch.push(data.typeOfResearchOther)
        }

        if (data.typeOfResearch && data.typeOfResearch.length > 0) {
            let html = '';
            for (const item of data.typeOfResearch) {
                html += '<li class="researcherprofiles--ucdstudentprojects--typesofresearch--item">' + item.trim() + '</li>';
            }
            $('.researcherprofiles--ucdstudentprojects--typesofresearch').html(html);
            $('.researcherprofiles--ucdstudentprojects--types-section').show();
        }

        if (data.currentProjects && data.currentProjects.length > 0) {
            let html = '';
            for (const proj of data.currentProjects) {
                let parts = [];
                if (proj.name && proj.name.trim().length > 0) parts.push('Name: ' + proj.name.trim());
                if (proj.location && proj.location.trim().length > 0) parts.push('Location: ' + proj.location.trim());
                if (proj.objectives && proj.objectives.trim().length > 0) parts.push('Objectives: ' + proj.objectives.trim());
                if (proj.responsibilities && proj.responsibilities.trim().length > 0) parts.push('Student Responsibilities: ' + proj.responsibilities.trim());
                if (proj.url && proj.url.trim().length > 0) parts.push('Link: <a href="' + proj.url.trim() + '" target="_blank">' + proj.url.trim() + '</a>');
                if (proj.startDate && proj.startDate.trim().length > 0) parts.push('Estimated Start Date: ' + proj.startDate.trim());
                if (proj.endDate && proj.endDate.trim().length > 0) parts.push('Estimated End Date: ' + proj.endDate.trim());
                if (proj.contactinfo && proj.contactinfo.trim().length > 0) parts.push('Contact Info: ' + proj.contactinfo.trim());
                html += '<li class="researcherprofiles--ucdstudentprojects--studentprojects--item">';
                if (parts.length > 0) {
                    html += '<span class="researcherprofiles--ucdstudentprojects--studentprojects-details"><span class="sr-only"></span>' + parts.join(', ') + '</span>';
                }
                html += '</li>';
            }
            $('.researcherprofiles--ucdstudentprojects--studentprojects').html(html);
            $('.researcherprofiles--ucdstudentprojects--projects-section').show();
        }

        if (data.lastUpdated && data.lastUpdated.trim().length > 0) {
            $('.researcherprofiles--ucdstudentprojects--last-updated')
                .html('Last updated: ' + data.lastUpdated)
                .show();
        }

    });
};
