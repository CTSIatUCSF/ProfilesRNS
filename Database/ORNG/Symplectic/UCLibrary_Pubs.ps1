function GetPublicationDetails([Data.SqlClient.SqlConnection] $sqlConnection,$doc){
     if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $persons=@()
    $records=$doc.feed.entry.object.records.ChildNodes
    foreach ($record in $records){
        if ($record.'source-name' -eq 'epmc') {
            $fields=@()
            $fields=$record.native.ChildNodes
            foreach ($field in $fields){
                if ($field.name -eq "external-identifiers") {
                    $identifiers=@()
                    $identifiers=$field.identifiers.ChildNodes
                    $PMID=""
                    $PCMID=""
                    foreach ($identifier in $identifiers){
                        if ($identifier.scheme -eq "pubmed"){$PMID=$identifier.InnerText}
                        if ($identifier.scheme -eq "pmc"){$PCMID=$identifier.InnerText}
                    } 
                }
                if ($field.name -eq "authors") {
                    $persons=$field.people.person
                    $authors=""
                    $ini=""
                    $lnm=""
                    foreach ($person in $persons ){
                        $data=@()
                        $data=$person.ChildNodes
                        foreach ($detail in $data){
                            $nln=$detail.Name
                            if ($nln -eq "api:last-name") {$lnm=$detail.InnerText}
                            if ($nln -eq "api:initials") {$ini=$detail.InnerText}
                        }
                        if (($ini+$lnm) -ne ""){
                            if ($authors -ne "") {
                                $authors=$authors+","
                            }
                            $authors=$authors+$lnm+" "+$ini
                        }
                        $ini=""
                        $lnm=""
                    }
                }            
            }
        }
    }
    $authors=$authors  -replace "'","''"
    $title=$doc.feed.entry.title
    $title=$title  -replace "'","''"
    #write-host "userName="$userName
    #write-host "lib_userid="$authorid
    #write-host "lib_pubid="$lib_pubid       
    #write-host "authors="$authors
    #write-host "title=" $title
    #write-host "PMID="$PMID
    #write-host "PCMID="$PCMID
    
    if (-not $PMID) {$col_PMID="NULL"} else {$col_PMID=$PMID}
    if (-not $PCMID) {$col_PCMID="NULL"} else {$col_PCMID="'"+$PCMID+"'"}
    if (-not $authors) {$col_authors="NULL"} else {$col_authors="'"+$authors+"'"}
    if (-not $title) {$col_title="NULL"} else {$col_title="'"+$title+"'"}
    #write-host "col_PMID="$col_PMID
    #write-host "col_PCMID="$col_PCMID
    #write-host "col_authors="$col_authors
    #write-host "col_title="$col_title
    $cmd="insert into [profiles_ucsf].[Symplectic.Elements].[Publication]"+
         " values ('$userName','$displayname',$authorid,$lib_pubid,$col_PMID,$col_PCMID,$col_authors,$col_title)"
    #write-host "!!!$cmd!!!"
    SQLExecuteCommand  $sqlConnection $cmd
}

function GetUserPublications($doc){
    $pubs=@()
    $i=0
    try {
      while ($true){
        $lib_pubid=$doc.feed.entry[$i].relationship.related.object.id
        if ("$lib_pubid" -eq ""){break}
        #    write-host $lib_pubid
        $pubs=$pubs+($lib_pubid  -join ",")
        $i++
      }
    } catch {
        $ErrorMessage = $_.Exception.Message
        get-date -f MM/dd/yyyy_HH:mm:ss
        write-host $ErrorMessage
    }
    return $pubs
}
function ReadXML($url){
    $xmlstr=""
    $webclient = new-object System.Net.WebClient
    $credCache = new-object System.Net.CredentialCache
    $creds = new-object System.Net.NetworkCredential($wusername,$wpassword) 
    $credCache.Add($url, "Basic", $creds)
    $webclient.Credentials = $credCache
    try {
    	$xmlstr=$webclient.DownloadString($url)
    	$start=$xmlstr.IndexOf(">")+1
    	$xmlstr=$xmlstr.Substring($start)
    	$xmlstr > 'D:\app\DesignSymplistic\data_utf8.txt'
    	return $xmlstr
    } catch {
        $ErrorMessage = $_.Exception.Message
        get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$ErrorMessage
    }
    return $result
}
function ReadUserNames ([Data.SqlClient.SqlConnection] $sqlConnection) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        "Select username,personid from [User.Account].[User] "+
	"where isActive=1 and personid is not NULL and username is not NULL"
    $reader = $sqlCommand.ExecuteReader()
    $lines=0
    while ($reader.Read())
    {
        $userNames=$userNames+($reader[“userName”]  -join ",")
        $personids=$personids+($reader["personid"] -join ",")
        $lines=$lines+1
        #if ($lines -ge 10 ) {break}      
    }
    return $userNames 
}

