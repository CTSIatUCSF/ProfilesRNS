ClinicalTrials = {};

ClinicalTrials.init = function (plugindata) {
	ClinicalTrials.render(JSON.parse(plugindata));
};

ClinicalTrials.dateOptions = { year: 'numeric', month: 'short' };

ClinicalTrials.render = function (data) {
	$(document).ready(function () {
		if (data) {
			$('.clinical-trials-list').show();
			var html = '';
			data.forEach(function (trial) {
				html += '<tr><td><a href="' + trial.SourceUrl + '" + target="_blank">' + trial.Title + '</a><br>'
					+ 'Start Date: ' + new Date(trial.StartDate).toLocaleDateString("en-US", ClinicalTrials.dateOptions) + '</br>';
				if (trial.CompletionDate) {
					html += 'Completion Date: ' + new Date(trial.CompletionDate).toLocaleDateString("en-US", ClinicalTrials.dateOptions) + '</br>';
				}
				if (trial.EstimatedCompletionDate) {
					html += 'Estimated Completion Date: ' + new Date(trial.EstimatedCompletionDate).toLocaleDateString("en-US", ClinicalTrials.dateOptions) + '</br>';
				}
				html += 'Recruitment Status: ' + trial.Status + '</br>Condition(s): ' + trial.Conditions + '</td></tr>';
			});
			$('.clinical-trials-list table').append(html);
		}
	});
};
