<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditAcademicSenate.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.AcademicSenate" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Literal runat="server" ID="litjs"></asp:Literal>

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
	This section uses information from UCSF’s database of Academic Senate faculty service. We were unable to find any data for you there. Therefore, you can not add it to your profile page. Please contact <a href="mailto:Joey.Cheng@ucsf.edu">Joey.Cheng@ucsf.edu</a> with questions about the Academic Senate.
</asp:Panel>

<asp:Panel runat="server" ID="pnlAddEditAcademicSenate">
        <div id="senate-committees">
			<div class="sc-title">
				This section uses information from UCSF’s database of Academic Senate faculty service and is not editable in Profiles. Please contact <a href="mailto:Joey.Cheng@ucsf.edu">Joey.Cheng@ucsf.edu</a> with questions about the Academic Senate.
			</div>    
			<div class="committee-list" style="display:none">
				<table></table>
			</div>
			<div id="debug" style="display:none"></div>
        </div>
</asp:Panel>

