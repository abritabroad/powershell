
$sqlServerInstance = "DAL2DEVPC354"
# $sqlServerInstance = "RIC1DVWSOSQL33"
$sqlServerDatabase = "Core_Tests"
# $sqlServerDatabase = "AJ_3PAT_Data2"
$sqlServerLogCsvFileName = "C:\temp\CSV_DB_ExternalInterfaceLog.csv"

$externalTradeId = ""
# $externalTradeId = "605934"

$serviceLogFileName = "C:\_c\Enterprise\Source\WSO.Core\Specs\WSO.Core.Tests00.svclog"
$serviceLogXmlFileName = "C:\_c\Enterprise\Source\WSO.Core\Specs\WSO.Core.Tests00.xml"

$serviceLogExternalLogEventCsvFileName = "C:\Temp\CSV_Trace_ServiceLog_ExternalLogEvent.csv"
$serviceLogUpdateStatusCsvFileName = "C:\Temp\CSV_Trace_ServiceLog_UpdateStatus.csv"
$serviceLogUpdateAsReprocessedCsvFileName = "C:\Temp\CSV_Trace_ServiceLog_UpdateAsReprocessed.csv"

$debuggingLogTableName = "dbo.ExternalInferfaceLog"
$debuggingTraceLogTableName = "dbo.ExternalInferfaceTraceLog"
$debuggingTraceLogUpdateStatusTableName = "dbo.ExternalInferfaceTraceLogUpdateStatus"
$debuggingTraceLogUpdateAsReprocessedTableName = "dbo.ExternalInferfaceTraceLogUpdateAsReprocessed"


function ExportTableLogFromSqlServer([string] $sqlServerInstance, [string] $sqlServerDatabase, [string] $externalTradeId, [string] $exportedCsvFileName)
{
    $tableName = "[log].tblExternalInterfaceLog"

    $sqlCommand = "select * from " + $tableName + " where m_sExternalTradeId like '%" + $externalTradeId +"%'"

    $result = Invoke-Sqlcmd -ServerInstance $sqlServerInstance -Database $sqlServerDatabase -Query $sqlCommand

    $result | export-csv $exportedCsvFileName -notypeinformation
}

function ConvertServiceLogToXml([string] $logInputFileName, [string] $logOutputFileName)
{
    $xmlLogContent = '<?xml version="1.0" standalone="no" ?><root>' + [IO.File]::ReadAllText($logInputFileName) + "</root>"

    $xmlLogContent | Set-Content $logOutputFileName
}

# this function is left in to demonstrate exporting all service log columns
function ExportTraceLogFromServiceLog_AllFields([string] $xmlLogFileName)
{
    # this function is left
    $logOutputFileName = "C:\Temp\ServiceLog.csv"

    $logParserQuery = "`"SELECT * INTO " + $logOutputFileName + " FROM " + $xmlLogFileName + "`""

    & "LogParser" $logParserQuery

    $logOutputFileName
}

function ExportExternalLogEventTraceLogFromServiceLog([string] $xmlFileName, [string] $csvOutputFileName)
{
    $logParserQuery = "`"SELECT " +
                        "SystemTime AS LoggedTimeStamp, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 0, ','), 1, ':') AS ExternalInterfaceLogId, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 1, ','), 1, 't:') AS DateTimeSubmittedStatusResult, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 2, ','), 1, ':') AS OperationInvoked, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 3, ','), 1, ':') AS IsReprocessed, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 4, ','), 1, ':') AS TradeGroupId, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 5, ','), 1, ':') AS MessageStatusResult, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 6, ','), 1, 't:') AS StatusResult, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 7, ','), 1, ':') AS ExternalTradeId, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 8, ','), 1, ':') AS ExternalMessageId " +
                        "INTO " + $csvOutputFileName + " FROM " + $xmlFileName + " WHERE Description like 'ExternalLogEvent%' `""

    & "LogParser" $logParserQuery
}

