
# Once this script has completed, run the configuration tool and:
# 1) Configure the existing connection strings as normal
# 2) Add another connection string (WSO Menu Button/Connection Strings/New/Interfaces Connection)
#       - Then configure Server as per 1) and Database as per script below

function global:RestoreDB ([string] $newDBName, [string] $backupFilePath)
{
    [string] $dbCommand = "RESTORE DATABASE [$newDBName] " +
                          "FROM    DISK = N'$backupFilePath' " +
                          "WITH    REPLACE, FILE = 1, NOUNLOAD, STATS = 10"

    Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $dbCommand
}

"Rename Config folder...`r`n"

$oldConfigFolderName = "C:\_c\Build\WSO.Interfaces\Server\Framework\Configs"
$newConfigFolderName = "C:\_c\Build\WSO.Interfaces\Server\Framework\Config"

Rename-Item -Path $oldConfigFolderName -NewName $newConfigFolderName

"Copy license file...`r`n"

$oldLicenseFileName = "C:\_c\Build\WSO.Interfaces\Server\Framework\Config\Internal\Interfaces.license"
$newLicenseFileName = "C:\_c\Build\WSO.Interfaces\Server\Framework\Interfaces.license"

Copy-Item -Path $oldLicenseFileName -Destination $newLicenseFileName

"Modifying config file...`r`n"

$configFileName = "C:\_c\Build\WSO.Interfaces\Server\Framework\Interfaces.config"
$oldServerConfigFilePath = "SERVER_CONFIG_FILE_PATH"
$newServerConfigFilePath = "C:\WSO Configuration\Server.config"

(Get-Content $configFileName).replace($oldServerConfigFilePath, $newServerConfigFilePath) | Set-Content $configFileName

"Restoring database...`r`n"

$sqlInstance = "DAL2DEVPC354"

$databaseName = "WSOMessages_US"
$databaseBackupFileName = "C:\_c\Enterprise\Data\Databases\US\WSOMessages_US.bak"

RestoreDB $databaseName $databaseBackupFileName


