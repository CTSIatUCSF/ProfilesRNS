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
    $displayname=$displayname -replace "'","''"
    $title=$doc.feed.entry.title
    $title=$title  -replace "'","''"
    if ($DEBUG -eq 1) {
        write-host "userName="$userName
        write-host "lib_userid="$authorid
        write-host "lib_pubid="$lib_pubid       
        write-host "authors="$authors
        write-host "title=" $title
        write-host "PMID="$PMID
        write-host "PCMID="$PCMID
    }
    if (-not $PMID) {$col_PMID="NULL"} else {$col_PMID=$PMID}
    if (-not $PCMID) {$col_PCMID="NULL"} else {$col_PCMID="'"+$PCMID+"'"}
    if (-not $authors) {$col_authors="NULL"} else {$col_authors="'"+$authors+"'"}
    if (-not $title) {$col_title="NULL"} else {$col_title="'"+$title+"'"}
    if ($DEBUG -eq 1) {
        write-host "col_PMID="$col_PMID
        write-host "col_PCMID="$col_PCMID
        write-host "col_authors="$col_authors
        write-host "col_title="$col_title
    }
    $cmd="insert into [profiles_ucsf].[Symplectic.Elements].[Publication]"+
         " values ('$userName','$displayname',$authorid,$lib_pubid,$col_PMID,$col_PCMID,$col_authors,$col_title)"
    if ($DEBUG -eq 1) {write-host "!!!$cmd!!!"}
    SQLExecuteCommand  $sqlConnection $cmd
}

function GetUserPublications($url){
  try {
    $pubs=@()
   	$pageurl=$url
   	[int]$page=1
    if ($DEBUG -eq 1){write-host "connect to "$pageurl}
    [string] $atem=ReadXML $pageurl
    #if (-not $atem) 
    [xml]$doc=[xml] $atem
    InsertUserXML $sqlConnection $userName $authorid $page
	$data=@()
	$data=$doc.feed.pagination.ChildNodes
	$data
    write-host "++each in data++"
    [int]$this=1
    [int]$next=1
    [int]$last=1
    foreach ($element in $data) {
			if ($DEBUG -eq 1) {write-host $element.position "=" $element.number}
			if ($element.position -eq "this"){$this=[int]$element.number}
			if ($element.position -eq "next"){$next=[int]$element.number}
			if ($element.position -eq "last"){$last=[int]$element.number}
	}
	while ($page -le $last){
	  if ($DEBUG -le 1){write-host "page=" $page "next" $next "last" $last}
	  $i=0
      while ($true){
         write-host "i=" $i
         $doc.feed.entry[$i]
         $lib_pubid=$doc.feed.entry[$i].relationship.related.object.id
         write-host "lib_pubid=" $lib_pubid
         if ("$lib_pubid" -eq ""){break}
         if ($DEBUG -eq 1) {    write-host $lib_pubid}
         $pubs=$pubs+($lib_pubid  -join ",")
         if ($DEBUG -eq 1) {write-host "added new pub " $lib_pubid "for "$username" got pubs="$pubs}
         $i++
      }
      $btem=""
      if ($page -lt $next) {
			$page=$next
      }else{
		    $page++
		    if ($page -gt $last) {break}
      }
      $pageurl=$url+"?page="+[string]$page	
	  if ($DEBUG -eq 1){write-host "connecting to "$pageurl}
      [string] $btem=ReadXML $pageurl
      [xml]$doc=[xml] $btem
      InsertUserXML $sqlConnection $userName $authorid $page
#cmd /c pause | out-null  
    }         
  } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
      $pubs="0"
  }
  if ($DEBUG -eq 1){write-host "GetUserPublications returning pubs=" $pubs}
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
    	write-host "we actually read xmlstr"
     	return $xmlstr
    } catch {
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh   $ErrorMessage
        return ""
    }
}
function ReadUserNames ([Data.SqlClient.SqlConnection] $sqlConnection) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        "Select username,personid from [User.Account].[User] "+
	"where isActive=1 and personid is not NULL and username is not NULL "+
		"and username not in ( SELECT idtype FROM [Symplectic.Elements].[userXML] "+
			" where id not like '%@%' and [page]=1 )"
    if ($users4db -ne "") {
        $sqlCommand.CommandText=$sqlCommand.CommandText+" and username in "+$users4db+";"
    } else {
        $sqlCommand.CommandText=$sqlCommand.CommandText+";"
    }
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    $lines=0
    while ($reader.Read())
    {
        $userNames=$userNames+($reader[“userName”]  -join ",")
        $personids=$personids+($reader["personid"] -join ",")
        $lines=$lines+1
        #if ($DEBUG -eq 1) {if ($lines -ge 100) {break}}      
    }
    $userNames=$userNames+("nobody@ucsf.edu"  -join ",")
    if ($DEBUG -eq 1) {write-host "number of users" $usernames.Count}
    return $userNames 
}

