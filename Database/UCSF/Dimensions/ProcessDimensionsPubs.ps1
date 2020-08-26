Function NewPersonObject(){
    $checkListPMID=@{"publs"=@();}
    $personData = New-Object -TypeName PSObject -Property $checkListPMID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimensionsID -Value $curID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimFistName -Value ""
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimLastName -Value ""
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name Dimpersonid -Value ""
    return $personData
}
Function GetPersons {
    param ( [System.Data.SqlClient.SqlConnection] $sqlConnection, 
        [Object] $readLimit)

    #([Data.SqlClient.SqlConnection] $sqlConnection,[ref] $readLimit ) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection

    $personData=NewPersonObject
    
    $curID=""
    $DBpersons=@()

    $sqlCommand.CommandText =
        " SELECT SourceAuthorID,p.personid,p.FirstName,p.LastName "+
        "     , ActualID as publ "+
	    " FROM [UCSF.].[ExternalID] ExtID "+  
	    " join [Profile.Data].[Person] p on ExtID.personid =p.personid "+
        " join DimensionsStage1 limList on LimList.personid =ExtID.personid "+
		" left outer join ( "+
		"  select * from [Profile.Data].[Publication.Person.Include] "+ 
		"	union "+
		"  select * from [Profile.Data].[Publication.Person.Exclude] "+
		" ) pubs "+
		"  on pubs.personid=ExtID.personid and pubs.pmid<0 "+
		" left join [Profile.Data].[Publication.Import.PubData] neg "+ 
		"   on neg.ImportPubID=pubs.pmid "+
		"  where PublicationSource='Dimensions' "+
        "    and p.internalusername  like '%@ucsf.edu' "+
        "    and  p.personid in ("+ 
 		"    select top 1 IDs.personid from [UCSF.].[ExternalID] IDs "+
        "    join DimensionsStage1 limitedSet on LimitedSet.personid =IDs.personid "+ 
		"		where IDs.personid >  @lastIUN "+
        "    ) "

    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters[0].Value = $readLimit.lastIUN
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $dimid=$reader[“SourceAuthorID”]
            $fistname=$reader["FirstName"]
            $lastname=$reader["LastName"]
            $readpubl=$reader["publ"]
            $IUN=$reader["personid"]

            if ($DEBUG -eq 1){write-host "curent id="$curID "newID="$dimid "newpmid="$readpmid "new personid="$IUN}
            if ($DEBUG -eq 1){write-host "DBpersons="$DBpersons}
            #if ($DEBUG -eq 1){write-host "personData="$personData}
            if ($dimid -eq $curID ){
                $personData.publs += $readpubl
                    continue
            } else {
                if ($curID.Length -gt 0)  {  $DBpersons += $personData }
                $personData=NewPersonObject
                $personData.DimensionsID=$dimid
                $curID=$dimid
                $personData.DimFistName =$fistname
                $personData.DimLastName =$lastname
                $personData.publs +=$readpubl
                $personData.Dimpersonid=$IUN

            }
        }
        $DBpersons += $personData
        $readLimit.lastIUN=$IUN
        $readLimit.lastPUBL=$readpubl
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
    if ([string]::IsNullOrEmpty($readLimit.lastIUN)) {
        write-host "Processed Dimensions publications for "$numcall " profiles" 
        exit
    }
    return $DBpersons
}    
Function GetProcessed ( [System.Data.SqlClient.SqlConnection] $sqlConnection,$inSet,$hashPubs) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection

    $foundPubs=@{}
    $foundPubs=$hashPubs

    $sqlCommand.CommandText =
        " select actualID,importPubID from [Profile.Data].[Publication.Import.PubData] "+
        "    where actualID in ("+$inSet+") "

    $sqlcommand.CommandTimeout=120
    #$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@inSet",[Data.SQLDBType]::VarChar, -1))) | Out-Null
    #$sqlCommand.Parameters[0].Value = $inSet
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $pubInDB=$reader[“actualID”]
            $pmidInDB=$reader[“importPubID”]
            $foundPubs[$pubInDB]=$pmidInDB
        }
        $reader.Close()
        return $foundPubs
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
}

