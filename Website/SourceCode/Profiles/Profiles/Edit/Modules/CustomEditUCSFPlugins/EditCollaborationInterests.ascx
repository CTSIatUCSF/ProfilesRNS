<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditCollaborationInterests.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.EditCollaborationInterests" %>
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

<asp:UpdatePanel ID="upnlEditCollaborationInterests" runat="server" CssClass="EditPanel" UpdateMode="Conditional">
    <ContentTemplate>
        <div style="margin-bottom: 10px;">
            <b>Collaboration Interests</b>
            <p>Use this section to indicate what kinds of collaborations or contacts might interest you. 
                Information saved here may be used by UCSF researchers, employees and organizations, and the 
                public depending on your privacy settings, to contact you. They may contact you by any means 
                visible on your profile page, e.g. phone number or email address listed at the top. Please add 
                specific collaboration interests or experience in the collaboration narrative below. </p>
            <p>Last Updated: <asp:Literal ID="litLastUpdated" runat="server"/></p>
            <p><b>Areas of Interests</b> (check all that apply)</p>
        </div>
        <section class="researcherprofiles--collaborationinterests-edit--container">
            <div class="researcherprofiles--collaborationinterests-edit--section">
                <div class="researcherprofiles--collaborationinterests-edit--input-group">
                    <asp:CheckBox ID="cbAcademicCollaboration" runat="server" Text="Academic Collaboration"/> 
                    - interested in talking/meeting with other researchers and potentially working together to 
					<ul>
						<li>brainstorm ideas, review research questions, refine approaches, etc. </li>
						<li>prepare cross-disciplinary grant applications</li>
					</ul>
					<p>The UCSF Research Development Office’s <a href="https://rdo.ucsf.edu/team-science-program" target="_blank">Team Science Program</a> has more information.

					</p>

                    <asp:CheckBox ID="cbAcademicSenateCommitteeService" runat="server" Text="Academic Senate Committee Service"/>
                    - would like to serve on senate academic committees. 
                    Note: Please add any specific interests you have in the Collaboration Narrative below.
                    </p>

                    <asp:CheckBox ID="cbMultiyearClinicalResearch" runat="server" Text="Multicenter Clinical Research"/>
                    - interested in hearing about opportunities to participate in multicenter clinical research projects, 
                    including clinical trials and other types of studies. <font color="red">For example:</font>
						<ul>
							<li>Multicenter studies using the Trials Innovation Network (<a href="https://trialinnovationnetwork.org" target="_blank">TIN</a>)</li>
							<li>Multicenter studies using PCORnet or <a href="https://reachnet.org" target="_blank">REACHNet</a></li>
						</ul>
                    </p>

                    <asp:CheckBox ID="cbCommunityandPartnerOrganizations" runat="server" Text="Community and Partner Organizations"/> 
                    - interested in working with community organizations, clinics and health systems, public health programs, 
                    other community leaders and/or policy makers to advance health for all, with an emphasis on addressing health 
                    inequities and disparities.
                    </p>

                    <asp:CheckBox ID="cbCompainesandEntrepreuners" runat="server" Text="Companies and Entrepreneurs"/>
                    - interested in opportunities vetted by UCSF Health Hub to advise, conduct industry-sponsored research, 
                    and/or co-develop products with growth-stage companies. <span class="underline">Note</span>: UCSF Health Hub offers a private, curated match-making service exclusively for UCSF. 
                    To get started, <a target="_blank" href="https://www.healthhubsf.org/apply">click here to apply</a>.
                    </p>

                    <asp:CheckBox ID="cbPolicyChange" runat="server" Text="Policy Change"/>
                    - Interested in working with policymakers in government, health systems, professional organizations, advocacy organizations, 
                    industry, and other groups to translate evidence into policy, both governmental and non-governmental policy. <a target="_blank" href="https://ctsi.ucsf.edu/about-us/programs/impact">IMPACT</a>
                    </p>

                    <asp:CheckBox ID="cbPress" runat="server" Text="Press"/>
                    - interested in working with University Relations to identify opportunities for publicity around my work or to serve as a topic 
                    area expert for media. Note: Please add any press experience and scope of your interests (e.g. commercialization or ethics) 
                    to your collaborative narrative.
                    </p>

                    <asp:CheckBox ID="cbProspectiveDonors" runat="server" Text="Prospective Donors"/>
                    - willing to work with the UCSF Development Office to talk to potential donors about your research.
                    </p>
                </div>

                <header class="researcherprofiles--collaborationinterests-edit--section-title">Narrative (optional)</header>
                <div class="researcherprofiles--collaborationinterests-edit--input-group">
                    <asp:TextBox ID="txtNarrative" runat="server" TextMode="MultiLine" Rows="4" Width="550px"></asp:TextBox>
                </div>

                <div class="actionbuttons">
                    <asp:LinkButton ID="btnSaveCollaborationInterests" runat="server" CausesValidation="False" OnClick="btnSave_OnClick" Text="Save" TabIndex="11" />
                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                    <asp:LinkButton ID="btnCancelCollaborationInterests" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick" Text="Cancel" TabIndex="12" />
                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                    <asp:LinkButton ID="btnDeleteCollaborationInterests" runat="server" CausesValidation="False" OnClick="btnDelete_OnClick" Text="Delete" TabIndex="13" />
                </div>
            </div>
        </section>
    </ContentTemplate>
</asp:UpdatePanel>

