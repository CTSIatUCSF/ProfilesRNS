<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditIdentity.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.Identity" %>
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

<asp:UpdatePanel ID="upnlEditIdentity" runat="server" CssClass="EditPanel" UpdateMode="Conditional">
    <ContentTemplate>
        <div style="margin-bottom: 10px;">
            <b>Identity</b>
            <p>Use this section to identify your membership in the following communities. Check as many as you wish to show.  
               Depending on your privacy settings, these may be visible within UCSF or to the general public. </p>
        </div>
        <section class="researcherprofiles--identity-edit--container">
            <div class="researcherprofiles--identity-edit--section">
                <header class="researcherprofiles--identity-edit--section-title">Race</header>
                <div class="researcherprofiles--identity-edit--input-group">
                    <asp:CheckBoxList ID="cblRace" runat="server" RepeatLayout="UnorderedList" RepeatDirection="Vertical" Visible="true"/>
                </div>

                <header class="researcherprofiles--identity-edit--section-title">Sexual Orientation</header>
                    <asp:CheckBoxList ID="cblSexualOrientation" runat="server" RepeatLayout="UnorderedList" RepeatDirection="Vertical" Visible="true"/>
                </div>

                <header class="researcherprofiles--identity-edit--section-title">Gender Identity</header>
                <div class="researcherprofiles--identity-edit--input-group">
                    <asp:CheckBoxList ID="cblGenderIdentity" runat="server" RepeatLayout="UnorderedList" RepeatDirection="Vertical" Visible="true"/>
                </div>

                <header class="researcherprofiles--identity-edit--section-title">Other</header>
                <div class="researcherprofiles--identity-edit--input-group">
                    <asp:CheckBoxList ID="cblOther" runat="server" RepeatLayout="UnorderedList" RepeatDirection="Vertical" Visible="true"/>
                </div>

                <header class="researcherprofiles--identity-edit--section-title">Narrative (optional)</header>
                <div class="researcherprofiles--identity-edit--input-group">
                    <asp:TextBox ID="txtNarrative" runat="server" TextMode="MultiLine" Rows="4" Width="550px"></asp:TextBox>
                </div>

                <div class="actionbuttons">
                    <asp:LinkButton ID="btnSaveIdentity" runat="server" CausesValidation="False" OnClick="btnSave_OnClick" Text="Save" TabIndex="11" />
                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                    <asp:LinkButton ID="btnCancelIdentity" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick" Text="Cancel" TabIndex="12" />
                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                    <asp:LinkButton ID="btnDeleteIdentity" runat="server" CausesValidation="False" OnClick="btnDelete_OnClick" Text="Delete" TabIndex="13" />
                </div>
            </div>
        </section>
    </ContentTemplate>
</asp:UpdatePanel>