function InsertUserXML ([Data.SqlClient.SqlConnection] $sqlConnection,$key1,$key2,$key3) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        " INSERT INTO [Symplectic.Elements].[UserXML] (XmlCol,idtype,id,page,createdDT,updatedDT)"+
        " SELECT CONVERT(XML, BulkColumn) AS BulkColumn,@idtype,@id,@page,getdate(),getDate() "+ 
        " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\data_utf8.txt', SINGLE_BLOB) AS x;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@idtype",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@id",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@page",[Data.SQLDBType]::integer))) | Out-Null
    $sqlCommand.Parameters[0].Value = $key1
    $sqlCommand.Parameters[1].Value = $key2
    $sqlCommand.Parameters[2].Value = $key3
    try{
         $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host "Exception processing typeid="$key1" id"=$key2 "page="$key3
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh   $ErrorMessage
    }
}

function InsertPubXML ([Data.SqlClient.SqlConnection] $sqlConnection,$key,$value) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
            $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        "if not exists (select * from  [Symplectic.Elements].[PubXML] where idtype=@val1 and id=@val2)"+
        " begin "+
        " INSERT INTO [Symplectic.Elements].[PubXML] (XmlCol,idtype,id,createdDT,updatedDT )"+
        " SELECT CONVERT(XML, BulkColumn) AS BulkColumn,@idtype,@id,getdate(),getdate() "+ 
        " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\data_utf8.txt', SINGLE_BLOB) AS x"+
        " end;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@val1",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@val2",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@idtype",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@id",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters[0].Value = $key
    $sqlCommand.Parameters[1].Value = $value
    $sqlCommand.Parameters[2].Value = $key
    $sqlCommand.Parameters[3].Value = $value
    try{
        $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host "Exception processing typeid="$key" id"=$value
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh  $ErrorMessage
    }
}


function SQLExecuteCommand ([Data.SqlClient.SqlConnection] $sqlConnection,$command ) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
      $sqlConnection.Open()
    }
    try {
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText = $command
        $sqlcommand.CommandTimeout=120
        $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host "Exception processing command"$command
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n$hh   $ErrorMessage
    }
}
 
# Open SQL connection (you have to change these variables)
$tableKeys=""
$tableValues=""
write-host "count=" $args.count "arguments=" $args
$params=$args[0..($args.count-1)]
write-host "params="$params

