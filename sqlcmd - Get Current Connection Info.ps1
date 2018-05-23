
"`r`nGetting environment...`r`n"

Invoke-Sqlcmd "SELECT @@servername AS 'Server Name', @@servicename AS 'Instance Name', DB_NAME() AS 'Database Name', HOST_NAME() AS 'Host Name'"
