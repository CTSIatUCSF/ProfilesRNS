$(document).ready(function () {
    // logged in/out subnav
  if ($('#defaultmenu') && $('#defaultmenu').length) {
    $('#defaultmenu ul').addClass('mainmenu');
    $(".mainmenu li:contains('RDF')").addClass('rdf').appendTo('.profilesMainColumnRight').hide();
    if ($('.mainmenu li').last().text() == 'Login to Profiles') {
        var login = $('.mainmenu li:last-child a').attr('href');
        $('#signinlink').attr('href', login);
    }
    if ($('.mainmenu li').last().text() == 'Sign out' ||
      $('.mainmenu li').last().text() == 'Logout') {
        $("#signin").hide();
        for (var index = 3; index < $('.mainmenu li').length; index++) {
            $('.mainmenu li').eq(index).clone().appendTo('#editmenu');
        }
        $("#active-nav").css('background-color', '#ECECEC');
        $('#editmenu li').last().css('border-right', 'none');
        $("#editmenu li:contains('Sign out')").addClass('logout');
        if ($('#editmenu li:first-child img').length) {
            $('#editmenu li:first-child img').prependTo('#editmenu li:nth-child(2) a').wrap('<div id="menuthumb" />');
            $('#editmenu li:first-child').remove();
        }
        if ($('.mainmenu li:nth-child(4)').text() == 'Edit My Profile' ||
         $('.mainmenu li:nth-child(5)').text() == 'Edit My Profile') {
            $('#editmenu li:first-child').append(' <span>is signed in</span>');
        }
    }
  }

    // copyright year
	if ($('#copyright-year') && $('#copyright-year').length) {
		$("#copyright-year").text( (new Date).getFullYear() );
	}
	
    // navbarsearch
    // remove from network pages - still necessary?
	if ($('.nonavbar') && $('.nonavbar').length) {
        $('#navbarsearch').remove();
    }
    // scope text drawn from selected option's title
	$('#nav-search-in-content').text($('#searchDropdownBox select').find("option:selected").attr("title"));
	$('#searchDropdownBox select').change(function() {
		$('#nav-search-in-content').text($(this).find("option:selected").attr("title"));
    });

    // Back to top http://typicalwhiner.com/116/effortless-jquery-floating-back-to-top-script-v2/
	// Not used on network pages
  if(window.location.href.indexOf("coauthors") == -1) {
    $("table").removeAttr("border").removeAttr("rules");

    var pxShow = 300; //height on which the button will show  
    var fadeInTime = 1000;  //how slow/fast you want the button to show  
    var fadeOutTime = 1000;  //how slow/fast you want the button to hide  
    var scrollSpeed = 1000;  //how slow/fast you want the button to scroll to top
    $(window).scroll(function () {
        if ($(window).scrollTop() >= pxShow) {
            $("#backtotop").fadeIn(fadeInTime);
        } else {
            $("#backtotop").fadeOut(fadeOutTime);
        }
    });

    $('#backtotop a').click(function () {
        $('html, body').animate({ scrollTop: 0 }, scrollSpeed);
        if (window.location.hash.length > 1) {
            window.location.hash = "";
        }
        return false;
    });

  }
});
