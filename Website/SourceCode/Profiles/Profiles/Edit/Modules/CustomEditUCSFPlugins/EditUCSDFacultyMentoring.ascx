<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="EditCollaborationInterests.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.EditUCSDFacultyMentoring" %>
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

<asp:UpdatePanel ID="upnlEditUCSDFacultyMentoring" runat="server" class="EditPanel researcherprofiles--ucsdfacultymentoring-edit--container" UpdateMode="Conditional">
    <ContentTemplate>

        <div class="researcherprofiles--ucsdfacultymentoring-edit--header">
            <h2 class="researcherprofiles--ucsdfacultymentoring-edit--heading">
                Faculty Mentoring
            </h2>

            <div class="researcherprofiles--ucsdfacultymentoring-edit--intro">
                <h3>Add Faculty Mentoring to Your Profile</h3>
                <a href="https://medschool.ucsd.edu/vchs/faculty-academics/faculty-affairs/faculty-development/Pages/Faculty-Mentor-Training-Program-.aspx" target="_blank">Learn about Mentoring at UCSD</a>
                — Be sure to <b>save</b> your work.
            </div>
        </div>

        <section class="researcherprofiles--ucsdfacultymentoring-edit--section">
            <div class="researcherprofiles--ucsdfacultymentoring-edit--available-group">

                <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                    <strong>Available to Mentor</strong> (check all that apply)
                </p>

                <div class="researcherprofiles--ucsdfacultymentoring-edit--checkbox-group">
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbJuniorFaculty" runat="server" OnCheckedChanged="itmChanged"
                            Text="Junior Faculty" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbMedicalFellows" runat="server" OnCheckedChanged="itmChanged"
                            Text="Medical Fellows" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbPostdoctoralTrainees" runat="server" OnCheckedChanged="itmChanged"
                            Text="Postdoctoral Trainees" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbGraduateStudents" runat="server" OnCheckedChanged="itmChanged"
                            Text="Graduate Students" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbMecicalAndPharmacyStudents" runat="server" OnCheckedChanged="itmChanged"
                            Text="Medical and Pharmacy Students" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbUndergraduateStudents" runat="server" OnCheckedChanged="itmChanged"
                            Text="Undergraduate Students" />
                    </div>
                </div>
            </div>

            <div class="researcherprofiles--ucsdfacultymentoring-edit--contact-group">
                <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                    <strong>How to contact me</strong> (check all that apply)
                </p>

                <div class="researcherprofiles--ucsdfacultymentoring-edit--checkbox-group">
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbEmail" runat="server" OnCheckedChanged="itmChanged"
                            Text="Email" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbPhone" runat="server" OnCheckedChanged="itmChanged"
                            Text="Phone" />
                    </div>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                        <asp:CheckBox ID="cbAssistant" runat="server" OnCheckedChanged="itmChanged"
                            Text="Via my assistant"
                            aria-expanded="false"
                            aria-controls="assistantFields" />
                        <span class="researcherprofiles--ucsdfacultymentoring-edit--option-hint">— check to add their contact details</span>
                    </div>
                </div>

                <div class="researcherprofiles--ucsdfacultymentoring-edit--assistant-fields" id="assistantFields">
                    <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                        Assistant contact details
                    </p>
                    <div class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field-row">
                        <label class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field">
                            <span class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field-label">Name</span>
                            <asp:TextBox ID="txtAssistantName" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--text-input"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field">
                            <span class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field-label">Email</span>
                            <asp:TextBox ID="txtAssistantEmail" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--text-input"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field">
                            <span class="researcherprofiles--ucsdfacultymentoring-edit--assistant-field-label">Phone</span>
                            <asp:TextBox ID="txtAssistantPhone" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--text-input"></asp:TextBox>
                        </label>
                    </div>
                </div>
            </div>

            <div class="researcherprofiles--ucsdfacultymentoring-edit--narrative-group">
                <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                    <strong>Mentoring Narrative</strong> <span class="researcherprofiles--ucsdfacultymentoring-edit--optional">(optional)</span>
                </p>
                <asp:TextBox ID="txtNarrative" runat="server" TextMode="MultiLine" Rows="4" OnTextChanged="itmChanged"
                    CssClass="researcherprofiles--ucsdfacultymentoring-edit--textarea"
                    placeholder="Describe your mentoring philosophy, areas of expertise, and what you are looking for in a mentee."></asp:TextBox>
            </div>

            <div class="researcherprofiles--ucsdfacultymentoring-edit--actions">
                <asp:LinkButton ID="btnSaveUCSDFacultMentoring" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_OnClick" TabIndex="11" />
                <asp:LinkButton ID="btnCancelUCSDFacultMentoring" runat="server" Text="Cancel" CssClass="btn btn-default" OnClick="btnCancel_OnClick" TabIndex="12" />
                <asp:LinkButton ID="btnDeleteUCSDFacultMentoring" runat="server" Text="Delete" CssClass="btn btn-danger" OnClick="btnDelete_OnClick" TabIndex="13" />
                <p class="researcherprofiles--ucsdfacultymentoring-edit--last-updated">
                    Last Updated: <asp:Literal ID="litLastUpdated" runat="server" />
                </p>
            </div>

            <div class="editBody researcherprofiles--ucsdfacultymentoring-edit--message" id="divMessage" runat="server"
                 role="status" aria-live="polite" aria-atomic="true">
                <asp:Label runat="server" ID="lblMessage"></asp:Label>
            </div>
        </section>

        <script type="text/javascript">
            (function () {
                function syncAssistantFields() {
                    var cb = document.getElementById('<%= cbAssistant.ClientID %>');
                    var fields = document.getElementById('assistantFields');
                    if (cb && fields) {
                        var open = cb.checked;
                        fields.style.display = open ? '' : 'none';
                        cb.setAttribute('aria-expanded', open ? 'true' : 'false');
                        cb.onchange = syncAssistantFields;
                    }
                }
                // default.aspx calls window.EndRequestHandler directly after each UpdatePanel postback
                window.EndRequestHandler = syncAssistantFields;
                // Sys.Application.add_load also covers initial page load and async refreshes
                if (typeof Sys !== 'undefined') {
                    Sys.Application.add_load(syncAssistantFields);
                } else {
                    document.addEventListener('DOMContentLoaded', syncAssistantFields);
                }
            })();
        </script>

    </ContentTemplate>
</asp:UpdatePanel>
