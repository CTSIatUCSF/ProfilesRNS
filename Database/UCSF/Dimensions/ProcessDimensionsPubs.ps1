Function NewPersonObject(){
    $checkListPMID=@{
    "pmids"=@();
    }    
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
        " SELECT top 300 SourceAuthorID,p.personid,p.FirstName,p.LastName,cast(inc.pmid  as varchar(10)) as pmid "+
	    " FROM [Profile.Data].[Publication.Person.Include] inc "+
	    " join [Profile.Data].[Person] p on inc.personid =p.personid "+
        " join [External.Publication].[AutorIDs] ExtID "+
		"   on ExtID.personID=p.personID "+
	    " left outer join [Profile.Data].[Publication.Person.Exclude] exc "+
		"	on	cast(inc.personid as varchar)+cast(inc.pmid  as varchar(10)) = "+
		"	cast(exc.personid as varchar)+cast(exc.pmid  as varchar(10)) "+
		" where exc.pmid is NULL "+ 
		#"	--and inc.personid=7688 "+
		"	and inc.pmid is not NULL and inc.pmid>0"+
        "   and p.personid > @lastIUN "+
		" order by p.personid,inc.pmid "

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
            $readpmid=$reader["pmid"]
            $IUN=$reader["personid"]

            if ($DEBUG -eq 1){write-host "curent id="$curID "newID="$dimid "newpmid="$readpmid "new personid="$IUN}
            if ($DEBUG -eq 1){write-host "DBpersons="$DBpersons}
            #if ($DEBUG -eq 1){write-host "personData="$personData}
            if ($dimid -eq $curID ){
                $personData.pmids += $readpmid
                continue
            } else {
                if ($curID.Length -gt 0)  {  $DBpersons += $personData }
                $personData=NewPersonObject
                $personData.DimensionsID=$dimid
                $curID=$dimid
                $personData.DimFistName =$fistname
                $personData.DimLastName =$lastname
                $personData.pmids +=$readpmid
                $personData.Dimpersonid=$IUN

            }
        }
        #$DBpersons += $personData
        $readLimit.lastIUN=$IUN
        $readLimit.lastPMID=$readpmid
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
    if ([string]::IsNullOrEmpty($readLimit.lastIUN)) {exit}    
