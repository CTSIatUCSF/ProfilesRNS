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
                        <img alt="Updating..." src="<%=Profiles.Framework.Ut
ilities.Brand.GetThemedDomain()%>/edit/images/loader.gif" /><br />
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

<asp:UpdatePanel ID="upnlEditCollaborationInterests" runat="server" CssClass="EditPanel researcherprofiles--collaborationinterests-edit--container" UpdateMode="Conditional">
    <ContentTemplate>

        <div class="researcherprofiles--collaborationinterests-edit--header">
            <h2 class="researcherprofiles--collaborationinterests-edit--heading">
                Collaboration Interests
            </h2>

            <p class="researcherprofiles--collaborationinterests-edit--intro">
                Use this section to indicate what kinds of collaborations or contacts might interest you.
                Information saved here may be used by UCSF researchers, employees and organizations, and the
                public depending on your privacy settings, to contact you. They may contact you by any means
                visible on your profile page, e.g. phone number or email address listed at the top. Please add
                specific collaboration interests or experience in the collaboration narrative below.
            </p>

            <p class="researcherprofiles--collaborationinterests-edit--last-updated">
                Last Updated: <asp:Literal ID="litLastUpdated" runat="server" />
            </p>

            <p class="researcherprofiles--collaborationinterests-edit--subhead">
                <strong>Areas of Interest</strong> (check all that apply)
            </p>
        </div>

        <section class="researcherprofiles--collaborationinterests-edit--section">
            <div class="researcherprofiles--collaborationinterests-edit--input-group">

                <!-- Academic Collaboration -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbAcademicCollaboration" runat="server"
                        Text="Academic Collaboration" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Interested in talking/meeting with other researchers and potentially working together to:</p>
                        <ul>
                            <li>brainstorm ideas, review research questions, refine approaches, etc.</li>
                            <li>prepare cross-disciplinary grant applications</li>
                        </ul>
                        <p>
                            The UCSF Research Development Office’s
                            <a href="https://rdo.ucsf.edu/team-science-program"
                               target="_blank" rel="noopener">Team Science Program</a>
                            has more information.
                        </p>
                    </div>
                </div>

                <!-- Academic Senate -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbAcademicSenateCommitteeService" runat="server"
                        Text="Academic Senate Committee Service" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Would like to serve on senate academic committees. Please add any specific interests in the Collaboration Narrative below.</p>
                    </div>
                </div>

                <!-- Multicenter Clinical Research -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbMultiyearClinicalResearch" runat="server"
                        Text="Multicenter Clinical Research" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Interested in hearing about opportunities to participate in multicenter clinical research projects, including clinical trials and other types of studies. For example:</p>
                        <ul>
                            <li>Multicenter studies using the <a href="https://trialinnovationnetwork.org" target="_blank" rel="noopener">Trials Innovation Network (TIN)</a></li>
                            <li>Multicenter studies using PCORnet or <a href="https://reachnet.org" target="_blank" rel="noopener">REACHNet</a></li>
                        </ul>
                    </div>
                </div>

                <!-- Community -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbCommunityandPartnerOrganizations" runat="server"
                        Text="Community and Partner Organizations" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Interested in working with community organizations, clinics and health systems, public health programs, other community leaders and/or policy makers to advance health for all, with emphasis on addressing health inequities and disparities.</p>
                    </div>
                </div>

                <!-- Companies -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbCompainesandEntrepreuners" runat="server"
                        Text="Companies and Entrepreneurs" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Interested in opportunities vetted by UCSF Health Hub to advise, conduct industry-sponsored research, and/or co-develop products with growth-stage companies. <strong>Note:</strong> UCSF Health Hub offers a private, curated match-making service exclusively for UCSF. To get started, <a href="https://www.healthhubsf.org/apply" target="_blank" rel="noopener">click here to apply</a>.</p>
                    </div>
                </div>

                <!-- Policy -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbPolicyChange" runat="server"
                        Text="Policy Change" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Interested in working with policymakers to translate evidence into policy. <a href="https://ctsi.ucsf.edu/about-us/programs/impact" target="_blank" rel="noopener">IMPACT</a></p>
                    </div>
                </div>

                <!-- Press -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbPress" runat="server"
                        Text="Press" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Interested in working with University Relations to identify opportunities for publicity around my work or to serve as a topic area expert for media. Please add any press experience and scope of your interests (e.g. commercialization or ethics) to your collaborative narrative.</p>
                    </div>
                </div>

                <!-- Donors -->
                <div class="researcherprofiles--collaborationinterests-edit--option-row">
                    <asp:CheckBox ID="cbProspectiveDonors" runat="server"
                        Text="Prospective Donors" />
                    <div class="researcherprofiles--collaborationinterests-edit--desc">
                        <p>Willing to work with the UCSF Development Office to talk to potential donors about your research.</p>
                    </div>
                </div>

            </div>

            <h3>Narrative (optional)</h3>

            <asp:TextBox ID="txtNarrative" runat="server" TextMode="MultiLine" Rows="4" CssClass="researcherprofiles--collaborationinterests-edit--textarea"></asp:TextBox>

            <div class="researcherprofiles--collaborationinterests-edit--actions">

                <asp:LinkButton ID="btnSaveCollaborationInterests" runat="server" Text="Save" CssClass="researcherprofiles--collaborationinterests-edit--btn researcherprofiles--collaborationinterests-edit--btn-save" OnClick="btnSave_OnClick" TabIndex="11" />

                <asp:LinkButton ID="btnCancelCollaborationInterests" runat="server" Text="Cancel" CssClass="researcherprofiles--collaborationinterests-edit--btn researcherprofiles--collaborationinterests-edit--btn-cancel" OnClick="btnCancel_OnClick" TabIndex="12" />

                <asp:LinkButton ID="btnDeleteCollaborationInterests" runat="server" Text="Delete" CssClass="researcherprofiles--collaborationinterests-edit--btn researcherprofiles--collaborationinterests-edit--btn-delete" OnClick="btnDelete_OnClick" TabIndex="13" />

            </div>

        </section>

    </ContentTemplate>
</asp:UpdatePanel>