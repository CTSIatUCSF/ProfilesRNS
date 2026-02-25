CollaborationInterests = {};

CollaborationInterests.init = function (data) {
    // replace \r\n or just \n with \\n
    CollaborationInterests.render(JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

// ========================================================================= //
CollaborationInterests.render = function (data) {
    $(document).ready(function () {
        if (data.collaborationInterests && data.collaborationInterests.length > 0) {
            $('.researcherprofiles--collaboration-interests--topics').show();            
            let htmlstr = '';
            for (const ci of data.collaborationInterests) {
                htmlstr += '<span class="researcherprofiles--collaboration-interests--topic">' + ci + '</span>';
            }
            $('.researcherprofiles--collaboration-interests--topics').html(htmlstr);
        }

        // Add narrative if it exists
        if (data.narrative && data.narrative.trim().length > 0) {
            $('.researcherprofiles--collaboration-interests--narrative').show();            
            $('.researcherprofiles--collaboration-interests--narrative').html(data.narrative);
        }

        // Add last updated if it exists
        if (data.lastUpdated && data.lastUpdated.trim().length > 0) {
            $('.researcherprofiles--collaboration-interests--last-updated').show()
            $('.researcherprofiles--collaboration-interests--last-updated').html('Last updated: ' + data.lastUpdated);
        }
    });
};
