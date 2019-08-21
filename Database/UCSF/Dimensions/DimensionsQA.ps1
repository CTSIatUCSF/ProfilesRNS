Function NewPersonObject(){
    $checkListPMID=@{"pmids"=@();}
    $personData = New-Object -TypeName PSObject -Property $checkListPMID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimensionsID -Value $curID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name Dimpersonid -Value ""
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name pfirstname -Value ""
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name plastname -Value ""
    return $personData
}

Function GetPersons ( [System.Data.SqlClient.SqlConnection] $sqlConnection,  $qaPersons){
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection

    $personData=NewPersonObject
    
    $curID=""
    $DBpersons=@()

    $sqlCommand.CommandText =
        "SELECT SourceAuthorID,p.personid,p.firstname,p.lastname, "+
	    "    cast(inc.pmid  as varchar(10)) as pmid  "+
        "FROM [Profile.Data].[Publication.Person.Include] inc "+ 
        "join [Profile.Data].[Person] p on inc.personid =p.personid "+ 
        "left join [UCSF.].[ExternalID] ExtID  "+
	    "    on ExtID.personID=p.personID  "+
        "left outer join [Profile.Data].[Publication.Person.Exclude] exc "+ 
	    "    on	cast(inc.personid as varchar)+cast(inc.pmid  as varchar(10)) = "+ 
		"    cast(exc.personid as varchar)+cast(exc.pmid  as varchar(10))  "+
        " where exc.pmid is NULL   "+
	    "   and inc.pmid is not NULL and inc.pmid>0 "+ 
        "   and p.personid in (" +$qaPersons+" )"+
		"   and PublicationSource='Dimensions' "+
		"   order by p.personid "

    $sqlcommand.CommandTimeout=120
    #$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    #$sqlCommand.Parameters[0].Value = $readLimit.lastIUN
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $dimid=$reader[“SourceAuthorID”]
            $readpmid=$reader["pmid"]
            $IUN=$reader["personid"]
            $firstname=$reader["firstname"]
            $lastname=$reader["lastname"]

            if ($DEBUG -eq 1){write-host "curent id="$curID "newID="$dimid "newpmid="$readpmid "new personid="$IUN}
            if ($DEBUG -eq 1){write-host "DBpersons="$DBpersons}
            if ($DEBUG -eq 1){write-host "personData="$personData}
            if ($dimid -eq $curID ){
                $personData.pmids += $readpmid
                    continue
            } else {
                if ($curID.Length -gt 0)  {  
                    $DBpersons += $personData 
                    $readLimit.lastIUN=$personData.dimpersonid
                }
                $personData=NewPersonObject
                $personData.DimensionsID=$dimid
                $curID=$dimid
                $personData.pmids +=$readpmid
                $personData.Dimpersonid=$IUN
                $personData.pfirstname=$firstname
                $personData.plastname=$lastname
            }
        }
        $DBpersons += $personData
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
   
    return $DBpersons
}    

Function GetAuthors ($jsonPub) {
  $wklist=@()
  $returnValue = New-Object -TypeName PSObject
  Add-Member -InputObject $returnValue -MemberType NoteProperty `
        -Name ids -Value $wklist
 
  foreach ($affiliationLine in $jsonPub.researchers) {
    foreach($author in  $affiliationLine){
        $order++
        $returnValue.ids +=$author.id
    }
  }
  #if ($DEBUG -eq 1){write-host $returnValue}
  return $returnValue
}




function SaveStatistic ($sqlConnection,$personid,$lostNum,$notNum){
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = " INSERT INTO [UCSF.].[ExternalStatistic] "+
                              " VALUES (@ActualSourceType,@personid,@lostNum,@notNum) "
  
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ActualSourceType",[Data.SQLDBType]::varChar, 20))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@personid",[Data.SQLDBType]::Integer))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lostNUM",[Data.SQLDBType]::Integer))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@notNum",[Data.SQLDBType]::Integer))) | Out-Null

    
    $sqlCommand.Parameters[0].Value = "Dimensions"
    $sqlCommand.Parameters[1].Value = $personid
    $sqlCommand.Parameters[2].Value = $lostNum
    $sqlCommand.Parameters[3].Value = $notNum
    try{    
        $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing write Statistic " $personid "," $lostNum "," $notNum
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        if ($DEBUG -eq 1){write-host `n"URL"$url}
        if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }

}


if ($DEBUG -eq 1){write-host "count=" $args.count "arguments=" $args}
if ($args.count -eq 0) {
    write-host "Need file with names/passwords"
    exit
}
$params=$args[0..($args.count-1)]
if ($DEBUG -eq 1){write-host "params="$params}

