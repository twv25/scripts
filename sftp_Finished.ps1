#author- Thomas Vasile

#removes contents of WBTlogs
Remove-Item "E:\WBTlogs\*.gz"
Remove-Item "E:\WBTlogs\*.log"

Write-Host "Receiving files from sftp.webtrends.com"

#Logs in to ftp server and gets Zip files
Start-Process "E:\SFTP\download.cmd" -wait
Write-host "finished"

#Intitalizing Variables
$Year_folder_name = Get-Date -Format "yyyy"
$Enterprise_dir = "E:\WBTlogs\ARC\Enterprise Search"
$RCP_dir = "E:\WBTlogs\ARC\RCP Directory"
$Arc_Folder = "E:\WBTlogs\ARC"
$2r9p_folder = dir "E:\WBTlogs\*_2r9p*.gz"
$9t9i_folder = dir "E:\WBTlogs\*_9t9i*.gz"

#Enterprise Section

$Enterprise_yearDir = Test-Path "E:\WBTlogs\ARC\Enterprise Search\$Year_folder_name"

if ($Enterprise_yearDir -eq $false) {
    md -Path "E:\WBTlogs\ARC\Enterprise Search\$Year_folder_name"
    }

foreach ($x in $2r9p_folder) {
    
    $name = $x.name
    $item_check = Test-Path "E:\WBTlogs\ARC\Enterprise Search\$Year_folder_name\$name"

    if ($item_check -eq $false)
        {
        Copy-Item $x "E:\WBTlogs\ARC\Enterprise Search\$Year_folder_name"
        Write-Host "$name copied"
        }
    Else
        {
        Write-Host "$name already Exists"
        }
}
    
    
#RCP Section

$RCP_yearDir = Test-Path "E:\WBTlogs\ARC\RCP Directory\$Year_folder_name"

if ($RCP_yearDir -eq $false) {
    md -Path "E:\WBTlogs\WBTlogs\RCP Directory\$Year_folder_name"
} 

foreach ($x in $9t9i_folder) {
    
    $name = $x.name
    $item_check = Test-Path "E:\WBTlogs\ARC\RCP Directory\$Year_folder_name\$name"

    if ($item_check -eq $false)
        {
        Copy-Item $x "E:\WBTlogs\ARC\RCP Directory\$Year_folder_name"
        Write-Host "$name copied"
        }
    Else
        {
        Write-Host "$name already Exists"
        }
}