# Take settings from config file
if ($PWD) {$myDir=$PWD}
if ($MyInvocation) {
    $myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
[xml]$ConfigFile = Get-Content "$MyDir\Symplectic.xml"

$DBserver=$ConfigFile.Settings.Database.DBServer
$DBName=$ConfigFile.Settings.Database.DBName 
$dbuser=$ConfigFile.Settings.Database.DBUser 
$dbpassword=$ConfigFile.Settings.Database.DBPassword 
$wusername=$ConfigFile.Settings.WebService.WSUser
$wpassword=$ConfigFile.Settings.WebService.WSPassword 
$apiurl=$ConfigFile.Settings.WebService.URL 

$i=0
$users=""
$userslist=@()
$users4db=""
$force=""
$DEBUG=0
#$params="-users", "028953@ucsf.edu,gogo@ucsf.edu,000983@ucsf.edu,nobody@ucsf.edu"
while ($i -lt $params.Length) {
    if ($DEBUG -eq 1) {
        write-host "i="$i
        write-host "current arg=" $params[$i] "==" $params[$i+1]
    }
    if ($params[$i] -eq "-users") {
        $users=$params[$i+1]
        if ($users -ne "all"){
            $userslist= $users  -split ','
            $j=0
            while ($j -lt $userslist.Length) {
                if ($j -eq $userslist.Length-1) {
                    $users4db=$users4db+"'"+$userslist[$j]+"'"
                } else {
                    $users4db=$users4db+"'"+$userslist[$j]+"',"
                }
                $j++
            }
            $users4db="("+$users4db+")"
            $DEBUG=1
        }
        if ($DEBUG -eq 1) {
            write-host "users="$users
            write-host "userslist="$userslist
            write-host "users4db="$users4db
        }
        $i=$i+2
        continue
    }
    if ($params[$i] -eq "-force") {
        $force="true"
    }
    if ($params[$i] -eq "-debug"){
        $DEBUG=1
    } 
    $i++
}

$allpubids=@()



$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open()
 
# Quit if the SQL connection didn't open properly.
if ($sqlConnection.State -ne [Data.ConnectionState]::Open) {
    "Connection to DB is not open."
    #Exit
}

$cmd=""
if ($DEBUG -eq 1) {
    write-host "DB preparation"
    write-host "users="$users
    write-host "force="$force
}
if ($users -eq "all" -and $force -ne "") {
    if ($DEBUG -eq 1) {write-host "Truncating DB tables"}
    $cmd="truncate table [Symplectic.Elements].[UserXML];" +
         "truncate table [Symplectic.Elements].[PubXML];"+
         "truncate table [Symplectic.Elements].[Publication];"
}
if ($users4db -ne "") {
    if ($DEBUG -eq 1) {write-host "Deleting existing users"}
    $cmd="delete [Symplectic.Elements].[UserXML] where idtype in "+$users4db+
         " or (idtype="+"'"+"UserName"+"'"+" and id in "+$users4db+
         " ); delete [Symplectic.Elements].[Publication] where username in "+$users4db+";"
}

if ($cmd -ne ""){
    SQLExecuteCommand  $sqlConnection $cmd
}


$userNames=@()
$personids=@()

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open()
$usernames=ReadUserNames $sqlConnection
write-host $usernames


$sqlConnection.Close()
#Exit
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
    if (-not $atem -or $atem.Trim().Length -eq 0){ continue} #.Length -eq 0) 
    [xml]$doc =[xml] $atem
    $authorid=$doc.feed.entry.object.id
    if (-not $authorid){
		if ($DEBUG -eq 1) {write-host "not found username=" $username}
		$foundid="0"
		InsertUserXML $sqlConnection "0" $userName 0
		continue
	}
    InsertUserXML $sqlConnection $authorid $userName 0
    $displayname=$doc.feed.entry.title
    if ($DEBUG -eq 1) {write-host "author="$authorid ($displayname)- "userName="$userName}
    $url=$apiurl+"/users/"+$authorid+"/publications"
    $newpubs=@()
    $newpubs=GetUserPublications $url 
#cmd /c pause | out-null    
    if ($DEBUG -eq 1) {write-host "for "$username" got newpubs="$newpubs}
    #exit
    if (-not $newpubs -or $newpubs.Lenght -eq 0 -or $newpubs -eq "Exception") { continue}
#continue
#in order to have only list of UCSF to compare with CDL usernames
    foreach ($lib_pubid in $newpubs){
		if($lib_pubid -match "^[0-9]*$" -or $lib_pubid -eq "" -or [string]::IsNullOrEmpty($lib_pubid) ){
			write-host $lib_pubid "is int"
		}else {
			continue
		}
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
            InsertPubXML $sqlConnection "lib_pubid" $lib_pubid
            $allpubids=$allpubids+($lib_pubid  -join ",")
        }
        #SQLExecuteCommand  $sqlConnection $cmd
        GetPublicationDetails $sqlConnection $doc
    }
}
if ($sqlConnection.State -eq [Data.ConnectionState]::Open) {$sqlConnection.Close()}   

 
