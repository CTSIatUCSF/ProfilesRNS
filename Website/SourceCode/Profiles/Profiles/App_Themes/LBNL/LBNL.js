$(document).ready(function () {
	
    // Back to top http://typicalwhiner.com/116/effortless-jquery-floating-back-to-top-script-v2/
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
	
});
