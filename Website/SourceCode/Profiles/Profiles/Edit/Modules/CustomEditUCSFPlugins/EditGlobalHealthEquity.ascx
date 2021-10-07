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

<div class="editBackLink">
    <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
</div>

<asp:Panel ID="phSecuritySettings" runat="server">
    <security:Options runat="server" ID="securityOptions"></security:Options>
</asp:Panel>

<asp:Panel runat="server" ID="pnlAddEditInterest">
    <div class="EditMenuItem">
        <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrowInterest" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
        <asp:LinkButton ID="btnAddEditEditInterest" runat="server" OnClick="btnAddEdit_OnClick">Add Global Health Equity Interest</asp:LinkButton>
    </div>
</asp:Panel>

<asp:Panel runat="server" ID="pnlAddEditLocation">
    <div class="EditMenuItem">
        <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrowLocation" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
        <asp:LinkButton ID="btnAddEditEditLocation" runat="server" OnClick="btnAddEdit_OnClick">Add Global Health Equity Location of Work</asp:LinkButton>
    </div>
</asp:Panel>

<asp:Panel runat="server" ID="pnlAddEditCenter">
    <div class="EditMenuItem">
        <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrowCenter" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
        <asp:LinkButton ID="btnAddEditCenter" runat="server" OnClick="btnAddEdit_OnClick">Add UCSF Global Health Equity Center & Program</asp:LinkButton>
    </div>
</asp:Panel>

<asp:Panel ID="pnlGlobalHealthInterests" runat="server" CssClass="EditPanel" Visible="false">
    <div style="margin-bottom: 10px;">
        Display global health equity interests on your profile. 
    </div>
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Global Health Equity Interests</b></div>
            <asp:DropDownList ID="ddlInterests" runat="server" Width="800px"/>
        </div>
        <div class="actionbuttons">
            <asp:LinkButton ID="btnInsertInterests" runat="server" CausesValidation="False" OnClick="btnInsert_OnClick" Text="Save and add another"  TabIndex="10"></asp:LinkButton>
                &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
            <asp:LinkButton ID="btnSaveAndCloseInterests" runat="server" CausesValidation="False"
                OnClick="btnSaveAndClose_OnClick" Text="Save and Close" TabIndex="11" />
            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                <asp:LinkButton ID="btnCancelInterests" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                    Text="Cancel" TabIndex="12" />
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlGlobalHealthLocations" runat="server" CssClass="EditPanel" Visible="false">
    <div style="margin-bottom: 10px;">
        Display global health equity locations on your profile. 
    </div>
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Global Health Equity Locations</b></div>
            <asp:DropDownList ID="ddlLocations" runat="server" Width="800px"/>
        </div>
        <div class="actionbuttons">
            <asp:LinkButton ID="btnInsertLocations" runat="server" CausesValidation="False" OnClick="btnInsert_OnClick" Text="Save and add another"  TabIndex="10"></asp:LinkButton>
                &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
            <asp:LinkButton ID="btnSaveAndCloseLocations" runat="server" CausesValidation="False"
                OnClick="btnSaveAndClose_OnClick" Text="Save and Close" TabIndex="11" />
            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                <asp:LinkButton ID="btnCancelLocations" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                    Text="Cancel" TabIndex="12" />
        </div>
    </div>
</asp:Panel>

<asp:Panel ID="pnlGlobalHealthCenters" runat="server" CssClass="EditPanel" Visible="false">
    <div style="margin-bottom: 10px;">
        Display UCSF global health equity centers and programs on your profile. 
    </div>
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>UCSF Global Health Equity Centers & Programs</b></div>
            <asp:DropDownList ID="ddlCenters" runat="server" Width="800px"/>
        </div>
        <div class="actionbuttons">
            <asp:LinkButton ID="btnInsertCenters" runat="server" CausesValidation="False" OnClick="btnInsert_OnClick" Text="Save and add another"  TabIndex="10"></asp:LinkButton>
                &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
            <asp:LinkButton ID="btnSaveAndCloseCenters" runat="server" CausesValidation="False"
                OnClick="btnSaveAndClose_OnClick" Text="Save and Close" TabIndex="11" />
            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                <asp:LinkButton ID="btnCancelCenters" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                    Text="Cancel" TabIndex="12" />
        </div>
    </div>
</asp:Panel>

<div class="editPage">
    <asp:GridView ID="GridViewGlobalHealthInterests" runat="server" AutoGenerateColumns="False"
        GridLines="Both"
        OnRowDeleting="GridViewGlobalHealth_RowDeleting" 
        CssClass="editBody">
        <HeaderStyle CssClass="topRow" />
        <Columns>
            <asp:TemplateField HeaderText="Global Health Equity Interests" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                <ItemTemplate>
                    <asp:Label ID="lblGlobalHealthItem" runat="server" Text='<%# Container.DataItem %>'></asp:Label>
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
                            CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this interest?');"
                            AlternateText="Delete"></asp:ImageButton>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <asp:GridView ID="GridViewGlobalHealthLocations" runat="server" AutoGenerateColumns="False"
        GridLines="Both"
        OnRowDeleting="GridViewGlobalHealth_RowDeleting" 
        CssClass="editBody">
        <HeaderStyle CssClass="topRow" />
        <Columns>
            <asp:TemplateField HeaderText="Global Health Equity Locations" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                <ItemTemplate>
                    <asp:Label ID="lblGlobalHealthItem" runat="server" Text='<%# Container.DataItem %>'></asp:Label>
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
                            CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this location?');"
                            AlternateText="Delete"></asp:ImageButton>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <asp:GridView ID="GridViewGlobalHealthCenters" runat="server" AutoGenerateColumns="False"
        GridLines="Both"
        OnRowDeleting="GridViewGlobalHealth_RowDeleting" 
        CssClass="editBody">
        <HeaderStyle CssClass="topRow" />
        <Columns>
            <asp:TemplateField HeaderText="UCSF Global Health Equity Centers & Programs" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                <ItemTemplate>
                    <asp:Label ID="lblGlobalHealthItem" runat="server" Text='<%# Container.DataItem %>'></asp:Label>
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
                            CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this center and program?');"
                            AlternateText="Delete"></asp:ImageButton>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>

    <div class="editBody" style="text-align: left;" id="divNoGlobalHealthEquity" runat="server">
        <i></i>
        <asp:Label runat="server" ID="lblNoGlobalHealthEquity" Text="No global health equity information have been addded to your profile"></asp:Label>
    </div>
</div>

