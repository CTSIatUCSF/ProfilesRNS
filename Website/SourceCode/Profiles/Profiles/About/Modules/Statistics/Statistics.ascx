<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Statistics.ascx.cs"
    Inherits="Profiles.About.Modules.Statistics.Statistics" %>
<div class="metrics" style="line-height:21px;padding-left:12px">
<strong>Profiles Metrics</strong><br />
</div>
<div>
<asp:Literal runat="server" ID="publicationsCount"/> Publications<br/>
<asp:Literal runat="server" ID="totalProfilesCount"/> Total Profiles<br/>
<asp:Literal runat="server" ID="editedProfilesCount"/> Edited Profiels<br/>
</div>
