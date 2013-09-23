#=======================#
# Author: Thomas Vasile #
#  DNS_Replicator.ps1   #
#=======================#

#params to use $DnsServer, $Original_Env, $Original_Env_Short, $NewEnv, $NewEnv_Short, $FirstThreeOctet
param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$false)]
    [string]
    $DnsServer,

    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false)]
    [string]
    $RootZone,

    [Parameter(Mandatory=$true,Position=2,ValueFromPipeline=$false)]
    [string]
    $Original_Env,

    [Parameter(Mandatory=$true,Position=3,ValueFromPipeline=$false)]
    [string]
    $Original_Env_Short,

    [Parameter(Mandatory=$true,Position=4,ValueFromPipeline=$false)]
    [string]
    $NewEnv,

    [Parameter(Mandatory=$true,Position=5,ValueFromPipeline=$false)]
    [string]
    $NewEnv_Short,

    [Parameter(Mandatory=$true,Position=6,ValueFromPipeline=$false)]
    [string]
    $wfe_FirstThreeOctet,

    [Parameter(Mandatory=$true,Position=7,ValueFromPipeline=$false)]
    [string]
    $api_FirstThreeOctet,

    [Parameter(Mandatory=$true,Position=8,ValueFromPipeline=$false)]
    [string]
    $has_FirstThreeOctet,

    [Parameter(Mandatory=$true,Position=9,ValueFromPipeline=$false)]
    [string]
    $sso_FirstThreeOctet)

#DNS MODULE REQUIRED!!!
#http://dnsshell.codeplex.com/
Import-Module DNSSHELL

#Folder of where to store csv files
$Directory = "C:\DNS"

#csv files
$Original_Env_csv = "$Directory\" + "$Original_Env" + ".csv"
$NewEnv_csv = "$Directory\" + "$NewEnv" + ".csv"

#Test if the Directory Exists and if it does it deletes the contents
If (!(Test-Path $Directory)){
[system.io.directory]::CreateDirectory($Directory)
} else { Remove-Item $Directory"\*" -Recurse }

try {
    #Gets DNS for supplied Enviroment and export as csv to Directory
    Get-DnsRecord -server $DnsServer -name $Original_Env -zonename $RootZone | Select-object name, recordtype, recorddata | export-csv -path $Original_Env_csv

    #Editing csv File 
    #Finds first 3 octet and replaces with supplied value
    $Range = '\b([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-4])\b'
    $Octet = "$Range" + "." + "$Range" + "." + "$Range"

    #Replacing Env name with NewEnv name
    (Get-Content $Original_Env_csv) | ForEach-Object { $_ -replace $Original_Env, $NewEnv } | Set-Content $NewEnv_csv

    #Seperate A records
    $A_record_replace = Import-Csv $NewEnv_csv
    
    #Replacing Ip address under data
    $A_record_replace | foreach {
        If ($_.recordtype -eq "A") {
            if ($_.name -imatch "has") { 
            $has_ip = $_.recorddata
            $new_has_ip = $has_ip | ForEach-Object { $_ -replace $Octet, $has_FirstThreeOctet }   
            (Get-Content $NewEnv_csv) | ForEach-Object { $_ -replace $has_ip, $new_has_ip } | Set-Content $NewEnv_csv
            } elseif ($_.name -imatch "api") { 
            $api_ip = $_.recorddata
            $new_api_ip = $api_ip | ForEach-Object { $_ -replace $Octet, $api_FirstThreeOctet }   
            (Get-Content $NewEnv_csv) | ForEach-Object { $_ -replace $api_ip, $new_api_ip } | Set-Content $NewEnv_csv
            } elseif ($_.name -imatch "wfe") { 
            $wfe_ip = $_.recorddata
            $new_wfe_ip = $wfe_ip | ForEach-Object { $_ -replace $Octet, $wfe_FirstThreeOctet }   
            (Get-Content $NewEnv_csv) | ForEach-Object { $_ -replace $wfe_ip, $new_wfe_ip } | Set-Content $NewEnv_csv
            } elseif ($_.name -imatch "sso") { 
            $sso_ip = $_.recorddata
            $new_sso_ip = $sso_ip | ForEach-Object { $_ -replace $Octet, $sso_FirstThreeOctet }   
            (Get-Content $NewEnv_csv) | ForEach-Object { $_ -replace $sso_ip, $new_sso_ip } | Set-Content $NewEnv_csv
            }
        }
    } 

    #Importing NEW CSV
    $CSV_Import = Import-Csv $NewEnv_csv

    $CSV_Import | foreach {
        #Used to fix name
        $replace = "." + "$RootZone"
        $recordName = $_.name
        $recordName = $recordName.Replace($replace,"")
        $recordType = $_.recordtype
        #Used to fix Data name
        $recordAddress = $_.RecordData
        $AddressName = $recordAddress.TrimStart($Original_Env_Short)
        $fixed_Name = $NewEnv_Short + $AddressName
        $recordAddress1 = $fixed_Name

        if ($recordName -imatch "db7") {} else {
        
            If ($_.RecordData -match $Range -or $AddressName -eq $recordAddress) {
               #adding records with ips and non-short names
               $RecordAdd = “dnscmd $DnsServer /RecordAdd $RootZone $recordName $recordType $recordAddress"
               Write-Host “Running the following command: $RecordAdd"
               Invoke-Expression $RecordAdd 
            } 
            Else {    
               #adding short-name containing records
               $RecordAdd = “dnscmd $DnsServer /RecordAdd $RootZone $recordName $recordType $recordAddress1"
               Write-Host “Running the following command: $RecordAdd"
               Invoke-Expression $RecordAdd
            }
        }
    }

    #clearing csv files
    Remove-Item "C:\DNS\*" -Recurse

} catch {
    throw ("Please Check Parameters for Errors")
} 