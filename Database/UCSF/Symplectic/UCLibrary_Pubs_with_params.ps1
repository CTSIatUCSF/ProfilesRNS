function GetPublicationDetails($doc){
    $persons=@()
    [System.Collections.ArrayList]$otherSources=@("doi","eissn","issn","scopus" ,"wos-lite" ,"crossref","c-inst-1","repec","isbn-13")
    $OtherDB="CDL"
    $OtherID=[string]$lib_pubid
    $OtherLink=$script:url
    
    $term=$doc.feed.category.term
    if ($term -eq "error-list") {
        $script:result="error"
        return
    }
    $keywords=$doc.feed.entry.object."all-labels".keywords.ChildNodes
    $concepts=""
    $delim=""
    foreach($keyword in $keywords){
        $base=$keyword.scheme
        if ($base-eq "") {$base=$keyword.source}
        $concepts=$concepts+$delim+"["+$base+"("+$keyword.InnerText+")]"
        $delim=","    
    }
    if ($DEBUG -eq 1){write-host "concepts="$concepts}
    $externalidentifiers_flag=1
    $authors_flag=1
    $records=$doc.feed.entry.object.records.ChildNodes
    $PMID_1=""
    $PMCID_1=""
    foreach ($record in $records){
        if ($record.'source-name' -eq 'pubmed') {
            $PMID_1=$record.'id-at-source'    
        }
        if ($record.'source-name' -eq 'epmc') {
            $PMCID_1=$record.'id-at-source'
        }
        $fields=@()
        $fields=$record.native.ChildNodes
        foreach ($field in $fields){
            if ($field.name -eq "external-identifiers" -and $externalidentifiers_flag) { 
                $externalidentifiers_flag=0
                $identifiers=@()
                $identifiers=$field.identifiers.ChildNodes
                $PMID_2=""
                $PMCID_2=""
                foreach ($identifier in $identifiers){
                    if ($identifier.scheme -eq "pubmed"){$PMID_2=$identifier.InnerText}
                    if ($identifier.scheme -eq "pmc"){$PMCID_2=$identifier.InnerText}
                }
            }
            if ($otherSources.Contains($field.name)) {
                if ($OtherDB -eq "" -or $OtherDB -eq "CDL"){
                    $otherDB=$field.name
                    $OtherID=$field.InnerText
                    foreach($link in $field.links.ChildNodes){
                        if ($link.type -eq $otherDB) {
                            $OtherLink=$link.href
                        }
                    }
                 }
            }
            if ($field.name -eq "authors" -and $authors_flag) {
                    $authors_flag=0
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
                            $authors=$authors+$lnm+":"+$ini
                        }
                        $ini=""
                        $lnm=""
                    }
                }            
            }
        #}
    }
    #$authors=$authors.replace(",","")
    $displayname=$displayname.replace(",","")
    $title=$doc.feed.entry.title
    $pubtype=$doc.feed.entry.object.type
    $title=$title  -replace "'","''"
    $PMID=$PMID_1
    if ($PMID -eq ""){$PMID=$PMID_2}
    $PMCID=$PMCID_1
    if ($PMCID -eq ""){$PMCID=$PMCID_2}
    if ($DEBUG -eq 1) {
        write-host "userName="$userName
        write-host "displayName="$displayName
        write-host "lib_userid="$authorid
        write-host "lib_pubid="$lib_pubid       
        write-host "authors="$authors
        write-host "title=" $title
        write-host "pubtype="$pubtype 
        write-host "PMID="$PMID
        write-host "PMCID="$PMCID
        write-host "Concepts="$Concepts
    }
    write-host "PMID="$PMID "END"
    if (-not $PMID) {$col_PMID=0} else {$col_PMID=$PMID}
    if (-not $PMCID) {$col_PMCID=""} else {$col_PMCID="'"+$PMCID+"'"}
    if (-not $authors) {$col_authors=""} else {$col_authors=$authors}
    if (-not $title) {$col_title=""} else {$col_title=$title}
    if (-not $pubtype) {$col_pubtype=""} else {$col_pubtype=$pubtype}
    if (-not $otherDB) {$col_otherDB=""} else {$col_otherDB=$otherDB}
    if (-not $otherid) {$col_otherid=""} else {$col_otherid=$otherid}
    if (-not $otherLink) {$col_otherLink=""} else {$col_otherLink=$otherLink}
    if (-not $Concepts) {$col_concepts=""} else {$col_concepts=$concepts}
    #if (-not $displayName) {$col_displayName=""} else {$col_displayName=$displayName}
    if ($DEBUG -eq 1) {
        write-host "col_PMID="$col_PMID
        write-host "col_PMCID="$col_PMCID
        write-host "col_authors="$col_authors
        write-host "col_title="$col_title
        write-host "col_pubtype="$col_pubtype
        write-host "col_otherDB="$col_otherDB
        write-host "col_otherid="$col_otherid
        write-host "col_otherLink="$col_otherLink
        write-host "col_otherid="$col_concepts
    }
    $script:authors=$col_authors
    #$script:fullName=$col_displayName
    $script:title=$col_title
    $script:PMID=$col_PMID
    $script:PMCID=$col_PMCID
    $script:pubtype=$col_pubtype
    $script:OtherDB=$col_otherDB
    $script:OtherID=$col_otherid
    $script:OtherLink=$col_otherLink
    $script:concepts=$col_concepts
}

