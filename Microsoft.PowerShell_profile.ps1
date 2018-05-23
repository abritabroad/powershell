
$profileScript = (Split-Path -Path $profile) + "\a_brit_abroad_profile.ps1"

& $profileScript

Set-Alias -Name BH -Value BranchHistory
Set-Alias -Name BD -Value BranchDiff
	
Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-a4faccd\src\posh-git.psd1'

## To get list of colors that can be changed type '$global:GitPromptSettings' at PS command prompt
#
#$global:GitPromptSettings.WorkingForegroundColor = [ConsoleColor]::Red
#$global:GitPromptSettings.LocalWorkingStatusForegroundColor = [ConsoleColor]::Red
#
#
#function global:RestoreDB ([string] $newDBName, [string] $backupFilePath)
#{
#    [string] $dbCommand = "RESTORE DATABASE [$newDBName] " +
#                          "FROM    DISK = N'$backupFilePath' " +
#                          "WITH    FILE = 1, NOUNLOAD, STATS = 10"
#
#    Invoke-Sqlcmd -Query $dbCommand
#}
#
#net use Z: "\\markit\dfs\DAL\Users\steven.fisher"
#
