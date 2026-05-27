<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditRequiredScholarlyProjectMentor.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.RequiredScholarlyProjectMentor" %>
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

<asp:Panel runat="server" ID="pnlAddDelete">
    <div class="EditMenuItem">
        <asp:LinkButton ID="btnAdd" runat="server" OnClick="btnAdd_OnClick">Add Required Scholarly Project Mentor to your profile page</asp:LinkButton>
    </div>
    <div class="actionbuttons">
        <asp:LinkButton ID="btnDelete" runat="server" OnClick="btnDelete_OnClick" Text="Remove Required Scholarly Project Mentor from your profile page" />
    </div>
</asp:Panel>

<asp:Literal runat="server" ID="litStatus"></asp:Literal>
