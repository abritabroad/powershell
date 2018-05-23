
function global:ExportLogFromSqlServer()
{
    # $sqlInstance = "DAL2DEVPC354"
    $sqlInstance = "RIC1DVWSOSQL33"

    # $databaseName = "Core_Tests"
    $databaseName = "AJ_3PAT_Data2"

    $tableName = "[log].tblExternalInterfaceLog"
    $externalTradeId = "605934"

    $sqlCommand = "select * from " + $tableName + " where m_sExternalTradeId = '" + $externalTradeId +"'"

    $exportedCsvFileName = "C:\temp\ExternalInterfaceLog.csv"

    "Exporting table from database...`r`n"

    $result = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $databaseName -Query $sqlCommand

    $result | export-csv $exportedCsvFileName -notypeinformation
}

ExportLogFromSqlServer