function CalculateSavedPages ($sqlConnection,$lib_userid){
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $pubcount=0
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText =
        "Select lib_userid,count(lib_userid) as pagecount "+
        " from [Symplectic.Elements].[pagesXML] "+
        " where lib_userid=$lib_userid group by lib_userid "
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $pagecount=$reader[“pagecount”]
        }
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
    }
    return $pagecount
 }   
function CheckPMID_in_Harvard ($sqlConnection,$PMID){
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $pubcount=0
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText =
        "Select count(pmid) as pubcount "+
        " from [Profile.Data].[Publication.PubMed.AllXML] "+
        " where pmid="+$PMID
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $pubcount=$reader[“pubcount”]
        }
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
    }
    return $pubcount
}

function CalculateProcessedPublications ($sqlConnection,$username){
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $pubcount=0
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText =
        "Select username,count(username) as pubcount "+
        " from [Symplectic.Elements].[UserPublication] "+
        " where username='"+$username+"' group by username "
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $pubcount=$reader[“pubcount”]
        }
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
    }
    return $pubcount
}

function GetUserPublications($url){
  try {
   	$pageurl=$url
   	[int]$page=1
    if ($DEBUG -eq 1){write-host "connect to "$pageurl}
    #$result=""
    [string] $atem=ReadXML $pageurl
    #if (-not $atem) 
    [xml]$doc=[xml] $atem
    [int]$pubXMLcount=$doc.feed.pagination."results-count"
    [int]$pageDBcount= CalculateSavedPages $sqlConnection $lib_userid
    if ($pageDBcount -eq 0) {
        InsertPagesXML $sqlConnection $lib_userid $page
    }
    [int]$pubDBcount= CalculateProcessedPublications $sqlConnection $username
    if ($pubDBcount -eq $pubXMLcount){ return }
    if ($pubDBcount -ne $pubXMLcount -and $pubDBcount -ge 1){
        $cmd="delete [Symplectic.Elements].[pagesXML] where lib_userid="+$lib_userid 
        SQLExecuteCommand  $sqlConnection $cmd
    }
    
    InsertPagesXML $sqlConnection $lib_userid $page
	$data=@()
	$data=$doc.feed.pagination.ChildNodes
    [int]$pubcount=$doc.feed.pagination."results-count"
	$data
    write-host "++each in data++"
    [int]$mythis=1
    [int]$next=1
    [int]$last=1
    foreach ($element in $data) {
			if ($DEBUG -eq 1) {write-host $element.position "=" $element.number}
			if ($element.position -eq "this"){$mythis=[int]$element.number}
			if ($element.position -eq "next"){$next=[int]$element.number}
			if ($element.position -eq "last"){$last=[int]$element.number}
	}
	while ($page -le $last){
	  if ($DEBUG -le 1){write-host "page=" $page "next" $next "last" $last}
	  $i=0
      while ($true){
         write-host "i=" $i
         $test=$doc.feed.entry[$i]
         if (-not $test){
            if ($i -eq 0){$test=$doc.feed.entry}
            else {break}
         }
         $lib_pubid=$test.relationship.related.object.id
         write-host "lib_pubid=" $lib_pubid
         if ("$lib_pubid" -eq ""){break} # -or !$pubids.Contains($lib_pubid) 
         if ($DEBUG -eq 1) {    write-host $lib_pubid}
         $script:pubs=$script:pubs+($lib_pubid  -join ",")
         if ($DEBUG -eq 1) {write-host "added new pub " $lib_pubid "for "$username" got pubs="$script:pubs}
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
      InsertPagesXML $sqlConnection $lib_userid $page
      
    }         
  } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      write-host `n$hh   $ErrorMessage
  }
  if ($DEBUG -eq 1){write-host "GetUserPublications returning pubs=" $script:pubs}
  #return $pubs
}

function ReadXML($url){
    $xmlstr=""
    $webclient = new-object System.Net.WebClient
    $credCache = new-object System.Net.CredentialCache
    $creds = new-object System.Net.NetworkCredential($wusername,$wpassword) 
    $credCache.Add($url, "Basic", $creds)
    $webclient.Credentials = $credCache
    $retstr=""
    try {
    	$xmlstr=$webclient.DownloadString($url)
    	$start=$xmlstr.IndexOf(">")+1
    	$xmlstr=$xmlstr.Substring($start)
    	$xmlstr > 'D:\app\DesignSymplistic\data_utf8.txt'
    	write-host "we actually read xmlstr"
     	$retstr= $xmlstr
    } catch {
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh   $ErrorMessage
    }
    $webclient.Dispose() #!!!!!!!!
    return $retstr
}

function ReadPublicationIds ([Data.SqlClient.SqlConnection] $sqlConnection) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        "Select lib_pubid from [Symplectic.Elements].[pubXML] "
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    while ($reader.Read())
    {
        $num=$script:allpubids.Add($reader[“lib_pubid”])
    }
    $reader.Close()
    if ($DEBUG -eq 1) {write-host "number of publications in allpubids=" $script:allpubids.Count}
} 

function ReadUserNames ([Data.SqlClient.SqlConnection] $sqlConnection) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        "Select username,personid from [User.Account].[User] "+
	"where isActive=1 and personid is not NULL and username is not NULL "
    if ($users4db -ne "") {
        $sqlCommand.CommandText=$sqlCommand.CommandText+" and username in "+$users4db+";"
    } else {
        $sqlCommand.CommandText=$sqlCommand.CommandText+";"
    }
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    $lines=$script:limit
    while ($reader.Read())
    {
        $script:userNames=$script:userNames+($reader[“userName”]  -join ",")
        $script:personids=$script:personids+($reader["personid"] -join ",")
        if ($script:limit -ge 0) {
            $lines=$lines-1
            if ($lines -le 0) {break}
        }      
    }
    #$script:usernames+("111650@ucsf.edu"  -join ",")
    $script:userNames+("nobody@ucsf.edu"  -join ",")
    ## Call Close when done reading.
    $reader.Close();
    if ($DEBUG -eq 1) {write-host "number of users in usernames" $usernames.Count}
    #return $userNames 
}

function InsertImportAuthor ([Data.SqlClient.SqlConnection] $sqlConnection,$lib_pubid,$personid,$authors,$author_fullname){
if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $authorslist= $authors  -split ','
    $j=1
    while ($j -le $authorslist.Count) {
        $currentauthor=$authorslist[$j-1] -split(":")
        $lastname=$currentauthor[0]
        $Initials=$currentauthor[1]
        $initial_name=$initials.substring(0,1)
        $authorid=[DBNull]::Value
        $author_lastname=$author_fullname.split(" ")[0]
        $author_initials=$author_fullname.split(" ")[1]
        $author_name_first=""
        $author_name_fore=""
        if ($lastname -eq $author_lastname){
            if ($author_initials.Length -ge 1){
                $author_name_first=$author_initials.substring(0,1)
                $author_name_fore=$author_initials.replace($author_name_first,"")
            }         
            if (($initials -eq $author_initials) -or ($initial_name -eq $author_name_first)){
                $authorid=$personid
            }
        }
        $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
        $sqlCommand.Connection = $sqlConnection
        $sqlCommand.CommandText = 
                " INSERT INTO [Profile.Data].[Publication.Import.Author] "+
                "(ImportPubID,personID,AuthorRank, Lastname, FirstName,ForeName,Fullname, AuthorName) "+
		        " VALUES (-cast(@lib_pubid as int),@authorid,@authorRank,@lastname,@firstname,@forename, @fullname, @authorName) "
        $sqlcommand.CommandTimeout=120
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lib_pubid",[Data.SQLDBType]::VarChar, 30))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@authorid",[Data.SQLDBType]::Integer))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@authorRank",[Data.SQLDBType]::Integer))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lastname",[Data.SQLDBType]::VarChar, 100))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@firstname",[Data.SQLDBType]::VarChar, 250))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@forename",[Data.SQLDBType]::VarChar, 250))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@fullname",[Data.SQLDBType]::VarChar, 250))) | Out-Null
        $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@authorname",[Data.SQLDBType]::VarChar, 100))) | Out-Null
        $sqlCommand.Parameters[0].Value = $lib_pubid
        $sqlCommand.Parameters[1].Value = $authorid
        $sqlCommand.Parameters[2].Value = $j
        $sqlCommand.Parameters[3].Value = $lastname
        $sqlCommand.Parameters[4].Value = $author_name_first
        $sqlCommand.Parameters[5].Value = $author_name_fore
        $sqlCommand.Parameters[6].Value = $lastname+" "+$Initials
        $sqlCommand.Parameters[7].Value = $lastname+" "+$Initials
        try{
            if ($DEBUG -eq 1) {write-host $sqlCommand.CommandText} 
            $InsertedID = $sqlCommand.ExecuteScalar()
        } catch {
            write-host $_.Exception.Message" processing lib_pubid=$lib_pubid($lastname $initials)"
            $ErrorMessage = $_.Exception.Message
            $hh=get-date -f MM/dd/yyyy_HH:mm:ss
            write-host `n"URL"$url
        }
        $j++
    }
}


