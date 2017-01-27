<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Statistics.ascx.cs"
    Inherits="Profiles.Activity.Modules.Statistics.Statistics" %>
<div class="metrics">
    <div class="act-heading"><strong>Profiles Metrics</strong></div>
<div>
<span><asp:Literal runat="server" ID="publicationsCount"/></span> Publications<br/>
<span><asp:Literal runat="server" ID="totalProfilesCount"/></span> Total Profiles<br/>
<span><asp:Literal runat="server" ID="editedProfilesCount"/></span> Edited Profiles<br/>
</div>
</div>