function InsertXML ([Data.SqlClient.SqlConnection] $sqlConnection,$key,$value) {
 
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        " INSERT INTO [Symplectic.Elements].[AllXML] (XmlCol,idtype,id )"+
        " SELECT CONVERT(XML, BulkColumn) AS BulkColumn,@idtype,@id "+ 
        " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\data_utf8.txt', SINGLE_BLOB) AS x;"
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@idtype",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@id",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters[0].Value = $key
    $sqlCommand.Parameters[1].Value = $value
    try{
        if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
            $sqlConnection.Open()
        }
        $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host "Exception processing typeid="$key" id"=$value
        $ErrorMessage = $_.Exception.Message
        get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$ErrorMessage
    }
}

function SQLExecuteCommand ([Data.SqlClient.SqlConnection] $sqlConnection,$command ) {
 
    try {
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText = $command
        if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
            $sqlConnection.Open()
        }
        $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host "Exception processing command"$command
        $ErrorMessage = $_.Exception.Message
        get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n$ErrorMessage
    }
}
 
# Open SQL connection (you have to change these variables)
$DBserver="stage-sql-ctsi.ucsf.edu"
$DBName="profiles_ucsf"
$dbuser="App_Profiles10"
$dbpassword="Password1234"
$wusername="ucsf"
$wpassword="t3PLMpzX98J"
$apiurl="https://qa-oapolicy.universityofcalifornia.edu:8002/elements-secure-api"
#$apiurl="https://oapolicy.universityofcalifornia.edu:8002/elements-secure-api"
$allpubids=@()



$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open()
 
# Quit if the SQL connection didn't open properly.
if ($sqlConnection.State -ne [Data.ConnectionState]::Open) {
    "Connection to DB is not open."
    Exit
}

$cmd="truncate table [profiles_ucsf].[Symplectic.Elements].[AllXML];truncate table [profiles_ucsf].[Symplectic.Elements].[Publication]"
SQLExecuteCommand  $sqlConnection $cmd

$userNames=@()
$personids=@()

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open()
$usernames=ReadUserNames $sqlConnection
#$userNames=$return[0]
#$personids=$return[1]

$sqlConnection.Close()
$sqlConnection.Open()
 
# Quit if the SQL connection didn't open properly.
if ($sqlConnection.State -ne [Data.ConnectionState]::Open) {
    "Connection to DB is not open."
    Exit
}




$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($wusername,$wpassword)
foreach ($userName in $userNames)
{
    $url=$apiurl+"/users?username="+$userName
    [string] $atem=ReadXML $url $userName
    if (-not $atem){ continue} #.Length -eq 0) 
    [xml]$doc =[xml] $atem
    $authorid=$doc.feed.entry.object.id
    if (-not $authorid){ continue}
    InsertXML $sqlConnection "UserName" $userName
    $displayname=$doc.feed.entry.title
    #$personid=$pcolersonids[$i]
    #write-host "author="$authorid ($displayname) "userName="$userName
    $url=$apiurl+"/users/"+$authorid+"/publications"
    [string] $atem=ReadXML $url
    if (-not $atem){continue}
    [xml]$doc=[xml] $atem
    InsertXML $sqlConnection "lib_authorid" $authorid    
#cmd /c pause | out-null
    $pubs=GetUserPublications $doc
    foreach ($lib_pubid in $pubs){
        $url=$apiurl+"/publications/"+$lib_pubid #1336238
	[string] $atem=ReadXML $url
    	if (-not $atem){continue} #
    	[xml]$doc=[xml] $atem
        $savedpub=0
        foreach ($pubid in $allpubids){
            if ($pubid -eq $lib_pubid) {
                $savedpub=1
                break
            }
            continue
        }
        if ($savedpub -eq 0){
            InsertXML $sqlConnection "lib_pubid" $lib_pubid
            $allpubids=$allpubids+($lib_pubid  -join ",")
        }
        #SQLExecuteCommand  $sqlConnection $cmd
        GetPublicationDetails $sqlConnection $doc
    }
}
if ($sqlConnection.State -eq [Data.ConnectionState]::Open) {$sqlConnection.Close()}   

 