# Take settings from config file
#if ($PWD) {$myDir=$PWD}
if ($MyInvocation) {
    $myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$hh=get-date -f MMddyyyy_HHmm
$templateReport="$myDir\QA_Template.xlsx"
$newReport=$templateReport.Replace("Template",$hh)
Copy-Item -Path "$templateReport" -Destination "$newReport" -verbose

$ff=$params[0]
[xml]$ConfigFile = Get-Content "$MyDir\$ff"

$DBserver=$ConfigFile.Settings.Database.DBServer
$DBName=$ConfigFile.Settings.Database.DBName 
$dbuser=$ConfigFile.Settings.Database.DBUser 
$dbpassword=$ConfigFile.Settings.Database.DBPassword 
$wusername=$ConfigFile.Settings.WebService.WSUser
$wpassword=$ConfigFile.Settings.WebService.WSPassword 
$apiurl=$ConfigFile.Settings.WebService.URL
$qaPersonList=@()

if ($params.count -gt 1) {
   $filename=$params[1]
   $gg=$params[1]
   if ([System.IO.File]::Exists( "$MyDir\$gg")){
        $qaPersonList=Get-Content "$MyDir\$gg"
   }else {
        for ($h=1;$h -lt $params.count; $h++){$qaPersonList=$qaPersonList+$params[$h]}
   }
}else {
    write-host "There is no any list of persons ID to process QA"
    write-host "It could be text file with personID on each row,"
    write-host " or as parameters for script execution like "
    write-host " DimensionsQA_Prod.ps1 <Configuration XML> <person ID1> <person ID2> <person ID3> ..." 
    exit
} 


#$DEBUG=1
$baseForProfiles="https://profiles.ucsf.edu/"
$baseForIDF="http://dx.doi.org/"
$baseForDimensions="https://app.dimensions.ai/details/publication/"
$baseForPubMed="https://www.ncbi.nlm.nih.gov/pubmed/"

$body=(@{'username' = $wusername; 'password' = $wpassword} | ConvertTo-JSON)
$TOKEN_URI=$apiurl+"/auth.json"
$DSL_TOKEN = (Invoke-RestMethod -Uri $TOKEN_URI -Method Post -Body $body).token
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open() 
$needNextPerson=1
$lost_pmids=$null
$not_pmids=$null
$lost_pmids=@()
$not_pmids=@()
$dim_publications =@()
$needStatistic=1
$qaPersons=""
$QA_Results= @()
For ($j=0; $j -lt $qaPersonList.Length; $j++) {
    $qaPersons=$qaPersonList[$j]
    if ($needStatistic -eq 1){
        For ($i=0; $i -lt $dim_publications.Length; $i++) {
            $lostval=$lost_pmids[$i]
            $notval=$not_pmids[$i]
            $dimpub=$dim_publications[$i]
            $displayName=$newPersons.pfirstname.trimStart()+"."+$newPersons.plastname
            $row=[PSCustomObject]@{
                'Profile Name' = $displayName
                'PubMed IDs not in Harvard Disambiguation' = $lostval
                'Publications not listed in PubMed' = $notval
                'Publication in Dimensions' = $dimpub
            }
            $QA_Results+=$row
        }
    }
    $newPersons=$null
    $lost_pmids=@()
    $not_pmids=@()
    $dim_pmids=@()
    $dim_publications=@()       
    $newPersons=GetPersons $sqlConnection $qaPersons
    if ($newPersons.Equals($null)) {
        $needNextPerson=0
        continue
    }
    $skip=0
    $setlen=-1
    $totalcount=-1
    $dimsIDs=""
    foreach ($personLine in $newPersons){
        write-host "new personid "$personLine.DimpersonID
        if ($dimsIDs.Length -eq 0) {$dimsIDs='"'+$personLine.DimensionsID+'"'} 
        else {$dimsIDs=$dimsIDs+","+'"'+$personLine.DimensionsID+'"'}
    }
#$DEBUG=1
    while  (( -not $setlen -eq 0) -and ($totalcount-$skip -ne 0))  { #($setlen -ne 0) -and ($totalcount-$skip -ne 0)
        $searchRequest='search publications  where researchers.id in [ '+$dimsIDs +' ] '+' return publications[id+pmid+doi+researchers] limit 1000 skip '+ $skip
        $searchRequest
        $DATA_URI=$apiurl+"/dsl.json"
        $jsonResult=Invoke-RestMethod -Uri $DATA_URI -Method Post -H @{Authorization = "JWT $DSL_TOKEN"} -Body $searchRequest
        $pubAuthors=""
        $setlen=$jsonResult.publications.Length
        $totalcount=$jsonResult._stats.total_count
        write-host "setlen=" $setlen "total_count="$totalcount "_stat="$jsonResult._stats
        foreach($pub in $jsonResult.publications){
            $skip++
            $authorsList=GetAuthors $pub
            if ($DEBUG -eq 1){write-host "pmid="$pub.pmid}
            foreach ($personLine in $newPersons){
                if ($DEBUG -eq 1){write-host "checking id="$personLine.DimensionsID}
                if ($authorsList.ids.Contains($personLine.DimensionsID)){
                    if ([string]::IsNullOrEmpty($pub.pmid)) {
                        $not_pmids=$not_pmids+$pub.doi
                        $lost_pmids=$lost_pmids+""
                        $dim_publications=$dim_publications+$pub.id
                    }else{
                        $dim_pmids=$dim_pmids+$pub.pmid
                        if (-not $personLine.pmids.Contains($pub.pmid)){
                            $lost_pmids=$lost_pmids+$pub.pmid
                            $not_pmids=$not_pmids+""
                            $dim_publications=$dim_publications+$pub.id
                        }  
                    }
                    continue
                }
                continue
            }           
        }
    }
}
if ($needStatistic -eq 1){
    $nodim_pmids=@()
    if ($dim_pmids.Length -gt 0){
        foreach ($check_pmid in $personLine.pmids){
            if ( -not $dim_pmids.Contains($check_pmid)){
                $nodim_pmids =$nodim_pmids+$check_pmid
            }
        }
    }
    For ($i=0; $i -lt $dim_publications.Length; $i++) {
        $lostval=$lost_pmids[$i]
        $notval=$not_pmids[$i]
        $dimpub=$dim_publications[$i]
        $displayName=$newPersons.pfirstname.trimStart()+"."+$newPersons.plastname
        $row=[PSCustomObject]@{
            'Profile Name' = $displayName
            'PubMed IDs not in Harvard Disambiguation' = $lostval
            'Publications not listed in PubMed' = $notval
            'Publication in Dimensions' = $dimpub
         }
         $QA_Results+=$row
    }
}

$excelObj = New-Object -ComObject Excel.Application
$excelWB = $excelObj.workbooks.Open($newReport)              #Add()
$excelWS = $excelWB.WorkSheets.Item(1)
$ColumnNames=$QA_Results[0].PSObject.Properties|%{$_.name}
#Make main excel window visible
$excelObj.Visible = $true
#Add excel column title
$cIndex = 0; #Column index
$rows=$QA_Results.Length+1 #last row
$ColumnNames | %{$cIndex++;$excelWS.Cells.Item(1, $cIndex).Font.Bold=$true;$excelWS.Cells.Item(1, $cIndex)=$_}
$rIndex = 1;$QA_Results | %{$cIndex = 0;$rIndex++;$row=$_;$ColumnNames | %{$cIndex++;$excelWS.Cells.Item($rIndex, $cIndex+4) = "$($row.$($_))"}}
$excelWS.cells.Item(2,1).formula='=IF(E2="","",HYPERLINK(CONCATENATE("https://profiles.ucsf.edu/",E2),E2))'
$excelWS.cells.Item(2,2).formula='=IF(F2="","",HYPERLINK(CONCATENATE("https://www.ncbi.nlm.nih.gov/pubmed/",F2),F2))'
$excelWS.cells.Item(2,3).formula='=IF(G2="","",HYPERLINK(CONCATENATE("http://dx.doi.org/",G2),G2))'
$excelWS.cells.Item(2,4).formula='=IF(H2="","",HYPERLINK(CONCATENATE("https://app.dimensions.ai/details/publication/",H2),H2))'
$excelWS.range("A2:A$rows").formula=$excelWS.cells.Item(2,1).formula
$excelWS.range("B2:B$rows").formula=$excelWS.cells.Item(2,2).formula
$excelWS.range("C2:C$rows").formula=$excelWS.cells.Item(2,3).formula
$excelWS.range("D2:D$rows").formula=$excelWS.cells.Item(2,4).formula
#$excelWS.cells.Item(2,4).formula='=IF(H2="","",HYPERLINK(CONCATENATE("https://app.dimensions.ai/details/publication/",H2),H2))'

#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
$c = $excelws.Columns
$c.Item(5).hidden = $true
$c.Item(6).hidden = $true
$c.Item(7).hidden = $true
$c.Item(8).hidden = $true
$excelWB.Save()
Stop-Process -Name EXCEL -Force
#$Excel.Quit()
#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
#[System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel) | Out-Null
#[System.GC]::Collect()
#[System.GC]::WaitForPendingFinalizers()
