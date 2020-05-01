Function GetPMIDs {
    param ( [System.Data.SqlClient.SqlConnection] $sqlConnection)

    if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
        $sqlConnection.Open()
    }
    $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
    $sqlCommand.Connection = $sqlConnection

    $ListData=@()
    $sqlCommand.CommandText =  " select * from PubmedXMLListForDisambiguation " 
    $sqlcommand.CommandTimeout=120
    $reader = $sqlCommand.ExecuteReader()
    try {
        while ($reader.Read())
        {
            $rPmid=$reader[“pmid”]
            $ListData +=$rPmid
        }
        $reader.Close()
    } catch {
      $ErrorMessage = $_.Exception.Message
      $hh=get-date -f MM/dd/yyyy_HH:mm:ss
      if ($DEBUG -eq 1){write-host `n$hh   $ErrorMessage}
    }
  
    return $ListData
}


$params=$args[0..($args.count-1)]
if ($params.count -eq 0){
 write-host "To connect DB, call must be ""getPMID.ps1 <xml file in same directory with DB connection parameters>"""
 exit
}
if ($PWD) {$myDir=$PWD}
if ($MyInvocation) {
    $myDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}     
$xmlstr=""

$ff=$params[0]
[xml]$ConfigFile = Get-Content "$MyDir\$ff"

$DBserver=$ConfigFile.Settings.Database.DBServer
$DBName=$ConfigFile.Settings.Database.DBName 
$dbuser=$ConfigFile.Settings.Database.DBUser 
$dbpassword=$ConfigFile.Settings.Database.DBPassword

$pmidList=@()
$sqlConnection = new-object System.Data.SqlClient.SQLConnection("Data Source=$DBserver;Initial Catalog=$DBName;User ID=$dbuser;Password=$dbpassword");
$sqlConnection.Open() 
write-host "param(0)="$params[0]
write-host "myDir="$myDir 
$marker="PubmedArticle"
$pmidList= GetPMIDs $sqlConnection

$webclient = new-object System.Net.WebClient
$apiurl="http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmax=1000&db=pubmed&retmode=xml&id="
foreach ($PMID in $PmidList){
    $url=$apiurl+$PMID
    try{
            $TEMPFILE=$myDir+"\"+$PMID+".xml"
            write-host "TEMPFILE="$TEMPFILE
            (New-Object System.Net.WebClient).DownloadFile($URL,$TEMPFILE)
            [string]$xmlFile=Get-Content -Path $TEMPFILE -Encoding UTF8
            $xmlstr = $xmlFile[3..($xmlFile.Length - 2)] #we need to remove the first lines
            if ($xmlFile.Length -le  210)    {#"    #<PubmedArticleSet />"){
                write-host "PMID="$PMID "Length="$xmlFile.Length
                continue
            }
            if ($sqlConnection.State -eq [Data.ConnectionState]::Close) {
                $sqlConnection.Open()
            }
            $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
            $sqlCommand.Connection = $sqlConnection
            $sqlCommand.CommandText = "DECLARE @XMLSTR xml; "+
            
            "set @XMLSTR=CONVERT(XML,@TEXT,2); "+
            " IF NOT EXISTS "+
            "(SELECT pmid FROM  [Profile.Data].[Publication.PubMed.AllXML] WHERE pmid=@PMID ) "+ 
            " BEGIN "+
            " INSERT INTO [Profile.Data].[Publication.PubMed.AllXML] ([PMID],[X])"+
            " VALUES (@PMID,@XMLSTR) "+
            " END ELSE "+
            " BEGIN "+
            " UPDATE [Profile.Data].[Publication.PubMed.AllXML] "+
            " SET X= @XMLSTR WHERE pmid=@PMID  "+
            " END ;"

            $sqlcommand.CommandTimeout=120
            #"Declare @TEXT xml='"+$xmlFile+"'"+           
            $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@PMID",[Data.SQLDBType]::INT))) | Out-Null
            $sqlCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@TEXT",[Data.SQLDBType]::NVARCHAR))) | Out-Null
            
            $sqlCommand.Parameters[0].Value = $PMID
            $sqlCommand.Parameters[1].Value = $xmlFile
            try{
                $sqlCommand.ExecuteScalar()
            }catch{
                $ErrorMessage = $_.Exception.Message
                $hh=get-date -f MM/dd/yyyy_HH:mm:ss
                write-host `n$PMID   $ErrorMessage
            }    
       } catch {
            $ErrorMessage = $_.Exception.Message
            $hh=get-date -f MM/dd/yyyy_HH:mm:ss
            write-host `n"URL"$url
            write-host `n$PMID   $ErrorMessage
        }
 }