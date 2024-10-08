﻿$(document).ready(function () {
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
        $('.collapsible').find('tr:gt(4)').addClass('show-or-hide-as-needed').hide();
        $('.collapsible').find('tr:lt(5)').addClass('always-show');
        $(".collapsible:has('.show-or-hide-as-needed')").append("<tr class='accordion'><td colspan='5'><div class='more'>Show more</div><div class='less' style='display:none'>Show less</div></td></tr>");
        $('.accordion').click(function () {
            $(this).siblings('.show-or-hide-as-needed').toggle();
            $(this).find('.more, .less').toggle();
        });
    }

    //Overview expand/collapse
    if ($('.basicInfo') && $('.basicInfo').length) {
        $('.PropertyItemHeader:contains("verview")').next('.PropertyGroupData').attr("id", "narrative");
        if ($('#narrative').height() > 280) {
            $('#narrative > div').addClass('overview');
            $("<div class='expand-collapse'><div class='more'>Show more</div><div class='less' style='display:none'>Show less</div></div>").insertAfter('.overview');
        }
		$('.expand-collapse').click(function(){
			$(this).siblings().toggleClass('full');
			$(this).find('.more, .less').toggle();
		});
    }

		
});




