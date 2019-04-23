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
        -Name DimInternalUserName -Value ""
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
        "SELECT top 300 [AuthorID],p.internalusername,dims.[FirstName],dims.[LastName],pmid "+ 
        "  FROM [Profile.Data].[Publication.Person.Include] inc   "+
        "  JOIN  [Profile.Data].[Person] p on p.personid=inc.personid "+ 
		"  JOIN [External.Publication].[AutorIDs] dims on p.internalusername=dims.internalusername "+
	    "   where AuthorIDType='Dimensions' and pmid is not NULL  "+
        "    and dims.internalusername > @lastIUN "+
        "    order by dims.internalusername,pmid  "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters[0].Value = $readLimit.lastIUN
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $dimid=$reader[“AuthorID”]
            $fistname=$reader["FirstName"]
            $lastname=$reader["LastName"]
            $pmid=$reader["pmid"]
            $IUN=$reader["internalusername"]

            #write-host "curent id="$curID "newID="$dimid
            #write-host "DBpersons="$DBpersons
            #write-host "personData="$personData
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
                $personData.DimInternalUserName=$IUN

            }
        }
        #$DBpersons += $personData
        $readLimit.lastIUN=$IUN
        $readLimit.lastPMID=$pmid
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
    }
    if ([string]::IsNullOrEmpty($readLimit.lastIUN)) {exit}    
# reading all pmids forlastIUN
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText =
        "SELECT [AuthorID],p.internalusername,dims.[FirstName],dims.[LastName],pmid "+ 
        "  FROM [Profile.Data].[Publication.Person.Include] inc   "+
        "  JOIN  [Profile.Data].[Person] p on p.personid=inc.personid "+ 
		"  JOIN [External.Publication].[AutorIDs] dims on p.internalusername=dims.internalusername "+
	    "   where AuthorIDType='Dimensions' and pmid is not NULL  "+
        "    and dims.internalusername = @lastIUN "+
        "    order by dims.internalusername,pmid  "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters[0].Value = $readLimit.lastIUN
    $personData.pmids=@()
    $curID=$personData.DimensionsID
    $newreader = $sqlCommand.ExecuteReader()
    try {
        while ($newreader.Read())
        {
            $dimid=$newreader[“AuthorID”]
            $fistname=$newreader["FirstName"]
            $lastname=$newreader["LastName"]
            $pmid=$newreader["pmid"]
            $IUN=$newreader["internalusername"]

            #write-host "curent id="$curID "newID="$dimid
            #write-host "DBpersons="$DBpersons
            #write-host "personData="$personData
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
                $personData.DimInternalUserName=$IUN

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
  $authors=""
  $returnValue = New-Object -TypeName PSObject
  Add-Member -InputObject $returnValue -MemberType NoteProperty `
        -Name names -Value $authors
  Add-Member -InputObject $returnValue -MemberType NoteProperty `
        -Name ids -Value $wklist
 
  foreach ($affiliationLine in $jsonPub.author_affiliations) {
    foreach($author in  $affiliationLine){
        #write-host $author
        $returnValue.ids +=$author.researcher_id
        $returnValue.names=$returnValue.names+$author.first_name+" "+$author.last_name+","
    }
  }
  #write-host $returnValue 
  return $returnValue
}

function InsertPubData ([Data.SqlClient.SqlConnection] $sqlConnection,$key,$value,$tempvalue) {
    $ActualDataType="Dimensions"
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    #write-host "inserting key="$key" value="$value
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
        "(SELECT * FROM  [External.Publication].[Import.PubData] WHERE ActualIDType=@IDtype and ActualID=@pubID ) "+ 
        " BEGIN "+
        " INSERT INTO [External.Publication].[Import.PubData] (ActualIDType,ActualID,[Data],AuthorsList)"+
        " VALUES (@IDtype,@pubID,@pubData,@authors) "+
        " END "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@IDtype",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@pubID",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@pubData",[Data.SQLDBType]::NVarChar, -1))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@authors",[Data.SQLDBType]::NVarChar,300))) | Out-Null
    
    $sqlCommand.Parameters[0].Value = $ActualDataType
    $sqlCommand.Parameters[1].Value = $key
    $sqlCommand.Parameters[2].Value = $value
    $sqlCommand.Parameters[3].Value = $tempvalue
    try{
         $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing pubid="$key "authors="$tempvalue
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh   $ErrorMessage
    }
}


write-host "count=" $args.count "arguments=" $args
if ($args.count -eq 0) {
    write-host "Need file with names/passwords"
    exit
}
$params=$args[0..($args.count-1)]
write-host "params="$params

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

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
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
   
    $searchRequest='search publications  where researchers.id in [ '+$dimsIDs +' ]'+' return publications[all]' 
    $searchRequest
    $DATA_URI=$apiurl+"/dsl.json"
    $jsonResult=Invoke-RestMethod -Uri $DATA_URI -Method Post -H @{Authorization = "JWT $DSL_TOKEN"} -Body $searchRequest
    $pubAuthors=
    foreach($pub in $jsonResult.publications){
        $authorsList=GetAuthors $pub
        foreach ($authorid in $authorsList.ids){
            #write-host "checking id="$authorid
            $ff=$newPersons | where {$_.DimensionsID -eq  $authorid}
            if ($ff) {
                #write-host "found Author"
                #$ff
                if (-not [string]::IsNullOrEmpty($pub.pmid) -and -not $ff.pmids.Contains($pub.pmid)){
                    write-host "PMID=" $pub.pmid " Lost in " $ff.DimFistName $ff.DimLastName "Profile"
                } 
            } 
        }

        #$pub.pmid
        if ( -not [string]::IsNullOrEmpty($pub.pmid)) {
            continue
        }
        #write-host $pub.id " Title=" $pub.title "Inserted at " $pub.date_inserted
        #write-host $pub.doi
        #write-host $pub.journal.title "( year " $pub.year "vol " $pub.volume "issue " $pub.issue "pages " $pub.pages ")"
        $pubJson=$pub|ConvertTo-Json -depth 100 -compress
        #$pubJson.Length
        InsertPubData $sqlConnection $pub.id $pubJson $authorsList.names
    }
    # save to DB as $pub|ConvertTo-Json -depth 100

   #[xml]$pub|ConvertTo-Json -Depth 100|ConvertTo-XML -depth 100
   #[xml] $pubXML=$wk.OuterXml
   #$wk1=$pubXML.Objects.Object.InnerText
   #$restPub=$wk1|ConvertFrom-Json
   #write-host $restPub.id " Title=" $restPub.title
   #write-host $restPub.doi
   #write-host $restPub.journal.title "( year " $restPub.year "vol " $restPub.volume "issue " $restPub.issue "pages " $restPub.pages ")"

}
