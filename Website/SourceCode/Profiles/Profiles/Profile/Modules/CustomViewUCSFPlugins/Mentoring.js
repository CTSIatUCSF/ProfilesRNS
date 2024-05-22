Mentoring = {};

Mentoring.init = function (inst, data) {
    // replace \r\n or just \n with \\n
    Mentoring.render(inst, JSON.parse(data.split('\r').join('').split('\n').join('\\n')));
};

// ========================================================================= //
Mentoring.render = function (inst, data) {
    $(document).ready(function () {
        var htmlstr = "";
        if (data.narrative && data.narrative.length > 0) {
            var tempTag = document.createElement("p");
            tempTag.textContent = data.narrative;
            htmlstr += "<p style='white-space: pre-line'>" + tempTag.innerHTML + "</p>";
        }
        if (data.mentoringInterests && data.mentoringInterests.length > 0) {
            var interestStatements = [];
            data.mentoringInterests.forEach(interest => interestStatements.push("<li>" + interest.mentee + " on " + interest.type + "</li>"));
            htmlstr += "<p>I am available to mentor:</p><ul>" + interestStatements.join("") + "</ul>";
        }
        if (inst == "UC Davis") {
            htmlstr += "<p><a href='https://health.ucdavis.edu/ctsc/area/education/mentoring-academy/about-us.html'>Learn about the Mentoring Academy for Research Excellence</a></p>";
        }
        $(".mentoring").html(htmlstr);
    });
};