function ExportUpdateStatusTraceLogFromServiceLog([string] $xmlFileName, [string] $csvOutputFileName)
{
    $logParserQuery = "`"SELECT " +
                        "SystemTime AS LoggedTimeStamp, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 0, ','), 1, ':') AS OriginalExternalInterfaceLogId, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 1, ','), 1, ':') AS StatusResult, " +
                        "EXTRACT_PREFIX(EXTRACT_TOKEN(Description, 1, 'message:'), 0, ')') AS Message " +
                        "INTO " + $csvOutputFileName + " FROM " + $xmlFileName + " WHERE Description like 'Entering UpdateStatus(ext%' `""

    & "LogParser" $logParserQuery
}

function ExportUpdateAsReprocessedTraceLogFromServiceLog([string] $xmlFileName, [string] $csvOutputFileName)
{
    $logParserQuery = "`"SELECT " +
                        "SystemTime AS LoggedTimeStamp, " +
                        "EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 0, ','), 1, ':') AS OriginalExternalInterfaceLogId, " +
                        "EXTRACT_PREFIX(EXTRACT_TOKEN(EXTRACT_TOKEN(Description, 1, ','), 1, ':'), 0, ')') AS TradeId " +
                        "INTO " + $csvOutputFileName + " FROM " + $xmlFileName + " WHERE Description like 'Entering UpdateAsReprocessed%' `""

    & "LogParser" $logParserQuery
}

function ExportCompleteTraceLogFromServiceLog([string] $xmlFileName, [string] $csvOutputFileName)
{
    # $logParserQuery = "`"SELECT Description INTO " + $logOutputFileName + " FROM " + $xmlLogFileName + " WHERE Description like 'ExternalLogEvent%' `""

    $logParserQuery = "`"SELECT * INTO " + $csvOutputFileName + " FROM " + $xmlFileName + "`""

    & "LogParser" $logParserQuery
}

function ImportCsvToLocalDb([string] $csvFileName, [string] $tableName) 
{

    $sqlInstance = "(localdb)\MSSQLLocalDB"

    $databaseName = "Debugging"

    $sqlCommand = "IF OBJECT_ID(N'" + $tableName +"', N'U') IS NOT NULL BEGIN DROP TABLE " + $tableName + " END"

    Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $databaseName -Query $sqlCommand

    $logParserQuery = "`"SELECT * INTO " + $tableName + " FROM " + $csvFileName + "`""
    
    & "LogParser" $logParserQuery -i:CSV -o:SQL -server:$sqlInstance -database:$databaseName -driver:"ODBC Driver 13 for SQL Server"-createTable:ON
}

"Exporting log from database to CSV...`r`n"

ExportTableLogFromSqlServer $sqlServerInstance $sqlServerDatabase $externalTradeId $sqlServerLogCsvFileName

"Converting trace from svclog to XML...`r`n"

ConvertServiceLogToXml $serviceLogFileName $serviceLogXmlFileName

"Converting trace XMLs to CSV...`r`n"

ExportExternalLogEventTraceLogFromServiceLog $serviceLogXmlFileName $serviceLogExternalLogEventCsvFileName

ExportUpdateStatusTraceLogFromServiceLog $serviceLogXmlFileName $serviceLogUpdateStatusCsvFileName

ExportUpdateAsReprocessedTraceLogFromServiceLog $serviceLogXmlFileName $serviceLogUpdateAsReprocessedCsvFileName

ExportCompleteTraceLogFromServiceLog $serviceLogXmlFileName $serviceLogCsvFileName

"Importing CSVs into debugging DB...`r`n"

ImportCsvToLocalDB $sqlServerLogCsvFileName $debuggingLogTableName

ImportCsvToLocalDB $serviceLogExternalLogEventCsvFileName $debuggingTraceLogTableName

ImportCsvToLocalDB $serviceLogUpdateStatusCsvFileName $debuggingTraceLogUpdateStatusTableName

ImportCsvToLocalDB $serviceLogUpdateAsReprocessedCsvFileName $debuggingTraceLogUpdateAsReprocessedTableName

