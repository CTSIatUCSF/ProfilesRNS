<%@ Control Language="C#" AutoEventWireup="True" CodeBehind="CustomViewAuthorInAuthorship.ascx.cs" Inherits="Profiles.Profile.Modules.CustomViewAuthorInAuthorship" %>


<div class='publicationList'>	
	<div style="font-weight:bold;color:#888;margin-bottom: 12px;margin-top:6px">
		Publications listed below are automatically derived from MEDLINE/PubMed and other sources, which might result in incorrect or missing publications. 
		Researchers can <asp:Literal runat='server' ID='loginLiteral'></asp:Literal> to make corrections and additions, or <asp:Hyperlink ID="Contact" SkinID="contact" runat="server" />.  
	</div>
	<div class="anchor-tab">
		<a class='selected' tabindex="0">List All</a> 
		&nbsp; | &nbsp; 
		<a tabindex="0">Timeline</a>
	</div>
	<div class='toggle-vis' style='display:none;margin-top: 6px;'>		
		Publications by year:
		<div id="publicationTimelineGraph">
			<a id="divShowTimelineTable" tabindex="0">View visualization as text</a><br />
			<img id='timelineBar' runat='server' border='0' width='595' height='100'/>
		</div>
	</div>	

	<asp:Repeater ID="rpPublication" runat="server" OnItemDataBound="rpPublication_OnDataBound">
		<HeaderTemplate>			
			<div id="publicationListAll" class="publications toggle-vis">
				<ol>
		</HeaderTemplate>
		<ItemTemplate>			
				<li runat="server" id="liPublication">
					<div>
						<asp:Label runat="server" ID="lblPublication"></asp:Label>
					</div>
					<div class="viewIn">
						<asp:Literal runat="server" ID="litViewIn"></asp:Literal>
					</div>
				</li>
		</ItemTemplate>
		<FooterTemplate>
				</ol>	
			</div>				
		</FooterTemplate>
	</asp:Repeater>
	
            <!--cp  <div style="text-align:left">To see the data from this visualization as text, <a id="divShowTimelineTable" tabindex="0">click here.</a></div> -->
		</div>

        <div id="divTimelineTable" class="listTable" style="display:none;margin-top:12px;margin-bottom:8px;">
		    <a id="dirReturnToTimeline" tabindex="0">View timeline visualization</a><br />
		    <asp:Literal runat="server" ID="litTimelineTable"></asp:Literal>
            <!--cp  To return to the timeline, <a id="dirReturnToTimeline" tabindex="0">click here.</a> -->
             
</div>

<div class="SupportText">
	<asp:Literal runat='server' ID='supportText'></asp:Literal>
</div>

<script type="text/javascript">
    $(function () {
        $("div.publicationList li:first").attr("class", "first");

        $(".publicationList .anchor-tab a").bind("click", function () {
            var $this = $(this);
            if ($this.get(0).className != "selected") {
                // Toggle link classes
                $this.toggleClass("selected").siblings("a").toggleClass("selected");
                // Show hide;
                $("div.publicationList .toggle-vis:visible").hide().siblings().fadeIn("fast");
            }
        });

        $(".publicationList .anchor-tab a").bind("keypress", function (e) {
            if (e.keyCode == 13) {
                var $this = $(this);
                if ($this.get(0).className != "selected") {
                    // Toggle link classes
                    $this.toggleClass("selected").siblings("a").toggleClass("selected");
                    // Show hide;
                    $("div.publicationList .toggle-vis:visible").hide().siblings().fadeIn("fast");
                }
            }
        });
    });

    $(function () {
        $("#divShowTimelineTable").bind("click", function () {

            $("#divTimelineTable").show();
            $("#publicationTimelineGraph").hide();
        });

        jQuery("#divShowTimelineTable").bind("keypress", function (e) {
            if (e.keyCode == 13) {
                $("#divTimelineTable").show();
                $("#publicationTimelineGraph").hide();
            }
        });
    });

    $(function () {
        $("#dirReturnToTimeline").bind("click", function () {

            $("#divTimelineTable").hide();
            $("#publicationTimelineGraph").show();
        });

        jQuery("#dirReturnToTimeline").bind("keypress", function (e) {
            if (e.keyCode == 13) {
                $("#divTimelineTable").hide();
                $("#publicationTimelineGraph").show();
            }
        });
    });

</script>