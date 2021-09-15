GlobalHealthEquity = {};

GlobalHealthEquity.init = function (ghdata) {
    GlobalHealthEquity.render(JSON.parse(ghdata));
};


// ========================================================================= //
GlobalHealthEquity.render = function (data) {
    $(document).ready(function () {
        var htmlstr = "";
        if (data.interests) {
            htmlstr += "<dt>Interests</dt><dd>" + data.interests.join(", ") + "</dd>";
        }
        if (data.locations) {
            htmlstr += "<dt>Locations</dt><dd>" + data.locations.join(", ") + "</dd>";
        }
        $(".globalhealthequity").html("<dl>" + htmlstr + "</dl>");
    });
};
