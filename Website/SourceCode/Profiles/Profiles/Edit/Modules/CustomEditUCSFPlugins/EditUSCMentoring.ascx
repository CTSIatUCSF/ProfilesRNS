<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditUSCMentoring.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.USCMentoring" %>
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

<asp:Panel ID="pnlNoData" runat="server">
	Please contact the USC Profiles team to turn this feature on
</asp:Panel>

<asp:UpdatePanel ID="upnlEditMentoring" runat="server" CssClass="EditPanel" UpdateMode="Conditional">
    <ContentTemplate>
        <div style="margin-bottom: 10px;">
            <b>Faculty Mentoring</b>
            <p>Add Faculty Mentoring to Your Profile </p>
            <p>Add details about your availability to mentor USC faculty. 
		        Learn about <a href="https://mentor.usc.edu/" target="_blank" title="Go to the USC Faculty Mentoring Website">Faculty Mentoring</a> 
		        or <a href="https://sc-ctsi.org/consults-new?service=Workforce%20development" target="_blank" title="Request an Education Consultation">Request an Education Consultation</a> for mentor-mentee matchmaking and team building
            </p>
        </div>
        <section class="researcherprofiles--mentoring-edit--container">
            <div class="researcherprofiles--mentoring-edit--section">
                <header class="researcherprofiles--mentoring-edit--section-title">Available to Mentor Faculty as:</header>
                <div class="researcherprofiles--mentoring-edit--input-group">
                    <asp:CheckBoxList ID="cblAvailableFor" runat="server" RepeatLayout="UnorderedList" RepeatDirection="Vertical" Visible="true"/>
                </div>

                <header class="researcherprofiles--mentoring-edit--section-title">Contact Preferences</header>
                    <div class="researcherprofiles--mentoring-edit--input-group">
                    <asp:CheckBoxList ID="cblContactPreferences" runat="server" RepeatLayout="UnorderedList" RepeatDirection="Vertical" Visible="true"/>
                </div>

                <div class="actionbuttons">
                    <asp:LinkButton ID="btnSaveMentoring" runat="server" CausesValidation="False" OnClick="btnSave_OnClick" Text="Save" TabIndex="11" />
                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                    <asp:LinkButton ID="btnCancelMentoring" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick" Text="Cancel" TabIndex="12" />
                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                    <asp:LinkButton ID="btnDeleteMentoring" runat="server" CausesValidation="False" OnClick="btnDelete_OnClick" Text="Delete" TabIndex="13" />
                </div>
            </div>
        </section>
    </ContentTemplate>
</asp:UpdatePanel>

