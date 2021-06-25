// used for lazy multishiblogin
function redirectForLogin(data) {
    if (window.location.href.indexOf("/login") === -1 && data.redirect) {
        window.location.href = decodeURIComponent(data.redirect);
    }
}


$(document).ready(function () {
    // logged in/out subnav
  if ($('#defaultmenu') && $('#defaultmenu').length) {
    $("#defaultmenu ul:contains('SIGN IN')").addClass('anon');
  }
 
    // copyright year
	if ($('#copyright-year') && $('#copyright-year').length) {
		$("#copyright-year").text( (new Date).getFullYear() );
	}
	
    // Back to top http://typicalwhiner.com/116/effortless-jquery-floating-back-to-top-script-v2/
	// Not used on network pages
  if(window.location.href.indexOf("coauthors") === -1) {
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
