<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UCSFFeaturedVideos.ascx.cs" EnableTheming="true"
    Inherits="Profiles.Profile.Modules.CustomViewUCSFPlugins.UCSFFeaturedVideos" %>

<script id="video-block-template" type="text/x-handlebars-template">
    <div class="video_option">
        <figure role="group">
            <div class="video_thumbnail_wrapper">
                {{#if thumbnail_url}}<img src="{{thumbnail_url}}" alt="">{{/if}}
            </div>
            <figcaption><a href="{{url}}">{{title}}</a></figcaption>
        </figure>
    </div>
</script>

<div id="videos">
    <div id="video_navigator"></div>
    <div id="current_video_container"></div>
</div> 

<asp:Literal runat="server" ID="litjs" />