Function GetAuthors ($jsonPub) {
  $wklist=@()
  $fnames=@()
  $lnames=@()
  $returnValue = New-Object -TypeName PSObject
  Add-Member -InputObject $returnValue -MemberType NoteProperty `
        -Name fnames -Value $fnames
  Add-Member -InputObject $returnValue -MemberType NoteProperty `
        -Name lnames -Value $lnames
  Add-Member -InputObject $returnValue -MemberType NoteProperty `
        -Name ids -Value $wklist
 
  foreach ($affiliationLine in $jsonPub.author_affiliations) {
    foreach($author in  $affiliationLine){
        $order++
        $returnValue.ids +=$author.researcher_id
        $returnValue.fnames +=$author.first_name
        $returnValue.lnames +=$author.last_name
    }
  }
  #if ($DEBUG -eq 1){write-host $returnValue}
  return $returnValue
}


function SaveAuthor ([Data.SqlClient.SqlConnection]$sqlConnection,$sourcePubID,$order,$sourceid,$sourceForeName,$sourceLastName) {
    write-host "in SaveAuthor processing name="$SourceLastName "pub ID="$sourcePubID
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
        "(SELECT * FROM  [Profile.Data].[Publication.Import.Author] WHERE ImportPubID=@sourcePubID and AuthorRank=@order ) "+ 
        " BEGIN "+
        " INSERT INTO [Profile.Data].[Publication.Import.Author] (ImportPubID,AuthorRank,SourceAuthorID,ForeName,LastName)"+
        " VALUES (@sourcePubID,@order,@sourceid,@sourceForeName,@sourceLastName) "+
        " END ;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sourcePubID",[Data.SQLDBType]::Integer))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@order",[Data.SQLDBType]::Integer))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sourceid",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sourceForeName",[Data.SQLDBType]::VarChar, 100))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@sourceLastName",[Data.SQLDBType]::VarChar, 100))) | Out-Null
    
    $sqlCommand.Parameters[0].Value = $sourcePubID
    $sqlCommand.Parameters[1].Value = $order
    $sqlCommand.Parameters[2].Value = $sourceid
    $sqlCommand.Parameters[3].Value = $sourceForeName
    $sqlCommand.Parameters[4].Value = $sourceLastName
    try{    
        $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing write into Author table pubid=" $sourcePubID " and Author=" $sourceid  
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        if ($DEBUG -eq 1){write-host `n"URL"$url}
        if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
}