function InsertImportPubData ([Data.SqlClient.SqlConnection] $sqlConnection,$lib_pubid){
if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
                "(SELECT * FROM [Profile.Data].[Publication.Import.PubData] where importPubID=-"+$lib_pubid +" ) "+ 
              "BEGIN "+
                " INSERT INTO [Profile.Data].[Publication.Import.PubData] (ImportPubID,ActualIDType, ActualID, X,URL) "+
		        " SELECT -cast(@lib_pubid as int), OtherDB, OtherID, XmlCol,OtherLink "+
		        "  from [Symplectic.Elements].[pubXML] where lib_pubid="+$lib_pubid +
              " END "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lib_pubid",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters[0].Value = $lib_pubid
    
    try{
         $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message" processing lib_pubid="$lib_pubid
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
    }
}

function InsertUserXML ([Data.SqlClient.SqlConnection] $sqlConnection,$username,$lib_userid,$userdisplayname) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
                "(SELECT * FROM   [Symplectic.Elements].[UserXML] WHERE  username = '"+$username+"' ) "+ 
              "BEGIN "+
                " INSERT INTO [Symplectic.Elements].[userXML] (XmlCol,username,lib_userid,displayname,createdDT)"+
                " SELECT CONVERT(XML, BulkColumn) AS BulkColumn,@username,@lib_userid,@displayname,getdate() "+ 
                " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\data_utf8.txt', SINGLE_BLOB) AS x " +
              "END "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@username",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lib_userid",[Data.SQLDBType]::Varchar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@displayname",[Data.SQLDBType]::Varchar, 100))) | Out-Null
    $sqlCommand.Parameters[0].Value = $username
    $sqlCommand.Parameters[1].Value = $lib_userid
    $sqlCommand.Parameters[2].Value = $userdisplayname
    try{
         $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message" processing username="$username "lib_userid="$lib_userid
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
    }
}


