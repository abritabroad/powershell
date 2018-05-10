
# Inorder to use this script:
#    1) the server database backup needs to be restored into the local server with the DB_Name 'Core_Tests'
#    2) 'Core_Tests' then needs to be backed up from there E.G. with a '_Local.bak' suffix
#    3) If processing a SLTTPN and want to replicate CREATE functionality, run the 'Delete External Trade Ticket.ps1' script first

function global:RestoreDB ([string] $newDBName, [string] $backupFilePath)
{
    [string] $dbCommand = "RESTORE DATABASE [$newDBName] " +
                          "FROM    DISK = N'$backupFilePath' " +
                          "WITH    REPLACE, FILE = 1, NOUNLOAD, STATS = 10"

    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $dbCommand
}

$sqlInstance = "DAL2DEVPC354"

$databaseName = "Core_Tests"
$databaseBackupFileName = "D:\Data\Database Backups\AJ_3PAT_Data2_20180425_Local.bak"

$sqlCommand = "DROP DATABASE " + $databaseName

"`r`nDropping database...`r`n"

#Invoke-Sqlcmd -Query $sqlCommand -OutputSqlErrors $false
Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $sqlCommand

"Restoring database...`r`n"

RestoreDB $databaseName $databaseBackupFileName
