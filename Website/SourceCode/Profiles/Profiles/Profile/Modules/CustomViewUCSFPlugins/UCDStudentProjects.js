UCDStudentProjects = {};

UCDStudentProjects.init = function (data) {
  UCDStudentProjects.render(
    JSON.parse(data.split("\r").join("").split("\n").join("\\n")),
  );
};

UCDStudentProjects.escapeHtml = function (value) {
  return $("<div>")
    .text(value == null ? "" : value)
    .html();
};

UCDStudentProjects.render = function (data) {
  $(document).ready(function () {
    // ------------------------------------------------------------
    // Types of Research
    // ------------------------------------------------------------

    if (data.typeOfResearch) {
      if (data.typeOfResearchOther && data.typeOfResearchOther.trim()) {
        data.typeOfResearch.push(data.typeOfResearchOther.trim());
      }

      if (data.typeOfResearch.length > 0) {
        let html = "";

        for (const item of data.typeOfResearch) {
          html +=
            '<li class="researcherprofiles--ucdstudentprojects--typesofresearch--item">' +
            UCDStudentProjects.escapeHtml(item.trim()) +
            "</li>";
        }

        $(".researcherprofiles--ucdstudentprojects--typesofresearch").html(
          html,
        );

        $(".researcherprofiles--ucdstudentprojects--types-section").show();
      }
    }

    // ------------------------------------------------------------
    // Student Projects
    // ------------------------------------------------------------

    if (data.currentProjects && data.currentProjects.length > 0) {
      let html = "";

      for (const proj of data.currentProjects) {
        html +=
          '<li class="researcherprofiles--ucdstudentprojects--studentprojects--item">' +
          '<article class="researcherprofiles--ucdstudentprojects--project">';

        // Project name (linked to the project URL, when present)
        if (proj.name && proj.name.trim()) {
          const name = UCDStudentProjects.escapeHtml(proj.name.trim());
          const url = proj.url && proj.url.trim();

          html +=
            '<h3 class="researcherprofiles--ucdstudentprojects--project-name">';

          if (url) {
            html +=
              '<a href="' +
              UCDStudentProjects.escapeHtml(url) +
              '"' +
              ' target="_blank"' +
              ' rel="noopener noreferrer">' +
              name +
              "</a>";
          } else {
            html += name;
          }

          html += "</h3>";
        }

        // Location
        if (proj.location && proj.location.trim()) {
          html +=
            '<p class="researcherprofiles--ucdstudentprojects--project-location">' +
            UCDStudentProjects.escapeHtml(proj.location.trim()) +
            "</p>";
        }

        // Project details
        const fields = [
          {
            label: "Objectives",
            value: proj.objectives,
          },
          {
            label: "Student Responsibilities",
            value: proj.responsibilities,
          },
          {
            label: "Estimated Start Date",
            value: proj.startDate,
          },
          {
            label: "Estimated End Date",
            value: proj.endDate,
          },
          {
            label: "Contact Information",
            value: proj.contactinfo,
          },
        ];

        const populatedFields = fields.filter(function (field) {
          return field.value && field.value.trim();
        });

        if (populatedFields.length > 0) {
          html +=
            '<dl class="researcherprofiles--ucdstudentprojects--project-details">';

          for (const field of populatedFields) {
            html +=
              '<div class="researcherprofiles--ucdstudentprojects--project-field">' +
              '<dt class="researcherprofiles--ucdstudentprojects--project-label">' +
              UCDStudentProjects.escapeHtml(field.label) +
              "</dt>" +
              '<dd class="researcherprofiles--ucdstudentprojects--project-value">' +
              UCDStudentProjects.escapeHtml(field.value.trim()) +
              "</dd>" +
              "</div>";
          }

          html += "</dl>";
        }

        html += "</article>" + "</li>";
      }

      $(".researcherprofiles--ucdstudentprojects--studentprojects").html(html);

      $(".researcherprofiles--ucdstudentprojects--projects-section").show();
    }

    // ------------------------------------------------------------
    // Last Updated
    // ------------------------------------------------------------

    if (data.lastUpdated && data.lastUpdated.trim()) {
      $(".researcherprofiles--ucdstudentprojects--last-updated")
        .text("Last updated: " + data.lastUpdated.trim())
        .show();
    }
  });
};
