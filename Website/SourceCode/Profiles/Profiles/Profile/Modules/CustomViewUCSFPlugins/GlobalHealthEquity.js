GlobalHealthEquity = {};

GlobalHealthEquity.init = function (ghdata) {
    GlobalHealthEquity.render(JSON.parse(ghdata));
};


// ========================================================================= //
GlobalHealthEquity.render = function (data) {
    $(document).ready(function () {
        var htmlstr = "";
        if (data.interests && data.interests.length > 0) {
            htmlstr += "<dt>Interests</dt><dd><p>" + data.interests.join(", ") + "</p></dd>";
        }
        if (data.locations && data.locations.length > 0) {
            htmlstr += "<dt>Locations</dt><dd><p>" + data.locations.join(", ") + "</p></dd>";
        }
        if (data.centers && data.centers.length > 0) {
            htmlstr += "<dt>UCSF Centers & Programs</dt><dd><p>" + data.centers.join(", ") + "</p></dd>";
        }
        $(".globalhealthequity").html("<dl>" + htmlstr + "</dl>");
    });
};
