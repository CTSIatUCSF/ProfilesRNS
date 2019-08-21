Function NewPersonObject(){
    $checkListPMID=@{"pmids"=@();}
    $personData = New-Object -TypeName PSObject -Property $checkListPMID
    Add-Member -InputObject $personData -MemberType NoteProperty `
        -Name DimensionsID -Value $curID
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
        "SELECT top 1000 SourceAuthorID,p.personid personid, "+
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
        "   and p.personid > @lastIUN   "+
		"   and PublicationSource='Dimensions' "+
        "   and p.internalusername  like '%@ucsf.edu' "+
        "   and p.isActive=1 "+
		"   order by p.personid "

    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastIUN",[Data.SQLDBType]::VarChar, 50))) | Out-Null
    $sqlCommand.Parameters[0].Value = $readLimit.lastIUN
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $dimid=$reader[“SourceAuthorID”]
            $readpmid=$reader["pmid"]
            $IUN=$reader["personid"]

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
            }
        }
        #$DBpersons += $personData
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
    if ($DBpersons.Length  -eq 0) {exit}    
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
if ($args.count -eq 0) {    write-host "Need file with names/passwords"
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
#$DEBUG=1
$body=(@{'username' = $wusername; 'password' = $wpassword} | ConvertTo-JSON)
$TOKEN_URI=$apiurl+"/auth.json"
$DSL_TOKEN = (Invoke-RestMethod -Uri $TOKEN_URI -Method Post -Body $body).token

#$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open() 
$readLimit = New-Object -TypeName PSObject 
Add-Member -InputObject $readLimit -MemberType NoteProperty `
        -Name lastIUN -Value "0"


$needNextPerson=1
$lost_pmids=$null
$not_pmids=$null
$lost_pmids=@{}
$not_pmids=@{}
$needStatistic=1
while ($needNextPerson -eq 1){
    $newPersons=$null
    if ($needStatistic -eq 1){
        foreach ($key in $lost_pmids.keys){
            $lostval=$lost_pmids[$($key)]
            $notval=$not_pmids[$($key)]
            $idval=$($key)
            write-host "$($key), lost $lostval no PMID $notval"
            SaveStatistic $sqlConnection $idval $lostval $notval
        }
        $lost_pmids=$null
        $not_pmids=$null
        $lost_pmids=@{}
        $not_pmids=@{}
    }
    $newPersons=GetPersons $sqlConnection $readLimit
    if ($newPersons.Equals($null)) {
        $needNextPerson=0
        continue
    }
    $skip=0
    $setlen=-1
    $dimsIDs=""
    foreach ($personLine in $newPersons){
        write-host "new personid "$personLine.DimpersonID
        $lost_pmids.add($personLine.DimpersonID,0)
        $not_pmids.add($personLine.DimpersonID,0)
        if ($dimsIDs.Length -eq 0) {$dimsIDs='"'+$personLine.DimensionsID+'"'} 
        else {$dimsIDs=$dimsIDs+","+'"'+$personLine.DimensionsID+'"'}
    }
#$DEBUG=1
    while  ( -not $setlen -eq 0){
        $searchRequest='search publications  where researchers.id in [ '+$dimsIDs +' ] '+' return publications[pmid+researchers] limit 1000 skip '+ $skip
        $searchRequest
        $DATA_URI=$apiurl+"/dsl.json"
        $jsonResult=Invoke-RestMethod -Uri $DATA_URI -Method Post -H @{Authorization = "JWT $DSL_TOKEN"} -Body $searchRequest
        $pubAuthors=""
        $setlen=$jsonResult.publications.Length
        write-host "setlen=" $setlen "_stat="$jsonResult._stats
        foreach($pub in $jsonResult.publications){
            $skip++
            $authorsList=GetAuthors $pub
            if ($DEBUG -eq 1){write-host "pmid="$pub.pmid}
            foreach ($personLine in $newPersons){
                if ($DEBUG -eq 1){write-host "checking id="$personLine.DimensionsID}
                if ($authorsList.ids.Contains($personLine.DimensionsID)){
                    if ([string]::IsNullOrEmpty($pub.pmid)) {
                        $not_pmids[$personLine.DimPersonID]++
                    }else{
                        if (-not $personLine.pmids.Contains($pub.pmid)){
                            $lost_pmids[$personLine.DimPersonID]++
                        }  
                    }
                    continue
                }
                continue
            }           
        }
    }
}
