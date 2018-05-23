
function global:RestoreDB ([string] $newDBName, [string] $backupFilePath)
{
    [string] $dbCommand = "RESTORE DATABASE [$newDBName] " +
                          "FROM    DISK = N'$backupFilePath' " +
                          "WITH    FILE = 1, NOUNLOAD, STATS = 10"

    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $dbCommand
}

$sqlInstance = "DAL2DEVPC354"

$databaseName = "Core_Tests"
$databaseBackupFileName = "D:\Data\Database Backups\Core_Tests_Local.bak"

$sqlCommand = "DROP DATABASE " + $databaseName

"`r`nDropping database...`r`n"

#Invoke-Sqlcmd -Query $sqlCommand -OutputSqlErrors $false
Invoke-Sqlcmd -Query $sqlCommand

"Restoring Local database...`r`n"

RestoreDB $databaseName $databaseBackupFileName


