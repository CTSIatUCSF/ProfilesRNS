$(document).ready(function () {
	
  //Search Form: clone clinical trials checkbox for promotion
    if ($('#trOtherOptions') && $('#trOtherOptions').length) {
		$("#divOtherOptions label[for='ctcFirst_rMaster_ctl00_rDetail_ctl00_checkDetailText']").parent().addClass('trials1');
		$('.trials2').click(function() { 
			if ($('.trials2').is(':checked')) {
				$('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", true)[0].onclick();
			} else {
				$('#ctcFirst_rMaster_ctl00_divDetail .trials1 :checkbox').attr("checked", false)[0].onclick(); 
			}
		});
	}

});