function SavePub2Person ($sqlConnection,$pubid,$personid,$order,$insertedPubID){
    write-host "in SavePub2Person processing pub idkey="$pubid" person="$personid
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
        "(SELECT * FROM  [Profile.Data].[Publication.Import.Pub2Person] WHERE ImportPubID=@insertedPubID and PersonID=@personid ) "+ 
        " BEGIN "+
        " INSERT INTO [Profile.Data].[Publication.Import.Pub2Person] (ActualIDType,ActualID,PersonID,AuthorRank,ImportPubID)"+
        " VALUES (@ActualSourceType,@pubid,@personid,@order,@insertedPubID) "+
        " END ;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ActualSourceType",[Data.SQLDBType]::varChar, 20))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@pubid",[Data.SQLDBType]::varChar, 50))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@personid",[Data.SQLDBType]::Integer))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@order",[Data.SQLDBType]::Integer))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@insertedPubID",[Data.SQLDBType]::Integer))) | Out-Null

    
    $sqlCommand.Parameters[0].Value = "Dimensions"
    $sqlCommand.Parameters[1].Value = $pubid
    $sqlCommand.Parameters[2].Value = $personid
    $sqlCommand.Parameters[3].Value = $order
    $sqlCommand.Parameters[4].Value = $insertedPubID
    try{    
        $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing write into Pub2Person " $personid "," $order "," $insertedPubID
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        if ($DEBUG -eq 1){write-host `n"URL"$url}
        if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }

}

function SaveGeneral ([Data.SqlClient.SqlConnection]$sqlConnection,$insertedPubID, $pubid, $pubType, $pubSourceType, $pubTitle, $pubSourceTitle, $pubVolume, $pubIssue,$pubPagination,$pubDate,$pubIssn,$pubDoi, $pubUrl, $pubAuthors) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    if ($DEBUG -eq 1){write-host "insertedPubID=<"$insertedPubID">"}
    if ($DEBUG -eq 1){write-host "pubid=<"$pubid">"}
    if ($DEBUG -eq 1){write-host "pubType=<"$pubType">"}
    if ($DEBUG -eq 1){write-host "pubSourceType=<"$pubSourceType">"}
    if ($DEBUG -eq 1){write-host "pubTitle<"$pubTitle">"}
    if ($DEBUG -eq 1){write-host "pubSourceTitle<"$pubSourceTitle">"}
    if ($DEBUG -eq 1){write-host "pubVolume<"$pubVolume">"}
    if ($DEBUG -eq 1){write-host "pubIssue<"$pubIssue">"}
    if ($DEBUG -eq 1){write-host "pubPagination<"$pubPagination">"}
    if ($DEBUG -eq 1){write-host "pubDate<"$pubDate">"}
    if ($DEBUG -eq 1){write-host "pubIssn<"$pubIssn">"}
    if ($DEBUG -eq 1){write-host "pubDoi<"$pubDoi">"}
    if ($DEBUG -eq 1){write-host "pubUrl<"$pubUrl">"}
    if ($DEBUG -eq 1){write-host "pubAuthors<"$pubAuthors">"}
    if ($DEBUG -eq 1){write-host "insertedPubID type="$insertedPubID.GetType()}
    if ($DEBUG -eq 1){write-host "pubid type="$pubid.GetType()}
    if ($DEBUG -eq 1){write-host "pubType type="$pubType.GetType()}
    if ($DEBUG -eq 1){write-host "pubSourceType type="$pubSourceType.GetType()}
    if ($DEBUG -eq 1){write-host "pubTitle type="$pubTitle.GetType()}
    if ($DEBUG -eq 1){write-host "pubSourceTitle type="$pubSourceTitle.GetType()}
    if ($DEBUG -eq 1){write-host "pubVolume type="$pubVolume.GetType()}
    if ($DEBUG -eq 1){write-host "pubIssue type="$pubIssue.GetType()}
    if ($DEBUG -eq 1){write-host "pubPagination type="$pubPagination.GetType()}
    if ($DEBUG -eq 1){write-host "pubDate type="$pubDate.GetType()}
    if ($DEBUG -eq 1){write-host "pubIssn type="$pubIssn.GetType()}
    if ($DEBUG -eq 1){write-host "pubdoi type="$pubDoi.GetType()}
    if ($DEBUG -eq 1){write-host "pubUrl type="$pubUrl.GetType()}
    if ($DEBUG -eq 1){write-host "pubAuthors type="$pubAuthors.GetType()}



    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
        "(SELECT * FROM  [Profile.Data].[Publication.Import.General] WHERE ImportPubID=@ImportPubID ) "+ 
        " BEGIN "+
        " INSERT INTO [Profile.Data].[Publication.Import.General] "+
        " VALUES (@ImportPubID,@ImportFileID,@ActualIDType,@ActualID,@ItemType,@SourceType,@ItemTitle,@SourceTitle,"+
        " @SourceAbbr,@Volume,@Issue,@Pagination,@PubDate,@ISSN,@DOI,@PMID,@URL,@Authors,@Reference,@TimesCited) "+
        " END ;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ImportPubID",[Data.SQLDBType]::Integer))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ImportFileID",[Data.SQLDBType]::Integer))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ActualIDType",[Data.SQLDBType]::VarChar, 50))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ActualID",[Data.SQLDBType]::VarChar, 50))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ItemType",[Data.SQLDBType]::VarChar, 100))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SourceType",[Data.SQLDBType]::VarChar, 100))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ItemTitle",[Data.SQLDBType]::VarChar, 4000))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SourceTitle",[Data.SQLDBType]::VarChar, 1000))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@SourceAbbr",[Data.SQLDBType]::VarChar, 1000))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Volume",[Data.SQLDBType]::VarChar, 25))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Issue",[Data.SQLDBType]::VarChar, 255))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Pagination",[Data.SQLDBType]::VarChar, 255))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PubDate",[Data.SQLDBType]::VarChar, 10))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@ISSN",[Data.SQLDBType]::VarChar, 20))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DOI",[Data.SQLDBType]::VarChar, 1000))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PMID",[Data.SQLDBType]::Integer))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@URL",[Data.SQLDBType]::VarChar, 1000))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Authors",[Data.SQLDBType]::VarChar, -1))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@Reference",[Data.SQLDBType]::VarChar, -1))) | Out-Null 
	$sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TimesCited",[Data.SQLDBType]::Integer))) | Out-Null
    

    $sqlCommand.Parameters[0].Value = $insertedPubID
    $sqlCommand.Parameters[1].Value = [DBNull]::Value
    $sqlCommand.Parameters[2].Value = "Dimensions" 
    $sqlCommand.Parameters[3].Value = $pubid
    $sqlCommand.Parameters[4].Value = $pubType
    $sqlCommand.Parameters[5].Value = $pubSourceType
    $sqlCommand.Parameters[6].Value = $pubTitle
    $sqlCommand.Parameters[7].Value = $pubSourceTitle
    $sqlCommand.Parameters[8].Value = [DBNull]::Value
    $sqlCommand.Parameters[9].Value = $pubVolume
    $sqlCommand.Parameters[10].Value = $pubIssue
    $sqlCommand.Parameters[11].Value = $pubPagination
    $sqlCommand.Parameters[12].Value = $pubDate  #[DBNull]::Value #
    $sqlCommand.Parameters[13].Value = $pubIssn
    $sqlCommand.Parameters[14].Value = $pubDoi
    $sqlCommand.Parameters[15].Value = $insertedPubID
    $sqlCommand.Parameters[16].Value = $pubUrl
    $sqlCommand.Parameters[17].Value = $pubAuthors
    $sqlCommand.Parameters[18].Value = [DBNull]::Value
    $sqlCommand.Parameters[19].Value = [DBNull]::Value
    
    try{    
        $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing write into General table pubid=" $pubid   
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        if ($DEBUG -eq 1){write-host `n"URL"$url}
        if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }

}