function InsertPagesXML ([Data.SqlClient.SqlConnection] $sqlConnection,$key1,$key2) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    write-host "key1="$key1" key2="$key2
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "IF NOT EXISTS "+
                "(SELECT * FROM   [Symplectic.Elements].[pagesXML] WHERE lib_userid=@lib_userid and page=@page ) "+ 
              "BEGIN "+
        " INSERT INTO [Symplectic.Elements].[pagesXML] (lib_userid,page,XmlCol,createdDT)"+
        " SELECT @lib_userid,@page,CONVERT(XML, BulkColumn) AS BulkColumn,getdate() "+ 
        " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\data_utf8.txt', SINGLE_BLOB) AS x "+
        "END "
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lib_userid",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@page",[Data.SQLDBType]::integer))) | Out-Null
    $sqlCommand.Parameters[0].Value = $key1
    $sqlCommand.Parameters[1].Value = $key2
    try{
         $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message " processing lib_userid="$key1 "page="$key2
        $ErrorMessage = $_.Exception.Message
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh   $ErrorMessage
    }
}

function InsertPubXML ([Data.SqlClient.SqlConnection] $sqlConnection,$lib_pubid,$pubtype,$title,$authors,$PMID,$PMCID,$OtherDB,$OtherID,$OtherLink,$concepts) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
            $sqlConnection.Open()
    }
    if ($PMID -eq 0) {$PMID=[DBNull]::Value}
    if ($PMCID -eq ""){$PMCID=[DBNull]::Value}
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "SET NOCOUNT ON; " +
        "if not exists (select * from  [Symplectic.Elements].[PubXML] where lib_pubid=@lib_pubid)"+
        " begin "+
        " INSERT INTO [Symplectic.Elements].[PubXML] (XmlCol,lib_pubid,pubtype,title,authors,PMID,PMCID,concepts,OtherDB,OtherID,OtherLink,createdDT )"+
        " SELECT CONVERT(XML, BulkColumn) AS BulkColumn,@lib_pubid,@pubtype,@title,@authors,@PMID,@PMCID,@concepts,@OtherDB,@OtherID,@OtherLink,getdate() "+ 
        " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\data_utf8.txt', SINGLE_BLOB) AS x"+
        " end;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@lib_pubid",[Data.SQLDBType]::VarChar, 30))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@pubtype",[Data.SQLDBType]::VarChar, 60))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@title",[Data.SQLDBType]::VarChar, 600))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@authors",[Data.SQLDBType]::VarChar, 500))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PMID",[Data.SQLDBType]::SqlDbType.Int))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PMCID",[Data.SQLDBType]::VarChar, 55))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@concepts",[Data.SQLDBType]::VarChar, 500))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OtherDB",[Data.SQLDBType]::VarChar, 4000))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OtherID",[Data.SQLDBType]::VarChar, 4000))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@OtherLink",[Data.SQLDBType]::VarChar, 4000))) | Out-Null
    $sqlCommand.Parameters[0].Value = $lib_pubid
    $sqlCommand.Parameters[1].Value = $pubtype
    $sqlCommand.Parameters[2].Value = $title
    $sqlCommand.Parameters[3].Value = $authors
    $sqlCommand.Parameters[4].Value = $PMID
    $sqlCommand.Parameters[5].Value = $PMCID
    $sqlCommand.Parameters[6].value = $concepts
    $sqlCommand.Parameters[7].Value = $OtherDB
    $sqlCommand.Parameters[8].Value = $OtherID
    $sqlCommand.Parameters[9].Value = $OtherLink
    
    try{
        $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message "processing lib_pubid="$lib_pubid
        $hh=get-date -f MM/dd/yyyy_HH:mm:ss
        write-host `n"URL"$url
        write-host `n$hh  $ErrorMessage
    }
}

