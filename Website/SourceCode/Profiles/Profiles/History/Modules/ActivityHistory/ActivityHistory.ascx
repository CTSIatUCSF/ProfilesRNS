<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ActivityHistory.ascx.cs"
    Inherits="Profiles.History.Modules.ActivityHistory.ActivityHistory" %>
<script type="text/javascript">
    var activitySize;

    $(document).ready(function () {
        setInterval(function () { GetRecords(true) }, 30000);
    }); 

    // function to detect if scrollbar is present
    (function ($) {
        $.fn.hasScrollBar = function () {
            return this.get(0) ? this.get(0).scrollHeight > this.innerHeight() : false;
        }
    })(jQuery);

    function ScrollAlert(){  
        var scrolltop = $('.clsScroll').attr('scrollTop');
        var scrollheight = $('.clsScroll').attr('scrollHeight');
        var windowheight = $('.clsScroll').attr('clientHeight');
        var scrolloffset=20;  
        if(scrolltop>=(scrollheight-(windowheight+scrolloffset)))  
        {
            GetRecords(false);
        }  
    }  
    
    function GetRecords(newActivities) {
        var referenceActivityId = newActivities ? $(".act-id").first().text() : $(".act-id").last().text();
        // only set this the first time
        activitySize = activitySize || $(".act-id").length;
        $("#loader").show();
        $.ajax({
            type: "POST",
            url: "<%=GetURLDomain()%>/History/ActivityDetails.aspx/GetActivities",
            data: '{"referenceActivityId": "' + referenceActivityId + '", "count": "' + activitySize + '", "newActivities": "' + newActivities + '"}',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: OnSuccess,
            failure: function (response) {
                alert(response.d);
            },
            error: function (response) {
                alert(response.d);
            }
        });
    }

    function OnSuccess(response) {
        var activities = JSON.parse(response.d);
        var addToBottom = activities.length && activities[0].Id < $(".act-id").first().text();
        if (addToBottom) {
            // we want to invert the array so that we add the most recent one last
            activities.reverse();
        }
        $.each(activities, function (index, newActivity) {
            var activityTemplate = addToBottom ? $(".actTemplate").last().clone(true) : $(".actTemplate").first().clone(true);
            // bail if it is for the same person. Can only happen on a new fetch being stitched into the existing one
            // because each fetch is already declumped against itself
            if (activityTemplate.find("a").first().attr("href") == newActivity.Profile.URL) {
                return true;
            }
            activityTemplate.find("a").attr("href", newActivity.Profile.URL);
            activityTemplate.find(".act-img").attr("src", newActivity.Profile.Thumbnail);
            activityTemplate.find(".act-user").find("a").html(newActivity.Profile.Name);
            activityTemplate.find(".act-date").html(newActivity.Date);
            activityTemplate.find(".act-msg").html(newActivity.Message);
            activityTemplate.find(".act-id").text(newActivity.Id);
            if (addToBottom) {
                // add to the bottom
                $(".actTemplate").last().after(activityTemplate.html());
            }
            else {
                // if there are no scroll bars, remove the last one to make room
                if (!$(".clsScroll").hasScrollBar()) {
                    $(".actTemplate").last().remove();
                }
                // prepend to the top
                $(".actTemplate").first().before(activityTemplate.html());
            }
        });
        $("#loader").hide();
    }
</script>
<div class="activities">
<div class="act-heading"><strong>Live Updates</strong></div>
<asp:Panel runat="server" ID="pnlActivities" CssClass="clsScroll" >
<asp:Repeater runat="server" ID="rptActivityHistory" OnItemDataBound="rptActivityHistory_OnItemDataBound">
    <ItemTemplate>
        <div class="actTemplate">
        <div class="act">
       	   <div class="act-body">
                <div class="act-image"><asp:HyperLink runat="server" ID="linkThumbnail"></asp:HyperLink></div>
                <div class="act-userdate">
    	    	    <div class="act-user"><asp:HyperLink runat="server" ID="linkProfileURL"></asp:HyperLink></div>
		            <div class="date"><asp:Literal runat="server" ID="litDate"></asp:Literal></div>
        		</div>
        	    <div class="act-msg"><asp:Literal runat="server" ID="litMessage"></asp:Literal></div>
	        </div>
    	    <div class="act-id" style="display: none"><asp:Literal runat="server" ID="litId"></asp:Literal></div>
        </div>
        </div>
    </ItemTemplate>
</asp:Repeater>
</asp:Panel>
</div>
<asp:HyperLink ID="linkSeeMore" runat="server" NavigateUrl="~/History/ActivityDetails.aspx"><img src="Images/icon_squareArrow.gif" /> See more Activities</asp:HyperLink>
<div id="divStatus">
    <div class="loader">
            <span><img alt="Loading..." id="loader" src="<%=GetURLDomain()%>/Edit/Images/loader.gif" width="400" height="213" style="display: none"/></span>
   </div>
</div>