function InsertPubData ([Data.SqlClient.SqlConnection] $sqlConnection,$key,$value) {
    write-host "in InsertPubData processing key="$key
    $ActualDataType="Dimensions"
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    #if ($DEBUG -eq 1){write-host "inserting key="$key" value="$value}
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
        "(SELECT * FROM  [Profile.Data].[Publication.Import.PubData] WHERE ActualIDType=@IDtype and ActualID=@pubID ) "+ 
        " BEGIN "+
        " INSERT INTO [Profile.Data].[Publication.Import.PubData] (ActualIDType,ActualID,[Data],ParseDT)"+
        " VALUES (@IDtype,@pubID,@pubData,GETDATE()) "+
        " END ;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IDtype",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@pubID",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@pubData",[Data.SQLDBType]::NVarChar, -1))) | Out-Null
    
    $sqlCommand.Parameters[0].Value = $ActualDataType
    $sqlCommand.Parameters[1].Value = $key
    $sqlCommand.Parameters[2].Value = $value

    try{
         $sqlCommand.ExecuteScalar()
         $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
         $sqlCommand.Connection = $sqlConnection
         $sqlCommand.CommandText =
         "SELECT ImportPubID FROM  [Profile.Data].[Publication.Import.PubData] "+   
         " where ActualIDType='"+$ActualDataType+"' and ActualID='"+$key+"'"
        $sqlcommand.CommandTimeout=120
        $reader = $sqlCommand.ExecuteReader()
        try {
            while ($reader.Read())
            {
                $ImportPubID=$reader[“ImportPubID”]
            }
            $reader.Close()
        }catch{
            $ErrorMessage = $_.Exception.Message
            $hh=get-date -f MM/dd/yyyy_HH:mm:ss
            write-host `n$hh   $ErrorMessage
        }
        write-host "in InsertPubData returning ID=" $ImportPubID
        return $ImportPubID
    } catch {
        write-host $_.Exception.Message " processing pubid="$key 
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        if ($DEBUG -eq 1){write-host `n"URL"$url}
        if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }

}


