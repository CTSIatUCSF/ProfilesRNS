<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditGlobalHealthEquity.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.GlobalHealthEquity" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:UpdatePanel ID="upnlEditSection" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:UpdateProgress ID="updateProgress" runat="server" DynamicLayout="true" DisplayAfter="1000">
            <ProgressTemplate>
                <div class="modalupdate">
                    <div class="modalcenter">
                        <img alt="Updating..." src="<%=Profiles.Framework.Utilities.Brand.GetThemedDomain()%>/edit/images/loader.gif" /><br />
                        <i>Updating...</i>
                    </div>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </ContentTemplate>
</asp:UpdatePanel>
<asp:HiddenField runat="server" ID="hdnURL" />

<div class="editBackLink">
    <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
</div>
<asp:Panel ID="phSecuritySettings" runat="server">
    <security:Options runat="server" ID="securityOptions"></security:Options>
</asp:Panel>
<asp:Panel runat="server" ID="pnlAddEdit">
    <div class="EditMenuItem">
        <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
        <asp:LinkButton ID="btnAddEditEdit" runat="server" OnClick="btnAddEdit_OnClick">Add Global Health Interest(s)</asp:LinkButton>
    </div>
</asp:Panel>
<asp:Panel ID="pnlGlobalHealthInterests" runat="server" CssClass="EditPanel" Visible="false">
    <div style="margin-bottom: 10px;">
        Display global health equity interests and locations on your profile. 
    </div>
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Global Health Equity Interests</b></div>
            <asp:DropDownList ID="ddlInterests" runat="server" Width="800px"/>
        </div>
        <div class="actionbuttons">
            <asp:LinkButton ID="btnSaveAndClose" runat="server" CausesValidation="False"
                OnClick="btnSaveAndClose_OnClick" Text="Save" TabIndex="11" />
            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                    Text="Cancel" TabIndex="7" />
        </div>
    </div>
</asp:Panel>
<div class="editPage">
    <asp:GridView ID="GridViewGlobalHealthInterests" runat="server" AutoGenerateColumns="False"
        GridLines="Both"
        OnRowDataBound="GridViewGlobalHealthInterests_RowDataBound"
        OnRowDeleting="GridViewGlobalHealthInterests_RowDeleting" 
        CssClass="editBody">
        <HeaderStyle CssClass="topRow" />
        <Columns>
            <asp:TemplateField HeaderText="Global Health Equity Interests" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                <EditItemTemplate>
                    <asp:TextBox ID="txtGlobalHealthInterests" runat="server" MaxLength="400" Width="800px" Text='<%# Container.DataItem %>' />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="lblGlobalHealthInterests" runat="server" Text='<%# Container.DataItem %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="alignCenterAction" HeaderText="Action" ItemStyle-CssClass="alignCenterAction">
                <EditItemTemplate>
                    <asp:LinkButton ID="lnkUpdate" runat="server"
                        CausesValidation="True" CommandName="Update" Text="Save" />
                    &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp
                                <asp:LinkButton ID="lnkCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                </EditItemTemplate>
                <ItemTemplate>
                    <span>
                        <asp:ImageButton OnClick="ibUp_Click" runat="server" CommandArgument="up" CommandName="action"
                            ID="ibUp" ImageUrl="~/Edit/Images/icon_up.gif" AlternateText="Move Up" />
                        <asp:ImageButton runat="server" ID="ibUpGray" Enabled="false" Visible="false" ImageUrl="~/Edit/Images/Icon_rounded_ArrowGrayUp.png" AlternateText="Move Up" />
                    </span>
                    <span>
                        <asp:ImageButton runat="server" OnClick="ibDown_Click" ID="ibDown" CommandArgument="down"
                            CommandName="action" ImageUrl="~/Edit/Images/icon_down.gif" AlternateText="Move Down" />
                        <asp:ImageButton runat="server" ID="ibDownGray" Enabled="false" Visible="false" ImageUrl="~/Edit/Images/Icon_rounded_ArrowGrayDown.png" AlternateText="Move Down" />
                    </span>
                    <span>
                        <asp:ImageButton ID="lnkDelete" runat="server" ImageUrl="~/Edit/Images/icon_delete.gif"
                            CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this entry?');"
                            AlternateText="Delete"></asp:ImageButton>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <div class="editBody" style="text-align: left;" id="divNoInterests" runat="server">
        <i></i>
        <asp:Label runat="server" ID="lblNoInterests" Text="No global health interests have been addded to your profile"></asp:Label>
    </div>
</div>

