<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NetworkTimeline.ascx.cs" Inherits="Profiles.Profile.Modules.NetworkTimeline.NetworkTimeline" %>
<div id="divData">
    <div class='tabInfoText'>
	    <%= InfoCaption %>
    </div>

    <div style="clear:both;padding-bottom:10px;">
    <a id="divShowTimelineTable" tabindex="0">View visualization as text</a>
    </div>

    <div class="keywordTimeline">
	    <img runat='server' id='timelineImage' class="keywordTimelineImage"/>
    </div>

    <div class="keywordTimelineLabels" runat='server' id='timelineDetails'>
    </div>

</div>

<div id="pnlDataText" style="display:none;margin-top:12px;margin-bottom:8px;">
    <div style="clear:both;padding-bottom:10px;">
    <a id="dirReturnToTimeline" tabindex="0">View timeline visualization</a>
    </div>
    <asp:Literal runat="server" ID="litNetworkText"></asp:Literal> 
    <!--cp <br/>
    To return to the timeline, <a id="dirReturnToTimeline" tabindex="0">click here.</a>   -->                    
</div>

<script type="text/javascript">
    jQuery(function () {
        jQuery("#divShowTimelineTable").bind("click", function () {

            jQuery("#pnlDataText").show();
            jQuery("#divData").hide();
        });

        jQuery("#divShowTimelineTable").bind("keypress", function (e) {
            if (e.keyCode == 13) {
                jQuery("#pnlDataText").show();
                jQuery("#divData").hide();
            }
        });
    });

    jQuery(function () {
        jQuery("#dirReturnToTimeline").bind("click", function () {
            jQuery("#pnlDataText").hide();
            jQuery("#divData").show();
        });

        jQuery("#dirReturnToTimeline").bind("keypress", function (e) {
            if (e.keyCode == 13) {
                jQuery("#pnlDataText").hide();
                jQuery("#divData").show();
            }
        });
    });
</script>