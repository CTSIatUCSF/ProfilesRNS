<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UCSDFacultyMentoring.ascx.cs"
    Inherits="Profiles.Profile.Modules.CustomViewUCSFPlugins.UCSDFacultyMentoring" %>
<asp:Literal runat="server" ID="litjs"></asp:Literal>

<section class="researcherprofiles--ucsdfacultymentoring">

  <div class="researcherprofiles--ucsdfacultymentoring--narrative" style="display:none"></div>

  <div class="researcherprofiles--ucsdfacultymentoring--available-section" style="display:none">
    <p class="researcherprofiles--ucsdfacultymentoring--section-label">Available to Mentor</p>
    <ul class="researcherprofiles--ucsdfacultymentoring--availabletomentor"></ul>
  </div>

  <div class="researcherprofiles--ucsdfacultymentoring--contact-section" style="display:none">
    <p class="researcherprofiles--ucsdfacultymentoring--section-label">How to Contact</p>
    <ul class="researcherprofiles--ucsdfacultymentoring--contactformentoring"></ul>
  </div>

  <p class="researcherprofiles--ucsdfacultymentoring--last-updated" style="display:none"></p>

</section>
