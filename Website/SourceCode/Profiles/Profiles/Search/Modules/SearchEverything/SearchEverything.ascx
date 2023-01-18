<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SearchEverything.ascx.cs"
    Inherits="Profiles.Search.Modules.SearchEverything.SearchEverything" %>

<script type="text/javascript">

    function submitEverythingSearch() {

        document.location = "default.aspx?searchtype=everything&searchfor=" + document.getElementById("<%=searchfor.ClientID%>").value + "&exactphrase=" + document.getElementById("<%=chkExactPhrase.ClientID%>").checked +
        "&ClassGroupURI=http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupConcepts"; //UCSF added to jump straight to concepts
    }
    function runScript(e) {
        $(document).keypress(function(e) {
            if (e.keyCode == 13) {
                submitEverythingSearch();
                return false;
            }
            return;
        });
    }
</script>

<input type="hidden" id="classgroupuri" name="classgroupuri" value="" />
<input type="hidden" id="classuri" name="classuri" value="" />
<input type="hidden" id="searchtype" name="searchtype" value="everything" />
<input type="hidden" id="txtSearchFor" name="txtSearchFor" value="" />
<div class="content_container">
    <div class="tabContainer" style="margin-top: 0px;">
        <div class="searchForm nonavbar">
            <table width="100%">
                <tr>
                    <td colspan='3'>
                        <div class="header">
                            Find Research Publications by Topic
                        </div>
                    </td>
                </tr>
                <div>
                    <td colspan="3">
                        <div class="searchSection">
                            <fieldset class='searchForm' onkeypress="JavaScript:runScript(event);">
                                <legend>Topic</legend>
                                <div class="researcherprofiles--primary-search--search-form--topic-search-container">
                                        <asp:TextBox EnableViewState="false" runat="server" ID="searchfor" CssClass="inputText" title="Topic" placeholder="e.g. HIV" />
                                        <label><asp:CheckBox runat="server" ID="chkExactPhrase" text="&nbsp;Use exact phrase"/></label>
                                </div>
                                <div class="search-button-container">
                                    <a href="JavaScript:submitEverythingSearch();" class="search-button">
                                        Search
                                    </a>
                                </div>
                            </fieldset>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>
