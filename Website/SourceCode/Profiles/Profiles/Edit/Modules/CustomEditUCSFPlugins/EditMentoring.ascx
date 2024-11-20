<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditMentoring.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.Mentoring" %>
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

<asp:Panel runat="server" ID="pnlAddEditMentoring">
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Mentoring Narrative</b></div>
            <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnCopyAdvanceMentoring_OnClick" ID="imbAdvanceArrow" AlternateText=" " 
                ImageUrl="~/Edit/Images/icon_squareArrow.gif" OnClientClick="Javascript:return confirm('Are you sure you want to import Mentoring from Advance?');"/>
            <asp:LinkButton ID="btnCopyAdvanceMentoring" runat="server" OnClick="btnCopyAdvanceMentoring_OnClick"
                OnClientClick="Javascript:return confirm('Are you sure you want to OVERWRITE with Mentoring Summary from your Advance CV?');">Overwrite this narrative with the Mentoring Summary from Advance CV</asp:LinkButton>
            <p class="text-left"><asp:Literal runat="server" ID="litAdvanceMessage" Text="Note: If you have set Prefs in Advance to share data with Profiles, this action overwrites the Mentoring Narrative on this page. Once brought over, the data is independent from your Advance CV. Edits you make here will not affect your Advance CV."/></p>
            <asp:TextBox ID="txtNarrative" runat="server" TextMode="MultiLine" Rows="4" Width="550px"></asp:TextBox>
        </div>
        <div class="actionbuttons">
            <asp:LinkButton ID="btnSaveNarrative" runat="server" CausesValidation="False"
                OnClick="btnSaveNarrative_OnClick" Text="Save Narrative" TabIndex="11" />
            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                    Text="Cancel" TabIndex="12" />
        </div>
    </div>
    </p>
    <div class="EditMenuItem">
        <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrowInterest" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
        <asp:LinkButton ID="btnAddEditEditInterest" runat="server" OnClick="btnAddEdit_OnClick">Add new Mentoring Interest</asp:LinkButton>
    </div>
</asp:Panel>

<asp:Panel ID="pnlMentoringInterests" runat="server" CssClass="EditPanel" Visible="false">
    <div style="margin-bottom: 10px;">
        Add a mentoring interest to your profile. 
    </div>
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Mentoring Interests</b></div>
            I can mentor <asp:DropDownList ID="ddlMentee" runat="server" Width="300px"/> on <asp:DropDownList ID="ddlType" runat="server" Width="200px"/>
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
        <asp:Label runat="server" ID="lblRedundantEntry" Text="That entry already exists for your mentoring section." Visible="false" ForeColor="Red" Font-Bold="true"></asp:Label>
    </div>
</asp:Panel>


<div class="editPage">
    <asp:GridView ID="GridViewMentoringInterests" runat="server" AutoGenerateColumns="False"
        DataKeyNames="mentee, type" GridLines="Both"
        OnRowDeleting="GridViewMentoring_RowDeleting" 
        CssClass="editBody">
        <HeaderStyle CssClass="topRow" />
        <Columns>
            <asp:TemplateField HeaderText="Mentoring Interests" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                <ItemTemplate>
                    I can mentor <asp:Label ID="lblMentoringItemMentee" runat="server" Text='<%# Bind("mentee") %>'></asp:Label> on 
                    <asp:Label ID="lblMentoringItemType" runat="server" Text='<%# Bind("type") %>'></asp:Label>
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


    <div class="editBody" style="text-align: left;" id="divNoMentoring" runat="server">
        <i></i>
        <asp:Label runat="server" ID="lblNoGlobalHealthEquity" Text="No mentoring information has been addded to your profile"></asp:Label>
    </div>
</div>

