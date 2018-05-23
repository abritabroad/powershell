
$currentDirectory = get-location

$logInputFileName = Join-Path "Z:" "WSO.MQBridge.ThirdPartyInboundService00.svclog"
$logOutputFileName = Join-Path $currentDirectory "ThirdPartyInboundService.csv"
$sheetOutputFileName = Join-Path $currentDirectory "ThirdPartyInboundService.xlsx"

try { remove-item $sheetOutputFileName }
catch {}

$logParserQuery = "`"SELECT Text INTO " + $logOutputFileName + " FROM " + $logInputFileName + "`""
$logParserCommand = "LogParser"

& $logParserCommand $logParserQuery

$excel = New-Object -ComObject Excel.Application

$excel.Visible = $false

$workBook = $excel.Workbooks.Open($logOutputFileName)

$workBook.WorkSheets[1].Columns.AutoFit()

$workBook.SaveAs($sheetOutputFileName, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbook)

$workBook.Close($false)

$excel.Quit()

[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workBook)
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)

Remove-Variable -Name excel
Remove-Variable -Name workBook

& $sheetOutputFileName
