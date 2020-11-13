$(document).ready(function () {

    //Search Form: featured options
    if ($('#selOtherOptions') && $('#selOtherOptions').length) {
        $("#divMaster_CTC1 label:contains('Student Projects')").parent().addClass('studentProjects1');
        $('.studentProjects2').click(function () {
            if ($('.studentProjects2').is(':checked')) {
                $('.studentProjects1 input:checkbox').attr("checked", true)[0].onclick();
            } else {
                $('.studentProjects1 input:checkbox').attr("checked", false)[0].onclick();
            }
        });
    }

});
