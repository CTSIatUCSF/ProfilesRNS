<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ActivityHistory.ascx.cs"
    Inherits="Profiles.History.Modules.ActivityHistory.ActivityHistory" %>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
<script type="text/javascript">
    var pageIndex = 1;
    var pageCount;
    $(window).scroll(function () {
        if ($(window).scrollTop() == $(document).height() - $(window).height()) {
            GetRecords();
        }
    });
    function GetNothing() {
        alert('do nothing');
    }
    function GetRecords() {
        pageIndex++;
        if (pageIndex == 2 || pageIndex <= pageCount || true) {
            //$("#loader").show();
            $.ajax({
                type: "POST",
                url: "ActivityDetails.aspx/GetActivities",
                data: '{"lastActivityId": "123", "count": "7"}',
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
    }
    function OnSuccess(response) {
        var xmlDoc = $.parseXML(response.d);
        var xml = $(xmlDoc);
        pageCount = parseInt(xml.find("PageCount").eq(0).find("PageCount").text());
        var customers = xml.find("Customers");
        customers.each(function () {
            var customer = $(this);
            var table = $("#dvCustomers table").eq(0).clone(true);
            $(".name", table).html(customer.find("ContactName").text());
            $(".city", table).html(customer.find("City").text());
            $(".postal", table).html(customer.find("PostalCode").text());
            $(".country", table).html(customer.find("Country").text());
            $(".phone", table).html(customer.find("Phone").text());
            $(".fax", table).html(customer.find("Fax").text());
            $("#dvCustomers").append(table).append("<br />");
        });
        $("#loader").hide();
    }
</script>
<asp:Panel runat="server" ID="pnlActivities" Height="200">
<asp:Repeater runat="server" ID="rptActivityHistory" OnItemDataBound="rptActivityHistory_OnItemDataBound">
    <ItemTemplate>
        <div class="divider"/>
        <div class="act">
            <div class="act-image"><asp:HyperLink runat="server" ID="linkThumbnail"></asp:HyperLink></div>
       			<div class="act-body">
                   <div class="act-userdate">
    			    <div class="act-user"><asp:HyperLink runat="server" ID="linkProfileURL"></asp:HyperLink></div>
    			    <div class="date"><asp:Literal runat="server" ID="litDate"></asp:Literal></div>
    			    <div class="act-msg"><asp:Literal runat="server" ID="litMessage"></asp:Literal></div>
    		    </div>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>
</asp:Panel>
<asp:HyperLink ID="linkSeeMore" runat="server" NavigateUrl="~/History/ActivityDetails.aspx">See more Activities</asp:HyperLink>