if ($DEBUG -eq 1){write-host "count=" $args.count "arguments=" $args}
if ($args.count -eq 0) {
    if ($DEBUG -eq 1){write-host "Need file with names/passwords"}
    exit
}
# Dimension types described at https://docs.dimensions.ai/dsl/datasource-publications.html
$allowedTypes=@("article"
,"chapter"
#,"monograph"
)
$titleRegex=@()
$titleRegex+='.{10,}\w\w.{10.}\w-+letters?'
$titleRegex+='^(the )?authors? reply'
$titleRegex+='^an open letter to'
$titleRegex+='^correction( to)?:'
$titleRegex+='^letter (by.*)*regarding'
$titleRegex+='^letter in response to'
$titleRegex+='^letter( \d+)?:'
$titleRegex+='^reply to the letters?'
$titleRegex+='^response by.*to'
$titleRegex+='^response letter to'
$titleRegex+='^response to [A-Z].{1,20}($|:)'
$titleRegex+='^response to comment(ary)?'
$titleRegex+='^response to the letter'
$titleRegex+='^response to.*(re(garding)?|paper|correspondence|doi|et al|dr.? [[:alpha:]]{2,})'
$titleRegex+='^response to\s*[[:punct:]]'
$titleRegex+='^retracted'
$titleRegex+='^retraction'
$titleRegex+='^withdrawn'
$titleRegex+='letters? to (the )?editor'
$titleRegex+='the authors? reply[!"\#$%&''()*+,\-./:;<=>?@\[\\\]^_`{|}~]*$'

$params=$args[0..($args.count-1)]
if ($DEBUG -eq 1){write-host "params="$params}

