<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HistoryActivity.ascx.cs"
    Inherits="Profiles.History.Modules.HistoryActivity.HistoryActivity" %>
<div class="metrics" style="line-height:21px;padding-left:12px">
<asp:Label ID="Title" runat="server"  /><br />
</div>
<div>
<asp:Label ID="Label1" runat="server"  /><br />
<asp:Label ID="Label2" runat="server"  /><br />
<asp:Label ID="Label3" runat="server"  /><br />
</div>
<asp:Repeater runat="server" ID="rptHistoryActivity" OnItemDataBound="rptHistoryActivity_OnItemDataBound">
    <HeaderTemplate>
    </HeaderTemplate>
    <ItemTemplate>
             <asp:Literal runat="server" ID="litHistoryActivityItem"></asp:Literal>
    </ItemTemplate>
    <FooterTemplate>
    </FooterTemplate>
</asp:Repeater>
<asp:Label ID="Label4" runat="server" />
<asp:HyperLink ID="linkPrev" runat="server">Previous Page</asp:HyperLink>
<asp:HyperLink ID="linkNext" runat="server">Next Page</asp:HyperLink>
<asp:HyperLink ID="linkSeeMore" runat="server">See more Activities</asp:HyperLink>
