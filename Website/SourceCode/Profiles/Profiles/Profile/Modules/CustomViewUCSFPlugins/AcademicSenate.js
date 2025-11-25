AcademicSenate = {};

AcademicSenate.init = function (plugindata) {
    AcademicSenate.render(JSON.parse(plugindata));
};

AcademicSenate.render = function (data) {
    $(document).ready(function () {
		if (data && data.committees) {
			$('.committee-list').show();
			var html = '<tr><th>Title</th><th>Role</th><th>Date</th></tr>';
			data.committees.forEach(function (committee) {
				committee.service.forEach(function (service) {
					var startDate = new Date(service.start_date);
					var endDate = new Date(service.end_date);
					html += '<tr>' +
						'  <td class="c-title">' + committee.title + '</td>' +
						'  <td class="c-role">' + service.role + '</td>' +
						'  <td class="c-date">' + startDate.getFullYear() + '-' + endDate.getFullYear() + '</td>' +
						'</tr>';
				});
			});
			$('.committee-list table').append(html);
		}
    });
};
