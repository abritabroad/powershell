
Import-Module SQLPS

$profileScript = (Split-Path -Path $profile) + "\a_brit_abroad_profile.ps1"

& $profileScript

