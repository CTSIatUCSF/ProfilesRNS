CommunityAndPublicService = {};

CommunityAndPublicService.init = function (plugindata) {
    CommunityAndPublicService.render(JSON.parse(plugindata));
};


// ========================================================================= //
CommunityAndPublicService.render = function (data) {
    $(document).ready(function () {
        var htmlstr = "<div style=\"margin-top: 6px\"><table style = \"width:592px\"  class=\"collapsible communityandpublicservice\" ><tbody>";
        for (let i = 0; i < data.length; i++) {
            let obj = data[i];
            htmlstr += "<tr><td>" + obj.institution + "</td><td>" + obj.startDate + "</td><td>" + obj.endDate + "</td><td>" + obj.role + "</td></trtd>";
        }
        htmlstr += "</tbody></table></div>"
        $(".communityandpublicservice").html(htmlstr);
    });
};
