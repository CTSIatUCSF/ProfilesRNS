Identity = {};

Identity.init = function (data) {
    // replace \r\n or just \n with \\n
    Identity.render(JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

// ========================================================================= //
Identity.render = function (data) {
    $(document).ready(function () {
        let htmlstr = "";

        // Helper function to format a list with "and"
        const formatListWithAnd = (list) => {
            if (list.length === 0) return "";
            if (list.length === 1) return list[0];
            return list.slice(0, -1).join(", ") + ", and " + list[list.length - 1];
        };

        // Collect sub-type data
        const attributes = [];
        if (data.race && data.race.length > 0) {
            attributes.push(...data.race);
        }
        if (data.sexualOrientation && data.sexualOrientation.length > 0) {
            attributes.push(...data.sexualOrientation);
        }
        if (data.genderIdentity && data.genderIdentity.length > 0) {
            attributes.push(...data.genderIdentity);
        }
        if (data.other && data.other.length > 0) {
            attributes.push(...data.other);
        }

        // Generate the "I identify as" paragraph if there are attributes
        if (attributes.length > 0) {
            htmlstr += `<p>I identify as ${formatListWithAnd(attributes)}.</p>`;
        }

        // Add narrative if it exists
        if (data.narrative && data.narrative.trim().length > 0) {
            const tempTag = document.createElement("p");
            tempTag.textContent = data.narrative;
            htmlstr += `<p>${tempTag.innerHTML}</p>`;
        }

        // If there's no sub-type or narrative, leave the output empty
        $(".identity").html(htmlstr);
    });
};
