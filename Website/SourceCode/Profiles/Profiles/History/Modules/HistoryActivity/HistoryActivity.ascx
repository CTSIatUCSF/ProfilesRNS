<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HistoryActivity.ascx.cs"
    Inherits="Profiles.History.Modules.HistoryActivity.HistoryActivity" %>
<div class="activities">
    <div class="act-heading"><strong>Live Updates</strong></div>
<asp:Repeater runat="server" ID="rptHistoryActivity" OnItemDataBound="rptHistoryActivity_OnItemDataBound">
    <ItemTemplate>
        <div class="divider"/>
        <div class="act">
       	   <div class="act-body">
	       <div class="act-image"><asp:HyperLink runat="server" ID="linkThumbnail"></asp:HyperLink></div>
               <div class="act-userdate">
		   <div class="act-user"><asp:HyperLink runat="server" ID="linkProfileURL"></asp:HyperLink></div>
		   <div class="date"><asp:Literal runat="server" ID="litDate"></asp:Literal></div>
		</div>
	    </div>
    	    <div class="act-msg"><asp:Literal runat="server" ID="litMessage"></asp:Literal></div>
        </div>
    </ItemTemplate>
</asp:Repeater>
</div>
<asp:Label ID="Label4" runat="server" />
<asp:HyperLink ID="linkPrev" runat="server">Previous Page</asp:HyperLink>
<asp:HyperLink ID="linkNext" runat="server">Next Page</asp:HyperLink>
<asp:HyperLink ID="linkSeeMore" runat="server" NavigateUrl="~/History/ActivityDetails.aspx"><img src="Images/icon_squareArrow.gif" /> See more Activities</asp:HyperLink>