function ProcessPMID ([Data.SqlClient.SqlConnection] $sqlConnection,$PMID,$personid) {
    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
            $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection
    $sqlCommand.CommandText = "INSERT INTO [Profile.Data].[Publication.PubMed.AllXML] (PMID,X) "+
			         " SELECT cast(@PMID as varchar),CONVERT(XML, BulkColumn) AS BulkColumn "+
			         " FROM OPENROWSET(BULK 'D:\app\DesignSymplistic\pmid.txt', SINGLE_BLOB) AS x;"+
                     " EXEC [Profile.Data].[Publication.Pubmed.AddPublication] @PersonID,@PMID;"
    $sqlcommand.CommandTimeout=120
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PMID",[Data.SQLDBType]::SqlDbType.Int))) | Out-Null
    $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PersonID",[Data.SQLDBType]::SqlDbType.Int))) | Out-Null
    $sqlCommand.Parameters[0].Value = $PMID
    $sqlCommand.Parameters[1].Value = $personid
    write-host $sqlCommand.CommandText
    try{
        $InsertedID = $sqlCommand.ExecuteScalar()
    } catch {
        write-host $_.Exception.Message "processing lib_pubid="$lib_pubid
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

 
## !!!!!!!!! THIS IS START OF SCRIPT !!!!!!!!!!!!!! 
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
[System.Collections.ArrayList]  $userslist=@()
$users4db=""
$force=""
$DEBUG=0
$limit=-1
#$params="-users", "028953@ucsf.edu,gogo@ucsf.edu,000983@ucsf.edu,nobody@ucsf.edu"
#$params="-limit", "10"
$params="-users","000983@ucsf.edu,013675@ucsf.edu,000732@ucsf.edu,002741@ucsf.edu,001710@ucsf.edu"
while ($i -lt $params.Length) {
    if ($params[$i] -eq "-debug"){
        $DEBUG=1
    } 
    if ($DEBUG -eq 1) {
        write-host "i="$i
        write-host "current arg=" $params[$i] "==" $params[$i+1]
    }
    if ($params[$i] -eq "-limit") {
        [int]$limit=$params[$i+1]
        $i=$i+2
        continue
    }
    if ($params[$i] -eq "-users") {
        $users=$params[$i+1]
        if ($users -ne "all"){
            $userslist= $users  -split ','
            $j=0
            while ($j -lt $userslist.Count) {
                if ($j -eq $userslist.Count-1) {
                    $users4db=$users4db+"'"+$userslist[$j]+"'"
                } else {
                    $users4db=$users4db+"'"+$userslist[$j]+"',"
                }
                $j++
            }
            $users4db="("+$users4db+")"
        
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
    $i++
}
write-host "params="$params "limit="$limit "debug="$DEBUG "users"=$users
#cmd /c pause | out-null 




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
         "truncate table [Symplectic.Elements].[PagesXML];"+
         "truncate table [Symplectic.Elements].[UserPublication];"
}else{

}

if ($cmd -ne ""){
    SQLExecuteCommand  $sqlConnection $cmd
}


$userNames=@()
$personids=@()
$publications=@()
[System.Collections.ArrayList]$pubids=@()
[System.Collections.ArrayList]$allpubids=@()

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open()
#$usernames=
ReadUserNames $sqlConnection
#$pubids=
ReadPublicationIds $sqlConnection
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
$pos=0
foreach ($userName in $userNames)
{
    $personid=$personids[$pos]
    $pos++
    $url=$apiurl+"/users?username="+$userName
    
    [string] $atem=ReadXML $url $userName
    if (-not $atem -or $atem.Trim().Length -eq 0){ continue} #.Length -eq 0) 
    [xml]$doc =[xml] $atem
    $lib_userid=$doc.feed.entry.object.id
    if (-not $lib_userid){
		if ($DEBUG -eq 1) {write-host "not found username=" $username}
		$foundid="0"
		continue
	}
    $displayname=$doc.feed.entry.title
	InsertUserXML $sqlConnection $userName $lib_userid $displayname

    
    
    $authors=""
    $fullName=""
    $title=""
    $pubtype=""
    $PMID=""
    $PMCID=""
    $concepts=""
    $OtherDB=""
    $OtherID=""
    $OtherLink=""
    if ($DEBUG -eq 1) {write-host "author="$lib_userd ($displayname) "userName="$userName}
    write-host "displayName=<"$displayName
    $displayList=$displayName.split(",")
    $author_lastname=$displayList[0]
    $author_initial1=$displayList[1].substring(1,1)
    write-host "initial1=<"$author_initial1
    $author_initial2=$displayList[1].remove(0,1).split(" ")[1].substring(0,1)
    write-host "initial2=<"$author_initial2
    $author_fullname=$author_lastname+" "+$author_initial1+$author_initial2
    write-host "fullname=<"$author_fullname
    $url=$apiurl+"/users/"+$lib_userid+"/publications"
    $pubs=@()
    GetUserPublications $url 
  
#cmd /c pause | out-null    
    if ($DEBUG -eq 1) {write-host "for "$username" got newpubs="$pubs}
    #exit
    if (-not $pubs -or $pubs.Lenght -eq 0 -or $pubs -eq "Exception") { continue}
#continue
#in order to have only list of UCSF to compare with CDL usernames
    foreach ($lib_pubid in $pubs){
		if($lib_pubid -match "^[0-9]*$" -and $lib_pubid -gt 0 ) {
			write-host $lib_pubid "is int"
		}else {
		    # -or $lib_pubid -eq "" -or [string]::IsNullOrEmpty($lib_pubid) 
			write-host "skipping empty " $lib_pubid " to avoid 404 error" 
			continue
		}
        $url=$apiurl+"/publications/"+$lib_pubid #1336238
    	[string] $atem=ReadXML $url
    	if (-not $atem){continue} #
    	[xml]$doc=[xml] $atem
        $result=""
        $savedpub=0
        GetPublicationDetails($doc)
        write-host "result="$result
        if ($result -eq "Error"){
            $savedpub=1
        }else{
           $cmd="IF NOT EXISTS "+
                "(SELECT * FROM   [Symplectic.Elements].[UserPublication] "+
                  "WHERE  username = '"+$username+"' and lib_pubid='"+$lib_pubid+"') "+ 
              "BEGIN "+
                    "insert into [Symplectic.Elements].[UserPublication] 	(username,personid,lib_pubid) values "+
                    "('"+$username+"'"+","+$personid+",'"+$lib_pubid+"')"+
              " END" 
          SQLExecuteCommand  $sqlConnection $cmd
        }
        if ($script:allpubids.Contains($lib_pubid)){ #foreach ($pubid in $allpubids){  # trying to get dup pubid
           $savedpub=1
           continue
        }
        if ($savedpub -eq 0){
            InsertPubXML $sqlConnection $lib_pubid $pubtype $title $authors $PMID $PMCID $OtherDB $OtherID $OtherLink $concepts
            $script:allpubids.Add($lib_pubid)
            $pubids.Add($lib_pubid)
            write-host "added pubid=" $lib_pubid "into pubids.Now count=" $allpubids.Count
        }
        if ($PMID -eq 0){
            InsertImportPubData $sqlConnection $lib_pubid
            InsertImportAuthor $sqlConnection $lib_pubid $personid $authors $author_fullname
        } else {
            #check if this PMID been processed by looking into Publication.PubMed.AllXML table
            #we may need to check if particular personid has this publication
            #if no PMID in AllXML, read it from NIH site
            $pmidExists=CheckPMID_in_Harvard $sqlConnection $PMID
            if ($pmidExists -eq 0){
                $NIHwebclient = new-object System.Net.WebClient
                $FILE="D:\app\DesignSymplistic\PMID.txt"
                $marker="PubmedArticle"
                $NIHurl="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmax=1000&db=pubmed&retmode=xml&id="
                $PMIDurl=$NIHurl+$PMID
                $ErrorMessage=""
                try {
    	           $xmlstr=$NIHwebclient.DownloadString($PMIDurl)
    	           $start=$xmlstr.IndexOf("<"+$marker+">")-1
                   $finish=$xmlstr.IndexOf("</"+$marker+">")-1 #+$marker.Lenght
                   $xmlstr=$xmlstr.Substring($start+1,$finish-$start)+"</"+$marker+">"
    	           $xmlstr > $FILE
                } catch {
                    $ErrorMessage = $_.Exception.Message
                    $hh=get-date -f MM/dd/yyyy_HH:mm:ss
                    write-host `n"URL"$url
                    write-host `n$hh   $ErrorMessage
                }
                if ($ErrorMessage -eq "") {
                    ProcessPMID $sqlconnection $PMID $personid
                }
            }
        }
     }
    $pubs=@()
}
if ($sqlConnection.State -eq [Data.ConnectionState]::Open) {$sqlConnection.Close()}   

 

