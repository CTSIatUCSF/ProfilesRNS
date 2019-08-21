Function NewPersonObject(){
    $checkListPMID=@{
    "pmids"=@();
    }    
    $personData = New-Object -TypeName PSObject -Property $checkListPMID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimensionsID -Value $curID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimFirstName -Value ""
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
    $recordsRead=1000
    $recordsNum=0
    $readSize= "Select top $recordsRead "
    $readType=" > @lastIUN "

    $SQLquery=$readSize+ "p.personid personid,"+
        "   case "+
		"	    when na.PublishingFirst is not NULL then na.PublishingFirst "+
		"	else p.FirstName "+
		"   end Firstname, "+
		"   case "+
		"	    when na.PublishingLast is not NULL then na.PublishingLast "+
		"	else p.LastName "+
		"   end LastName, "+
	    "   cast(inc.pmid  as varchar(10)) as pmid "+
        " FROM [Profile.Data].[Publication.Person.Include] inc "+
        " join [Profile.Data].[Person] p on inc.personid =p.personid "+
        " join [UCSF.].[NameAdditions] na on p.internalusername=na.internalusername "+
        " left join [UCSF.].[ExternalID] ExtID "+
	    "    on ExtID.personID=p.personID "+
        " left outer join [Profile.Data].[Publication.Person.Exclude] exc "+
	    "    on	cast(inc.personid as varchar)+cast(inc.pmid  as varchar(10)) = "+
		"    cast(exc.personid as varchar)+cast(exc.pmid  as varchar(10)) "+
        " where exc.pmid is NULL  "+
	    "   and inc.pmid is not NULL and inc.pmid>0 "+
	    "   and ExtID.personID is NULL "+
        "   and p.personid "+$readType +
        " order by p.personid,inc.pmid"

#        "   and p.lastname='McMullen'and p.firstname='Ashley' "+
#"   and (p.personid=7997 or p.personid=12065) "+
#"   and p.personid=14911 "+
#" join [Profile.Data].[Publication.Person.Add] conf on conf.personid=p.personid and conf.pmid=inc.pmid "+

    $sqlCommand.CommandText =$SQLquery
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters[0].Value =$readLimit.lastIUN
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $recordsNum++
            $fistname=$reader["FirstName"]
            $lastname=$reader["LastName"]
            $readpmid=$reader["pmid"]
            $IUN=$reader["personid"]

            if ($DEBUG -eq 1){write-host "curent id="$curID "newID="$dimid "newpmid="$readpmid "new personid="$IUN}
            if ($DEBUG -eq 1){write-host "DBpersons="$DBpersons}
            #if ($DEBUG -eq 1){write-host "personData="$personData}
            if ($IUN -eq $curID ){
                $personData.pmids += $readpmid
                continue
            } else {
                if ($curID.Length -gt 0)  {  $DBpersons += $personData }
                $personData=NewPersonObject
                $personData.DimensionsID=$null
                $curID=$IUN
                $personData.DimFirstName =$fistname
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
    $newSQLquery=$SQLquery -replace  $readSize, "Select "
    $newSQLquery=$newSQLquery -replace $readType, " = @lastIUN "

    if ($recordsNum -eq $recordsRead) {   
        # reading all pmids forlastIUN
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText =$newSQLquery
        $sqlcommand.CommandTimeout=120
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
        $sqlCommand.Parameters[0].Value = $readLimit.lastIUN
        $personData.pmids=@()
        $curID=$personData.DimensionsID
        $newreader = $sqlCommand.ExecuteReader()
        try {
            while ($newreader.Read())
            {
                $fistname=$newreader["FirstName"]
                $lastname=$newreader["LastName"]
                $pmid=$newreader["pmid"]
                $IUN=$newreader["personid"]
                if ($DEBUG -eq 1){write-host "added curent id="$curID "newID="$dimid}
                if ($DEBUG -eq 1){write-host "addedDBpersons="$DBpersons}
                #if ($DEBUG -eq 1){write-host "personData="$personData}
                if ($IUN -eq $curID ){
                    $personData.pmids += $pmid
                    continue
                } else {
                    if ($curID.Length -gt 0)  {  $DBpersons += $personData }
                    $personData=NewPersonObject
                    $personData.DimensionsID=$null
                    $curID=$IUN
                    $personData.DimFirstName =$fistname
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
    } else {
        $DBpersons += $personData
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

function SaveDimensionsIDs ([Data.SqlClient.SqlConnection]$sqlConnection,$DimensionsID,$firstname,$lastname,$personID) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = " INSERT INTO [UCSF.].[ExternalID] "+
        " VALUES ('Dimensions',@DimensionsID,@firstname,@lastname,@personID); "

    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@DimensionsID",[Data.SQLDBType]::VarChar, 100))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@firstname",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastname",[Data.SQLDBType]::VarChar, 250))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@personid",[Data.SQLDBType]::Integer))) | Out-Null
    
    
    $sqlCommand.Parameters[0].Value = $DimensionsID
    $sqlCommand.Parameters[1].Value = $firstname
    $sqlCommand.Parameters[2].Value = $lastname
    $sqlCommand.Parameters[3].Value = $personID

    try{    
        $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing write into [UCSF.].[ExternalID]  "
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        if ($DEBUG -eq 1){write-host `n"URL"$url}
        if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
}






#$DEBUG=1
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
$DEBUG=0

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
    get-date -f MM/dd/yyyy_HH:mm:ss
    $newPersons=GetPersons $sqlConnection $readLimit
    $newPersons.Length
    get-date -f MM/dd/yyyy_HH:mm:ss
    if ($newPersons.Equals($null)) {
        $needNextPerson=0
        continue
    }
    $dimsIDs=""
    $numperson=0
    $numcall=0
    foreach ($person in $newPersons){
        get-date -f MM/dd/yyyy_HH:mm:ss
        $numperson++
        write-host "person number" $numperson
        $check_researcher= $person.DimFirstName+" "+$person.DimLastName
        $DimensionsID=$null
        $skip=0
        $setlen=-1
        $totalcount=-1
        while (( -not $setlen -eq 0) -and ($totalcount-$skip -ne 0)){
#$DEBUG=1
            $numcall++
            if ($numcall -ge 10){
                write-host "Sleeping 3 sec" $numcall
                 Start-sleep -Seconds 3
                 $numcall=0
            } 
            $searchRequest='search publications in authors for "\"'+$check_researcher+'\"" where pmid is not empty return publications [all] limit 1000 skip '+ $skip
            $searchRequest
            $jsonResult=Invoke-RestMethod -Uri https://app.dimensions.ai/api/dsl.json -Method Post -ContentType "text/plain; charset=utf-8"-H @{Authorization = "JWT $DSL_TOKEN"} -Body $searchRequest
            $setlen=$jsonResult.publications.Length
            $totalcount=$jsonResult._stats.total_count
            if ($DEBUG -eq 1){write-host "setlen=" $setlen "_stat="$jsonResult._stats}
            $skip=$skip+$setlen
            foreach ($pub in $jsonResult.publications){
                if ($DEBUG -eq 1){write-host "publication="$pub.id",pmid="$pub.pmid}
                #if ($DEBUG -eq 1){$pub.researchers}
                if ($DEBUG -eq 1){
                    $listpmids="("
                    foreach ($onepmid in $person.pmids){
                        if ($listpmids -eq "("){ $listpmids=$listpmids+$onepmid}
                        else {$listpmids=$listpmids+","+$onepmid}
                    }
                    $listpmids=$listpmids+")"
                    write-host "pmids="$listpmids
                }
                if ($person.pmids.contains($pub.pmid)) {
                    if ($DEBUG -eq 1) {write-host "Contains pmid="$pub.pmid}
                    foreach($researcher in $pub.researchers){
                        if ($DEBUG -eq 1){write-host "First Name <<"$researcher.first_name">>Last Name <<"$researcher.last_name">>pmid="$pub.pmid}
                        if ($DEBUG -eq 1){write-host "Looking for <<"$person.Dimfirstname" "$person.Dimlastname">>"}
                        $adjustedLastname=$researcher.last_name
                        if ($person.Dimlastname -eq $adjustedLastname) {
                                if ($researcher.first_name.substring(0,1) -eq $person.DimFirstName.Substring(0,1)) {
                                    $DimensionsID=$researcher.id
                                    break
                                }
                        }
                        continue
                    }
                }
                if ($DimensionsID -ne $null){break}
            }
            if ($DimensionsID -ne $null){break}
        }
        if ($DimensionsID -ne $null){
            if ($DEBUG -eq 1){write-host "Saving "$DimensionsID"for "$check_researcher}
            SaveDimensionsIDs $sqlConnection $DimensionsID $person.DimFirstName $person.DimLastName $person.Dimpersonid
        } else {
            write-host "Cannot find Dimensions ID for "$check_researcher
           
        }
 }
}
