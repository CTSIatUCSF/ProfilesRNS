$(document).ready(function () {
    //move other position below primary title
    if ($('.sectionHeader2') && $('.sectionHeader2').length) {
        $('<br><span id="othpos">&nbsp;</span>').appendTo('.basicInfo:first-child tr:nth-child(1) td:nth-child(2)');
        $('.sectionHeader2').siblings().addClass('otherpos');
        $('.otherpos th').html('');
        $('.otherpos td:not(:empty)').append('%');
        var str = $('.otherpos').text();
        str = str.replace(/\%/g, "<br>");
        str = str.replace(/\;/g, "<br>");
        $("#othpos").html(str);
        $('.sectionHeader2').parents('.content_two_columns').hide();
    }


    //TOC
    if ($('#toc') && $('#toc').length) {
        $('.panelMain .PropertyItemHeader').addClass('toc-item');
        $('.toc-item').attr("id", function (arr) {
            return 'toc-id' + arr;
        });
        $('.toc-item').each(function () {
            var id = $(this).attr('id');
            var txt = $.trim($(this).text());
            var alink = '<li><a href=#' + id + '>' + txt + '</a></li>';
            $('#toc ul').append(alink);
        });

        if ($('#toc ul li').length < 3) {
            $('#toc').hide();
        }
        // $('#toc ul li:contains("Publications")').appendTo('#toc ul');
        $('#toc ul li').last().css('border-right', 'none').css('margin-right', '0');

        //class for 1st section
        $('.PropertyItemHeader').first().addClass('first-section');
    }

    //Expand/collapse for Tables (Awards, Education, Grants)
	if ($('.collapsible') && $('.collapsible').length) {			
		$('.collapsible').find('tr:gt(4)').addClass('hide').hide();
		$(".collapsible:has('.hide')").append("<tr class='accordion'><td colspan='5'><div class='more'>Show more <span>+</span></div><div class='less' style='display:none'>Show less <span>-</span></div></td></tr>");
		$('.accordion').click(function(){
			$(this).siblings('.hide').toggle();
			$(this).find('.more, .less').toggle();
		});
	}

    //Overview expand/collapse
    if ($('.basicInfo') && $('.basicInfo').length) {
        $('.PropertyItemHeader:contains("verview")').next('.PropertyGroupData').attr("id", "narrative");
		$('#narrative > div').addClass('overview');
        if ($('.overview').text().length > 800) {
            $("<div class='expand-collapse'><div class='more'>Show more <span>+</span></div><div class='less' style='display:none;margin-top:-20px;'>Show less <span>-</span></div></div>").insertAfter('.overview');
        }
		$('.expand-collapse').click(function(){
			$(this).siblings().toggleClass('full');
			$(this).find('.more, .less').toggle();
			location.href = "#narrative";
		});
    }

    //Remove border when no External Co-Authors
    if ($('.panelPassive .gadgets-gadget-network-parent') && $('.panelPassive .gadgets-gadget-network-parent').length) {
	if ($('.panelPassive .gadgets-gadget-network-parent').height() < 20) {
		$('.panelPassive .gadgets-gadget-network-parent').css("cssText", "border: none !important;");
	}
    }
		
});




