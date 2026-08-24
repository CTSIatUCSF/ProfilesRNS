﻿<%@ Control Language="C#" AutoEventWireup="true" 
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

            <p class="researcherprofiles--ucsdfacultymentoring-edit--intro">
	            <h3>Add Faculty Mentoring to Your Profile</h3>
	
		        <!-- Add details about your availability to mentor. -->
		        <a href="https://medschool.ucsd.edu/vchs/faculty-academics/faculty-affairs/faculty-development/Pages/Faculty-Mentor-Training-Program-.aspx" target="_blank">Learn about Mentoring at UCSD</a> 
			
    			Be sure to <b>SAVE</b> your work below.</span>
		
		    <div class="updated" style="float:right; display:block; text-align:left; padding-right:10px; font-size: 10px;">
			    Last Updated: <span id="last_updated" style="font-size: 10px;"></span>
		    </div>

            <p class="researcherprofiles--ucsdfacultymentoring-edit--last-updated">
                Last Updated: <asp:Literal ID="litLastUpdated" runat="server" />
            </p>
        </div>

        <section class="researcherprofiles--ucsdfacultymentoring-edit--section">
            <div class="researcherprofiles--ucsdfacultymentoring-edit--available-group">

                <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                    <strong>Available to Mentor:</strong> (check all that apply)
                </p>

                <!-- Junior Faculty -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbJuniorFaculty" runat="server" OnCheckedChanged="itmChanged"
                        Text="Junior Faculty" />
                </div>

                <!-- Medical Fellows -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbMedicalFellows" runat="server" OnCheckedChanged="itmChanged"
                        Text="Medical Fellows" />
                </div>

                <!-- Postdoctoral Trainees -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbPostdoctoralTrainees" runat="server" OnCheckedChanged="itmChanged"
                        Text="Postdoctoral Trainees" />
                </div>

                <!-- Graduate Students -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbGraduateStudents" runat="server" OnCheckedChanged="itmChanged"
                        Text="Graduate Students" />
                </div>

                <!-- Medical and Pharmacy Students -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbMecicalAndPharmacyStudents" runat="server" OnCheckedChanged="itmChanged"
                        Text="Medical and Pharmacy Students" />
                </div>

                <!-- Undergraduate Students -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbUndergraduateStudents" runat="server" OnCheckedChanged="itmChanged"
                        Text="Undergraduate Students" />
                </div>
            </div>

            <div class="researcherprofiles--ucsdfacultymentoring-edit--contact-group">
                <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                    <strong>My Contact Preference:</strong> 
                </p>
                <!-- email -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbEmail" runat="server" OnCheckedChanged="itmChanged"
                        Text="Email" />
                </div>

                <!-- phone -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbPhone" runat="server" OnCheckedChanged="itmChanged"
                        Text="Phone" />
                </div>

                <!-- Assistant -->
                <div class="researcherprofiles--ucsdfacultymentoring-edit--option-row">
                    <asp:CheckBox ID="cbAssistant" runat="server" OnCheckedChanged="itmChanged"
                        Text="Assistant" />

                    <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                        Assistant Details (if Assitant selected above) 
                    </p>
                    Name: <asp:TextBox ID="txtAssistantName" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--textarea"></asp:TextBox>
                    Email: <asp:TextBox ID="txtAssistantEmail" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--textarea"></asp:TextBox>
                    Phone: <asp:TextBox ID="txtAssistantPhone" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--textarea"></asp:TextBox>
                </div>

            </div>

            <div class="researcherprofiles--ucsdfacultymentoring-edit--contact-group">
                <p class="researcherprofiles--ucsdfacultymentoring-edit--subhead">
                    <strong>Mentoring Narrative:</strong> 
                </p>
                <asp:TextBox ID="txtNarrative" runat="server" TextMode="MultiLine" Rows="4" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucsdfacultymentoring-edit--textarea"></asp:TextBox>
            </div>


            <div class="researcherprofiles--ucsdfacultymentoring-edit--actions">

                <asp:LinkButton ID="btnSaveUCSDFacultMentoring" runat="server" Text="Save" CssClass="researcherprofiles--ucsdfacultymentoring-edit--btn researcherprofiles--ucsdfacultymentoring-edit--btn-save" OnClick="btnSave_OnClick" TabIndex="11" />

                <asp:LinkButton ID="btnCancelUCSDFacultMentoring" runat="server" Text="Cancel" CssClass="researcherprofiles--ucsdfacultymentoring-edit--btn researcherprofiles--ucsdfacultymentoring-edit--btn-cancel" OnClick="btnCancel_OnClick" TabIndex="12" />

                <asp:LinkButton ID="btnDeleteUCSDFacultMentoring" runat="server" Text="Delete" CssClass="researcherprofiles--ucsdfacultymentoring-edit--btn researcherprofiles--ucsdfacultymentoring-edit--btn-delete" OnClick="btnDelete_OnClick" TabIndex="13" />

            </div>
            <div class="editBody" style="text-align: left;" id="divMessage" runat="server">
                <i>
                <asp:Label runat="server" ID="lblMessage" ></asp:Label>
                </i>
            </div>
        </section>

    </ContentTemplate>
</asp:UpdatePanel>