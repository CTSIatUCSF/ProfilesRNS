<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditUCSFFeaturedVideos.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.UCSFFeaturedVideos" %>
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

<asp:HiddenField runat="server" ID="hdnYouTubeId" />

<div class="editBackLink">
    <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
</div>

<asp:Panel ID="phSecuritySettings" runat="server">
    <security:Options runat="server" ID="securityOptions"></security:Options>
</asp:Panel>

<p class="text-left">Supported video services include YouTube and Vimeo.
For questions about this section please <a href="mailto:profiles@ucsf.edu">contact us</a>.</p>

<asp:Panel runat="server" ID="pnlAddEdit">
    <div class="EditMenuItem">
        <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
        <asp:LinkButton ID="btnAddEditEdit" runat="server" OnClick="btnAddEdit_OnClick">Add a video</asp:LinkButton>
    </div>
</asp:Panel>
<asp:Panel ID="pnlImportVideo" runat="server" CssClass="EditPanel" Visible="false">
    <div style="margin-bottom: 10px;">
        Display videos from YouTube and Vimeo in a playlist on your profile. If you do not see a preview here after pasting in a link, that video service is currently not supported.
    </div>
    <div style="padding-top: 3px;">
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Description</b></div>
            <asp:TextBox Width="400px" runat="server" MaxLength="100" ID="txtName"></asp:TextBox>
        </div>
        <div style="margin-bottom: 5px;">
            <div style="margin-bottom: 4px"><b>Video URL</b></div>
            <asp:TextBox Width="400px" runat="server" ID="txtURL"></asp:TextBox>
        </div>
        <div class="actionbuttons">
            <asp:LinkButton ID="btnSaveAndClose" runat="server" CausesValidation="False"
                OnClick="btnSaveAndClose_OnClick" Text="Save" TabIndex="11" />
            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                    Text="Cancel" TabIndex="7" />
        </div>
    </div>
</asp:Panel>
<div class="editPage">
    <asp:GridView ID="GridViewVideos" runat="server" AutoGenerateColumns="False"
        DataKeyNames="name, url" GridLines="Both"
        OnRowCancelingEdit="GridViewVideos_RowCancelingEdit" OnRowDataBound="GridViewVideos_RowDataBound"
        OnRowDeleting="GridViewVideos_RowDeleting" OnRowEditing="GridViewVideos_RowEditing"
        OnRowUpdating="GridViewVideos_RowUpdating" OnRowUpdated="GridViewVideos_RowUpdated"
        CssClass="editBody">
        <HeaderStyle CssClass="topRow" />
        <Columns>
            <asp:TemplateField HeaderText="Description" ItemStyle-CssClass="alignLeft" HeaderStyle-CssClass="alignLeft">
                <EditItemTemplate>
                    <asp:TextBox ID="txtVideoDescription" runat="server" MaxLength="400" Width="450px" Text='<%# Bind("Name") %>' />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="Label5" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Preview" HeaderStyle-CssClass="alignCenter" ItemStyle-CssClass="alignCenter">
                <ItemTemplate>
                    <asp:Image ID="videoThumbnail" runat="server" Height=75 Width=125 AlternateText='<%# Bind("Url") %>' ImageUrl="~/ORNG/Images/waiting.gif" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-CssClass="alignCenterAction" HeaderText="Action" ItemStyle-CssClass="alignCenterAction">
                <EditItemTemplate>
                    <asp:LinkButton ID="lnkUpdate" runat="server"
                        CausesValidation="True" CommandName="Update" Text="Save" />
                    &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp
                                <asp:LinkButton ID="lnkCancel" runat="server" CausesValidation="False" CommandName="Cancel" Text="Cancel" />
                </EditItemTemplate>
                <ItemTemplate>
                    <span>
                        <asp:ImageButton OnClick="ibUp_Click" runat="server" CommandArgument="up" CommandName="action"
                            ID="ibUp" ImageUrl="~/Edit/Images/icon_up.gif" AlternateText="Move Up" />
                        <asp:ImageButton runat="server" ID="ibUpGray" Enabled="false" Visible="false" ImageUrl="~/Edit/Images/Icon_rounded_ArrowGrayUp.png" AlternateText="Move Up" />
                    </span>
                    <span>
                        <asp:ImageButton runat="server" OnClick="ibDown_Click" ID="ibDown" CommandArgument="down"
                            CommandName="action" ImageUrl="~/Edit/Images/icon_down.gif" AlternateText="Move Down" />
                        <asp:ImageButton runat="server" ID="ibDownGray" Enabled="false" Visible="false" ImageUrl="~/Edit/Images/Icon_rounded_ArrowGrayDown.png" AlternateText="Move Down" />
                    </span>
                    <span>
                        <asp:ImageButton ID="lnkEdit" runat="server" ImageUrl="~/Edit/Images/icon_edit.gif"
                            CausesValidation="False" CommandName="Edit" AlternateText="Edit"></asp:ImageButton>
                    </span>
                    <span>
                        <asp:ImageButton ID="lnkDelete" runat="server" ImageUrl="~/Edit/Images/icon_delete.gif"
                            CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this entry?');"
                            AlternateText="Delete"></asp:ImageButton>
                    </span>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <div class="editBody" style="text-align: left;" id="divNoVideos" runat="server">
        <i></i>
        <asp:Label runat="server" ID="lblNoVideos" Text="No videos have been added to your playlist."></asp:Label>
    </div>
</div>

<script>
    $("#<%=txtURL.ClientID%>").on("focusout", function () {
        // new stuff
        var s = $("#<%=txtURL.ClientID%>").val();
        var id = FeaturedVideos.getVideoIdFromYouTubeUrl(s);
        $("#<%=hdnYouTubeId.ClientID%>").val(id);
    });

    function addThumbnailToImage(clientId) {
        // weird .net thing where it sometimes gets out of synch, but putting the URL in the image object fixes it 
        FeaturedVideos.getVideoMetadata($("#" + clientId).attr("alt"), 75, 125, function (video_data) {
            if (video_data.thumbnail_url) {
                $("#" + clientId).attr("src", video_data.thumbnail_url);                
            }
            else if (video_data.provider_url) {
                $("#" + clientId).attr("src", "https://s2.googleusercontent.com/s2/favicons?domain_url=" + encodeURIComponent(video_data.provider_url));                
            }
        });
    };
</script>
