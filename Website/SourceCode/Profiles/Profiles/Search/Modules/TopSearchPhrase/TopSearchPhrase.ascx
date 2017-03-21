﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TopSearchPhrase.ascx.cs"
    Inherits="Profiles.Search.Modules.TopSearchPhrase.TopSearchPhrase" %>

<script type="text/javascript">

    function searchThisPhrase(keyword,classuri,searchtype) {        
        document.location.href = '<%=GetURLDomain()%>/search/default.aspx?searchtype=' + searchtype + '&searchfor=' + keyword + '&exactphrase=false&classuri=' + classuri;
    }    
    
</script>

<div class="passiveSectionHead">
    <asp:Literal runat="server" ID="litDescription"></asp:Literal>
</div>
<div class="passiveSectionBody topSearchPhrases">
    <asp:Literal runat="server" ID="litTopSearchPhrase"></asp:Literal>
    <div class="passiveSectionLine">
    </div>
</div>

<asp:Panel ID="TwitterUSC" runat="server" SkinID="USC" Visible="false">
<div class="tour"><a href="<%=GetURLDomain()%>/about/AboutProfiles.aspx" class="dblarrow">Tour Profiles </a></div>

<p style="margin: 0; padding: 20px 0 6px"><strong>USC Profiles Updates</strong></p>
<div style="margin: 0 20px 0 -6px;">
<a class="twitter-timeline"  href="https://twitter.com/USCProfiles"  data-widget-id="407943177664860160" data-chrome="nofooter noborders noheader" data-tweet-limit="1" data-link-color="#4D8BA9">Updates by @USCProfiles</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
</div>
<p style="margin: 0;">
<a href="https://twitter.com/USCProfiles" class="twitter-follow-button" data-show-count="false">Follow @USCProfiles</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
</p>
</asp:Panel>