# reading all pmids forlastIUN
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText =
        " SELECT SourceAuthorID,p.personid,p.FirstName,p.LastName,cast(inc.pmid  as varchar(10)) as pmid "+
	    " FROM [Profile.Data].[Publication.Person.Include] inc "+
	    " join [Profile.Data].[Person] p on inc.personid =p.personid "+
        " join [External.Publication].[AutorIDs] ExtID "+
		"   on ExtID.personID=p.personID "+
	    " left outer join [Profile.Data].[Publication.Person.Exclude] exc "+
		"	on	cast(inc.personid as varchar)+cast(inc.pmid  as varchar(10)) = "+
		"	cast(exc.personid as varchar)+cast(exc.pmid  as varchar(10)) "+
		" where exc.pmid is NULL "+ 
		"	and PublicationSource='Dimensions' "+
		"	and inc.pmid is not NULL and inc.pmid>0"+
        "   and p.personid = @lastIUN "+
		" order by p.personid,inc.pmid "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters[0].Value = $readLimit.lastIUN
    $personData.pmids=@()
    $curID=$personData.DimensionsID
    $newreader = $sqlCommand.ExecuteReader()
    try {
        while ($newreader.Read())
        {
            $dimid=$newreader[“SourceAuthorID”]
            $fistname=$newreader["FirstName"]
            $lastname=$newreader["LastName"]
            $pmid=$newreader["pmid"]
            $IUN=$newreader["personid"]

            if ($DEBUG -eq 1){write-host "added curent id="$curID "newID="$dimid}
            if ($DEBUG -eq 1){write-host "addedDBpersons="$DBpersons}
            #if ($DEBUG -eq 1){write-host "personData="$personData}
            if ($dimid -eq $curID ){
                $personData.pmids += $pmid
                continue
            } else {
                if ($curID.Length -gt 0)  {  $DBpersons += $personData }
                $personData=NewPersonObject
                $personData.DimensionsID=$dimid
                $curID=$dimid
                $personData.DimFistName =$fistname
                $personData.DimLastName =$lastname
                $personData.pmids +=$pmid
                $personData.Dimpersonid=$IUN

            }
        }
        $DBpersons += $personData
        $readLimit.lastIUN=$IUN
        $readLimit.lastPMID=$pmid
        $newreader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
    }
    return $DBpersons
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
write-host "insertedPubID=<"$insertedPubID">"
write-host "pubid=<"$pubid">"
write-host "pubType=<"$pubType">"
write-host "pubSourceType=<"$pubSourceType">"
write-host "pubTitle<"$pubTitle">"
write-host "pubSourceTitle<"$pubSourceTitle">"
write-host "pubVolume<"$pubVolume">"
write-host "pubIssue<"$pubIssue">"
write-host "pubPagination<"$pubPagination">"
write-host "pubDate<"$pubDate">"
write-host "pubIssn<"$pubIssn">"
write-host "pubDoi<"$pubDoi">"
write-host "pubUrl<"$pubUrl">"
write-host "pubAuthors<"$pubAuthors">"
write-host "insertedPubID type="$insertedPubID.GetType()
write-host "pubid type="$pubid.GetType()
write-host "pubType type="$pubType.GetType()
write-host "pubSourceType type="$pubSourceType.GetType()
write-host "pubTitle type="$pubTitle.GetType()
write-host "pubSourceTitle type="$pubSourceTitle.GetType()
write-host "pubVolume type="$pubVolume.GetType()
write-host "pubIssue type="$pubIssue.GetType()
write-host "pubPagination type="$pubPagination.GetType()
write-host "pubDate type="$pubDate.GetType()
write-host "pubIssn type="$pubIssn.GetType()
write-host "pubdoi type="$pubDoi.GetType()
write-host "pubUrl type="$pubUrl.GetType()
write-host "pubAuthors type="$pubAuthors.GetType()



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
        " INSERT INTO [Profile.Data].[Publication.Import.PubData] (ActualIDType,ActualID,[Data])"+
        " VALUES (@IDtype,@pubID,@pubData) "+
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

$body=(@{'username' = $wusername; 'password' = $wpassword} | ConvertTo-JSON)
$TOKEN_URI=$apiurl+"/auth.json"
$DSL_TOKEN = (Invoke-RestMethod -Uri $TOKEN_URI -Method Post -Body $body).token

#$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open() 
$readLimit = New-Object -TypeName PSObject 
Add-Member -InputObject $readLimit -MemberType NoteProperty `
        -Name lastIUN -Value "0"
Add-Member -InputObject $readLimit -MemberType NoteProperty `
        -Name lastPMID -Value 0

