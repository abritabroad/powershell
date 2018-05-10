
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

$frameworkPath = "C:\_c\Build\WSO.Interfaces\Server\Framework\"
$databaseBackupPath = "C:\_c\Enterprise\Data\Databases\US\"
$wsoConfigurationPath = "C:\WSO Configuration\"

"Rename Config folder...`r`n"

$oldConfigFolderName = $frameworkPath + "Configs"
$newConfigFolderName = $frameworkPath + "Config"

Rename-Item -Path $oldConfigFolderName -NewName $newConfigFolderName

"Copy license file...`r`n"

$oldLicenseFileName = $newConfigFolderName + "\Internal\Interfaces.license"
$newLicenseFileName = $frameworkPath + "Interfaces.license"

Copy-Item -Path $oldLicenseFileName -Destination $newLicenseFileName

"Modifying config file...`r`n"

$configFileName = $frameworkPath + "Interfaces.config"
$oldServerConfigFilePath = "SERVER_CONFIG_FILE_PATH"
$newServerConfigFilePath = $wsoConfigurationPath + "Server.config"

(Get-Content $configFileName).replace($oldServerConfigFilePath, $newServerConfigFilePath) | Set-Content $configFileName

"Restoring database...`r`n"

$sqlInstance = "DAL2DEVPC354"

$databaseName = "WSOMessages_US"
$databaseBackupFileName = $databaseBackupPath + "WSOMessages_US.bak"

RestoreDB $databaseName $databaseBackupFileName


