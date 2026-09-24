<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UCDStudentProjects.ascx.cs"
    Inherits="Profiles.Profile.Modules.CustomViewUCSFPlugins.UCDStudentProjects" %>
<asp:Literal runat="server" ID="litjs"></asp:Literal>

<section class="researcherprofiles--ucdstudentprojects">

  <div class="researcherprofiles--ucdstudentprojects--types-section" style="display:none">
    <p class="researcherprofiles--ucdstudentprojects--section-label">Types of Research</p>
    <ul class="researcherprofiles--ucdstudentprojects--typesofresearch"></ul>
  </div>

  <div class="researcherprofiles--ucdstudentprojects--projects-section" style="display:none">
    <p class="researcherprofiles--ucdstudentprojects--section-label">Student Projects</p>
    <ul class="researcherprofiles--ucdstudentprojects--studentprojects"></ul>
  </div>

  <p class="researcherprofiles--ucdstudentprojects--last-updated" style="display:none"></p>

</section>