$needNextPerson=1
while ($needNextPerson -eq 1){
    $newPersons=$null
    $newPersons=GetPersons $sqlConnection $readLimit
    if ($newPersons.Equals($null)) {
        $needNextPerson=0
        continue
    }
    $dimsIDs=""
    foreach ($person in $newPersons){
        if ($dimsIDs.Length -eq 0) {$dimsIDs='"'+$person.DimensionsID+'"'} 
        else {$dimsIDs=$dimsIDs+","+'"'+$person.DimensionsID+'"'}
    }
   
    $searchRequest='search publications  where researchers.id in [ '+$dimsIDs +' ]'+' return publications[all] limit 500' 
    $searchRequest
    $DATA_URI=$apiurl+"/dsl.json"
    $jsonResult=Invoke-RestMethod -Uri $DATA_URI -Method Post -H @{Authorization = "JWT $DSL_TOKEN"} -Body $searchRequest
    $pubAuthors=
    foreach($pub in $jsonResult.publications){
        $pubJson=$pub|ConvertTo-Json -depth 100 -compress        
        $insertedPubID=0
        if ($DEBUG -eq 1){write-host "pmid="$pub.pmid}
        if ([string]::IsNullOrEmpty($pub.pmid)) {
            $gg=InsertPubData $sqlConnection $pub.id $pubJson
            $insertedPubID=$gg[1]
        }
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
            if ($DEBUG -eq 1){write-host "pmid="$pub.pmid}
            if ([string]::IsNullOrEmpty($pub.pmid)) {
                SaveAuthor $sqlConnection $insertedPubID $order $authorid $fname $lname
                if ($order -ge 2) {
                    $authors=$authors+","
                } 
                $authors=$authors+$fname+" "+$lname
            }
            foreach ($personLine in $newPersons){
                if ($DEBUG -eq 1){write-host "find "$authorid "comparing with " $personLine.DimensionsID}
                if ($DEBUG -eq 1){write-host $pub.id $authors}
                if ($personLine.DimensionsID -eq $authorid){
                    $personID=$personLine.DimpersonID
                    if ($DEBUG -eq 1){write-host "found Author with personID="$personID}
                    if ($DEBUG -eq 1){write-host "pmid="$pub.pmid}
                    if  ($personid -gt 0 -and $insertedPubID -lt 0 ) { 
                        SavePub2Person $sqlConnection $pub.id $personid $order $insertedPubID
                    }
                    if (-not [string]::IsNullOrEmpty($pub.pmid) -and -not $personLine.pmids.Contains($pub.pmid)){
                        write-host "PMID=" $pub.pmid " Lost in " $personLine.DimFistName $personLine.DimLastName "Profile"
                    } 
                    break
                }
            }
        }
        if ($DEBUG -eq 1){write-host "pmid="$pub.pmid}       
        if ([string]::IsNullOrEmpty($pub.pmid)) {
            if ($DEBUG -eq 1){write-host $pub.id " Title=" $pub.title "Inserted at " $pub.date_inserted}
            if ($DEBUG -eq 1){write-host $pub.doi}
            if ($DEBUG -eq 1){write-host $pub.journal.title "(date " $pub.date "vol " $pub.volume "issue " $pub.issue "pages " $pub.pages ")"}

#$insertedPubID=0
$pubid="unknown"
$pubType="unknown"
$pubSourceType="unknown"
$pubTitle="unknown"
$pubSourceTitle="unknown"
$pubVolume="unknown"
$pubIssue="unknown"
$pubPagination="unknown"
$pubDate="1900"
$pubIssn="unknown"
$pubDoi="unknown"
$pubUrl="unknown"
$pubAuthors="unknown"
            

            if ( $pub.type -eq "proceeding") {
                write-host "before type="$pubType
            }
            if ( -not [string]::IsNullOrEmpty($pub.type)){
                $pubType=$pub.type
            }
            if ( $pub.type -eq "processing") {
                write-host "after type="$pubType
            }
            
            if (  -not [string]::IsNullOrEmpty($pub.journal)){$pubSourceType="Journal"}
            $pubTitle=$pub.title
            if ( -not  [string]::IsNullOrEmpty($pub.journal)){$pubSourceTitle=$pub.journal.title}
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
            $pubAuthors=$authors
            SaveGeneral $sqlConnection $insertedPubID $pub.id $pubType $pubSourceType $pubTitle $pubSourceTitle $pubVolume $pubIssue $pubPagination $pubDate $pubIssn $pubDoi $pubUrl $pubAuthors
        }
  
        continue

        #$pub.pmid
        #if ( -not [string]::IsNullOrEmpty($pub.pmid)) {
            #continue
        #}
         
        #$pubJson.Length
        # $authorsList.names
    }
    # save to DB as $pub|ConvertTo-Json -depth 100

   #[xml]$pub|ConvertTo-Json -Depth 100|ConvertTo-XML -depth 100
   #[xml] $pubXML=$wk.OuterXml
   #$wk1=$pubXML.Objects.Object.InnerText
   #$restPub=$wk1|ConvertFrom-Json
   #if ($DEBUG -eq 1){write-host $restPub.id " Title=" $restPub.title}
   #if ($DEBUG -eq 1){write-host $restPub.doi}
   #if ($DEBUG -eq 1){write-host $restPub.journal.title "( year " $restPub.year "vol " $restPub.volume "issue " $restPub.issue "pages " $restPub.pages ")"}

}
