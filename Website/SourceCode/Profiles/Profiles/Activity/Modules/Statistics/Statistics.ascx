<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Statistics.ascx.cs"
    Inherits="Profiles.Activity.Modules.Statistics.Statistics" %>
<div class="metrics">
    <div class="act-heading"><strong><asp:Label runat="server" SkinID="Acronym" /> Profiles Metrics</strong></div>
<div class="metricsDetails">
<span><asp:Literal runat="server" ID="publicationsCount"/></span> Publications<br/>
<span><asp:Literal runat="server" ID="totalProfilesCount"/></span> Total Profiles<br/>
<span><asp:Literal runat="server" ID="editedProfilesCount"/></span> Edited Profiles<br/>
</div>
</div>
