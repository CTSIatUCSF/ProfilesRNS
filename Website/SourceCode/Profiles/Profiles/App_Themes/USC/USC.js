$(document).ready(function () {
	
	//Search Form: featured options
    if ($('#selOtherOptions') && $('#selOtherOptions').length) {
		$("#divMaster_CTC1 label:contains('Clinical Trials')").parent().addClass('trials1');
		$('.trials2').click(function() { 
			if ($('.trials2').is(':checked')) {
				$('.trials1 input:checkbox').attr("checked", true)[0].onclick();
			} else {
				$('.trials1 input:checkbox').attr("checked", false)[0].onclick(); 
			}
		});
		$("#divMaster_CTC1 label:contains('Faculty Mentoring')").parent().addClass('faculty1');
		$('.faculty2').click(function() { 
			if ($('.faculty2').is(':checked')) {
				$('.faculty1 input:checkbox').attr("checked", true)[0].onclick();
			} else {
				$('.faculty1 input:checkbox').attr("checked", false)[0].onclick(); 
			}
		});
		$("#divMaster_CTC1 label:contains('Student Mentoring')").parent().addClass('student1');
		$('.student2').click(function() { 
			if ($('.student2').is(':checked')) {
				$('.student1 input:checkbox').attr("checked", true)[0].onclick();
			} else {
				$('.student1 input:checkbox').attr("checked", false)[0].onclick(); 
			}
		});
	}
	
	
	// PlumX metrics, don’t attempt to load till after 7 seconds, which is 7000 milliseconds 
	setTimeout(function () { 
      if ($('#publicationListAll') && $('#publicationListAll').length) {
		$("#publicationListAll li a:contains('PubMed')").each(function () { 
			var pmid = $(this).attr('href').match(/(\d+)$/); 
            if (pmid && pmid[0] && $(this).attr('href').includes('pubmed')) { // Eric. Added check to only include pubmed links, and thus weed out PMCID ones
				$(this).parent().append("<a href='https://plu.mx/usc/a/?pmid=" + pmid[0] + "' class='plumx-plum-print-popup' data-popup='bottom' data-hide-when-empty='true' data-site='usc' data-badge='true'></a>");
			}
		});
		$.getScript('https://d39af2mgp1pqhg.cloudfront.net/widget-popup.js');
	  }
	}, 7000);

});