# Take settings from config file
#if ($PWD) {$myDir=$PWD}
if ($MyInvocation) {
    $myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
$ff=$params[0]
[xml]$ConfigFile = Get-Content "$MyDir\$ff"

$DBserver=$ConfigFile.Settings.Database.DBServer
$DBName=$ConfigFile.Settings.Database.DBName 
$dbuser=$ConfigFile.Settings.Database.DBUser 
$dbpassword=$ConfigFile.Settings.Database.DBPassword 
$wusername=$ConfigFile.Settings.WebService.WSUser
$wpassword=$ConfigFile.Settings.WebService.WSPassword 
$apiurl=$ConfigFile.Settings.WebService.URL
try {
    $body=(@{'username' = $wusername; 'password' = $wpassword} | ConvertTo-JSON)
    $TOKEN_URI=$apiurl+"/auth.json"
    $DSL_TOKEN = (Invoke-RestMethod -Uri $TOKEN_URI -Method Post -Body $body).token
}catch{
    write-host "StatusCode:" $_.Exception.Response.StatusCode.value__ 
    write-host "StatusDescription:" $_.Exception.Response.StatusDescription
    write-host "Exiting due to problem with Dimensions API connection"
    exit
}

try {
    $sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
    $sqlConnection.Open()
}catch{
    write-host "Exception:" $_.Exception
    write-host "Exiting due to problem with RNS Database connection"
    exit
}
$numcall=0 
$errornum=0
$readLimit = New-Object -TypeName PSObject 
Add-Member -InputObject $readLimit -MemberType NoteProperty `
        -Name lastIUN -Value "0"
Add-Member -InputObject $readLimit -MemberType NoteProperty `
        -Name lastPUBL -Value 0

$needNextPerson=1
while ($needNextPerson -eq 1){
    $newPersons=$null
    get-date -f MM/dd/yyyy_HH:mm:ss
    $numcall++
   #if ($numcall -ge 10){
   #   write-host "Sleeping 3 sec" $numcall
   #   Start-sleep -Seconds 3
   #   $numcall=0
   #} 
   $newPersons=GetPersons $sqlConnection $readLimit
   $newPersons
    get-date -f MM/dd/yyyy_HH:mm:ss
    if ($newPersons.Equals($null)) {
        $needNextPerson=0
        continue
    }
    $dimsIDs=""
    foreach ($person in $newPersons){
        if ($dimsIDs.Length -eq 0) {$dimsIDs='"'+$person.DimensionsID+'"'} 
        else {$dimsIDs=$dimsIDs+","+'"'+$person.DimensionsID+'"'}
    }
    $skip=0
    $setlen=-1
    $totalcount=-1
    #$numcall=0
    #$DEBUG=1
    while  (( -not $setlen -eq 0) -and ($totalcount-$skip -ne 0)) {
        $attempt=0
        $errornum=0
        $StatusCode=0
        $searchRequest='search publications  where researchers.id in [ '+$dimsIDs +' ] and pmid is empty'+' return publications[all] limit 1000 skip '+ $skip
        $searchRequest
        $DATA_URI=$apiurl+"/dsl.json"
        while ($attempt -le 2) {
            try {
                $jsonResult=Invoke-RestMethod -Uri $DATA_URI -Method Post -H @{Authorization = "JWT $DSL_TOKEN"} -Body $searchRequest
                $pubAuthors=""
                #$attempt=3
                #$errornum=0
                write-host "attempts=" $attempt "errornum " $errornum
                $StatusCode=$_.Exception.Response.StatusCode.value__
            }catch{
                $StatusCode=$_.Exception.Response.StatusCode.value__
                $StatusDescription= $_.Exception.Response.StatusDescription
                Write-Host "StatusCode:" $StatusCode 
                Write-Host "StatusDescription:" $StatusDescription
                write-host "before attempts=" $attempt
                if ($attempt -lt 2) {
                    write-host "Skipping due after "$attempt " failed atttempts executing query:"
                    $searchRequest 
                    #exit
                } 
                $attempt++
                $errornum++
                if ($attempt -gt 3) {break}
                Start-sleep -Seconds 1
                continue
            }
            If ([string]::IsNullOrEmpty($StatusCode)) {
                $StatusCode=0
                break
            }
        }
        if ($StatusCode -gt 0){
            write-host "errornum= "$errornum
            $errornum++
            if ( $errornum -lt 3) {
                $StatusCode=0
                $StatusDescription=""
                $setlen=0
                $totalcount=0
                continue
            }  
            else {
                write-host "Exiting after skipping 3 queries"
                break
            }
        } 
        $setlen=$jsonResult.publications.Length
        $totalcount=$jsonResult._stats.total_count
        write-host "setlen=" $setlen "_stat="$jsonResult._stats
        if ($setlen -eq 0){break}
        $pubsInDB=""
        $hash=$null
        $hash=@{}
        foreach($pub in $jsonResult.publications){
            $skip++
            # filter out unneeded publication types
            if ( -not $allowedTypes.Contains($pub.type)) {
                $badTitle=1
            } else {
                # filter out  not actual publications
                foreach ($regex in $titleRegex){
                    $badTitle=$pub.title -match $regex
                    if ($badTitle) {
                        write-host "Publication "$pub.id "<"$pub.title">"
                        write-host "validating->"$regex"->returning " $badTitle
                        break
                    }
                }
            }
            if ($badTitle) {continue}

            if ($pubsInDB -eq "") {$pubsInDB=$pubsInDB+"'"+$pub.id+"'"}
            else {$pubsInDB=$pubsInDB+",'"+$pub.id+"'"}
            $hash.add($pub.id,0)
        }
        if(-not [string]::IsNullOrEmpty($pubsInDB)){
            $processedPubs=GetProcessed $sqlConnection $pubsInDB $hash
        } 
        $pubnum=0
        foreach($pub in $jsonResult.publications){
            $pubnum++
            if ($hash.count -eq 0 ) {
                write-host "("$pubnum","$skip")<->" $pub.id " Hash for this pub is empty " 
                continue
            }
            #if ($hash.count -gt 0 -and $hash.ContainsKey($pub.id) -and $hash[$pub.id] -le -1) {
            #    write-host "("$pubnum","$skip")<->" $pub.id " this pub been previously processed" 
            #    continue
            #}
            if ($hash.count -gt 0 -and -not $hash.ContainsKey($pub.id)) {
                write-host "("$pubnum","$skip")<->" $pub.id " this pub has not allowed title or type"
                continue
            }
            write-host "("$pubnum","$skip")<->" $pub.id "Continue to process"
            $authorsList=GetAuthors $pub
            for($rank=0;$rank-le $authorsList.ids.length-1;$rank++){
                if ($person.DimensionsID -eq $authorsList.ids[$rank]) {
                    $rank++
                    break
                }
            }
            if ( $processedPubs[$pub.id] -eq 0) {
                $pubJson=$pub|ConvertTo-Json -depth 100 -compress        
                $insertedPubID=0
                $gg=InsertPubData $sqlConnection $pub.id $pubJson
                $insertedPubID=$gg[1]
                $authorsList=GetAuthors $pub
                $order=0
                $authors=""
                foreach ($authorid in $authorsList.ids){
                    $order++
                    $personID=0
                    if ($DEBUG -eq 1){write-host "checking id="$authorid}
                    $lname=$authorsList.lnames[$order-1]
                    $fname=$authorsList.fnames[$order-1]
                    if ($DEBUG -eq 1){write-host $insertedPubID "," $order "," $authorid "," $fname "," $lname}
                    SaveAuthor $sqlConnection $insertedPubID $order $authorid $fname $lname
                    if ($order -ge 2) {
                        $authors=$authors+", "
                    } 
                    $authors=$authors+$fname+" "+$lname
                }
                if ($DEBUG -eq 1){write-host $pub.id " Title=" $pub.title "Inserted at " $pub.date_inserted}
                if ($DEBUG -eq 1){write-host $pub.doi}
                if ($DEBUG -eq 1){write-host $pub.journal.title "(date " $pub.date "vol " $pub.volume "issue " $pub.issue "pages " $pub.pages ")"}
                $pubid=""
                $pubType=""
                $pubSourceType=""
                $pubTitle=""
                $pubSourceTitle=""
                $pubVolume=""
                $pubIssue=""
                $pubPagination=""
                $pubDate="1900"
                $pubIssn=""
                $pubDoi=""
                $pubUrl=""
                $pubAuthors=""
                if ( -not [string]::IsNullOrEmpty($pub.type)){
                    $pubType=$pub.type
                }
                if ( $pub.type -eq "processing") {
                    write-host "after type="$pubType
                }
                if (  -not [string]::IsNullOrEmpty($pub.journal)){$pubSourceType="Journal"}
                $pubTitle=$pub.title
                if ( -not  [string]::IsNullOrEmpty($pub.journal)){$pubSourceTitle=$pub.journal.title}
                if ($pubSourceTitle -eq "" -and [string]::IsNullOrEmpty($pub.book_title)){$pubSourceTitle=$pub.book_title}
                if ([string]::IsNullOrEmpty($pubSourceTitle)) {$pubSourceTitle=""}
                if ( -not  [string]::IsNullOrEmpty($pub.volume)){$pubVolume=$pub.volume}
                if ( -not  [string]::IsNullOrEmpty($pub.issue)){$pubIssue=$pub.issue}
                if ( -not [string]::IsNullOrEmpty($pub.pages)){$pubPagination=$pub.pages}
                if ( -not  [string]::IsNullOrEmpty($pub.date)){$pubDate=$pub.date}
                if ( -not  [string]::IsNullOrEmpty($pub.issn)){
                    $pubIssn=$pub.issn[0]
                }
                if ( -not  [string]::IsNullOrEmpty($pub.doi)){
                    $pubDoi=$pub.doi 
                    $pubUrl="http://dx.doi.org/"+$pubDoi
                }
                if ($authors.Length -ge 4000){
                    $pubAuthors=$authors.Substring(1,3900)+"..."
                }else {$pubAuthors=$authors}
                
                SaveGeneral $sqlConnection $insertedPubID $pub.id $pubType $pubSourceType $pubTitle $pubSourceTitle $pubVolume $pubIssue $pubPagination $pubDate $pubIssn $pubDoi $pubUrl $pubAuthors
            } else {$insertedPubID=$processedPubs[$pub.id]}
            if  ($person.Dimpersonid -gt 0 -and $insertedPubID -ne $null -and $insertedPubID -lt 0 -and -not $person.publs.Contains($pub.id)) { 
                SavePub2Person $sqlConnection $pub.id $person.Dimpersonid $rank $insertedPubID
            }
            continue
        }
    }
}
 
