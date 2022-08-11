FeaturedVideos = {};

FeaturedVideos.init = function (playlist) {
    FeaturedVideos.renderVideos(JSON.parse(playlist));
};

FeaturedVideos.getVideoIdFromYouTubeUrl = function (videoUrl) {
    var video_id;
    var exp = /http[s]?:\/\/(?:[^\.]+\.)*(?:youtube\.com\/(?:v\/|watch\?(?:.*?\&)?v=|embed\/)|youtu.be\/)([\w\-\_]+)/i
    var res = videoUrl.match(exp);
    if (res) {
        video_id = res[1];
    }
    return video_id;
};

FeaturedVideos.getVideoMetadata = function (video, max_height, max_width, callback) {
    // if this is a newer one, we already have the html metadata. Check
    if (video.html) {
        callback(video);
        return;
    }

    var oEmbedURLBase = 'http://api.embed.ly/1/oembed'; // works great, but we need to pay for API key
    oEmbedURLBase = 'https://noembed.com/embed'; // works OK, but hobbyist project

    var oembedURL = oEmbedURLBase + '?maxheight=' + max_height + '&maxwidth=' + max_width + '&url=' + encodeURIComponent(video.url);
    var req = $.ajax({
        url: oembedURL,
        dataType: "jsonp",
        timeout: 10000,
        success: callback
    });
};

// viewing
FeaturedVideos.renderVideos = function (videos) {
    // compile Handlebars template
    var source = $("#video-block-template").html();
    var template = Handlebars.compile(source);

    var need_to_show_list_of_videos = true;
    if (videos.length === 1) {
        $('#video_navigator').detach();
        need_to_show_list_of_videos = false;
    }

    // video iframe should be slightly less than full width and full height
    var max_width = 300;
    if ($('#current_video_container').width()) {
        max_width = $('#current_video_container').width() - 20;
    }
    var max_height = 300;

    $.each(videos, function (i, video) {
        if (video && ("url" in video) && video.url) {
            if (video.youTubeId) {
                video.url = "http://www.youtube.com/watch?v=" + video.youTubeId;
            }

            // add an empty div for each item
            var video_navigator_div_id = 'video_navigator--item-' + i;
            if (need_to_show_list_of_videos) {
                $('#video_navigator').append($('<div id="' + video_navigator_div_id + '"></div>'));
            }

            FeaturedVideos.getVideoMetadata(video, max_height, max_width, function (video_data) {
                if (!video_data.error_code && !video_data.error) {

                    // set video title to the provided label, otherwise use the native title
                    video_data.title = (video.name || video_data.title);

                    // use normalized video URL, or fall back to original URL
                    video_data.url = (video_data.url || video.url);

                    if (need_to_show_list_of_videos) {
                        // run video data through Handlebars template, insert into DOM,
                        //   then save the iframe HTML (video_data.html) to the object's data

                        // if we find our own div, put the video item nav there
                        // otherwise, just put it at the end of the list
                        var inserted_block;
                        if ($('#' + video_navigator_div_id).length === 1) {
                            $('#' + video_navigator_div_id).append(template(video_data));
                            inserted_block = $('#' + video_navigator_div_id + ' .video_option:last');
                        } else {
                            $('#video_navigator').append(template(video_data));
                            inserted_block = $('#video_navigator .video_option:last');
                        }

                        inserted_block.data('video_html', video_data.html);
                    }

                    // if this is the first video on the list, show it big and feature it
                    if (i === 0) {
                        $('#current_video_container').html(video_data.html);
                        if (need_to_show_list_of_videos) {
                            $('#video_navigator').prepend(inserted_block);
                            inserted_block.addClass('selected');
                        }
                    }
                }
            });
        }
    });

    // if user clicks on a video option in the video navigator...
    $('#videos').on("click", '.video_option', function (e) {
        e.preventDefault();
        if (e.ctrlKey || e.metaKey) {
            // open video in new tab on right-click
            var url = $(this).find('a:first').attr('href');
            window.open(url, '_blank');
            //ucsf.gadgetEventTrack('open_video_in_new_window', url);

        } else if (!$(this).hasClass('selected')) { // show video, if not shown
            $('#current_video_container').html($(this).data('video_html'));
            $('#videos .video_option.selected').removeClass('selected');
            $(this).addClass('selected');
            //ucsf.gadgetEventTrack('go_to_video')
        }
        return false;
    });

    $('#videos').on('mouseover', function () {
        $('#videos').off('mouseover');
        //ucsf.gadgetEventTrack('mouseover');
    });

    // if, after the first 3 seconds, the first video didn't load, load whichever one we can
    window.setTimeout(function (x) {
        if (!$('#videos .video_option.selected').length) {
            $('#videos .video_option:first').click();
        }
    }, 3000);
};


