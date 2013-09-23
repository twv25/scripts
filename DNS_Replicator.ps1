#=======================#
# Author: Thomas Vasile #
#  DNS_Replicator.ps1   #
#=======================#

###################################################################
# Purpose: To take supplied enviroment and replicate its dns      #
# Parameters: -DnsServer <string> -DNSZone <string> -Env <string> #
# -Env_Short <string> -NewEnv <string> -NewEnv_Short <string>     #
# -FirstThreeOctet <string>                                       #
#   •DnsServer = DNS DomainController                             #
#   •DNSZone = The Zone the target Enviroment is housed           #
#   •Env = the name of the Enviroment DNS is being copied from    #
#   •Env_Short = Short name of the Enviroment                     #
#   •NewEnv = Name of Enivroment being created                    #
#   •NewEnv_Short = Short name of New Enviroment                  #
#   •FirstThreeOctet = First three Octets of desired IP           #
#      Ex: 192.168.1                                              #
###################################################################

#params to use $DnsServer, $Env, $Env_Short, $NewEnv, $NewEnv_Short, $FirstThreeOctet
param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$false)]
    [string]
    $DnsServer,

    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false)]
    [string]
    $DNSZone,

    [Parameter(Mandatory=$true,Position=2,ValueFromPipeline=$false)]
    [string]
    $Env,

    [Parameter(Mandatory=$true,Position=3,ValueFromPipeline=$false)]
    [string]
    $Env_Short,

    [Parameter(Mandatory=$true,Position=4,ValueFromPipeline=$false)]
    [string]
    $NewEnv,

    [Parameter(Mandatory=$true,Position=5,ValueFromPipeline=$false)]
    [string]
    $NewEnv_Short,

    [Parameter(Mandatory=$true,Position=6,ValueFromPipeline=$false)]
    [string]
    $FirstThreeOctet)


#DNS MODULE REQUIRED!!!
#http://dnsshell.codeplex.com/
Import-Module DNSSHELL

#Folder of where to store csv files
$Directory = "C:\DNS"

#csv files
$Env_csv = "$Directory\" + "$Env" + ".csv"
$NewEnv_csv = "$Directory\" + "$NewEnv" + ".csv"

#Test if the Directory Exists and if it does it deletes the contents
If (!(Test-Path $Directory)){
[system.io.directory]::CreateDirectory($Directory)
} else { Remove-Item $Directory"\*" -Recurse }

try {
    #Gets DNS for supplied Enviroment and export as csv to Directory
    Get-DnsRecord -server $DnsServer -name $Env -zonename $DNSZone | Select-object name, recordtype, recorddata | export-csv -path $Env_csv

    #Editing csv File 
    #Finds first 3 octet and replaces with supplied value
    $Range = '\b([0-9]{1,2}|1[0-9]{2}|2[0-4][0-9]|25[0-4])\b'
    $Octet = "$Range" + "." + "$Range" + "." + "$Range"

    #Replacing Env name with NewEnv name
    (Get-Content $Env_csv) | ForEach-Object { $_ -replace $Env, $NewEnv } | Set-Content $NewEnv_csv

    #Replacing Ip address under data
    (Get-Content $NewEnv_csv) | ForEach-Object { $_ -replace $Octet, $FirstThreeOctet } | Set-Content $NewEnv_csv

    #Importing NEW CSV
    $CSV_Import = Import-Csv $NewEnv_csv

    $CSV_Import | foreach {
        #Used to fix name
        $replace = "." + "$DNSZone"
        $recordName = $_.name
        $recordName = $recordName.Replace($replace,"")
        $recordType = $_.recordtype
        #Used to fix Data name
        $recordAddress = $_.RecordData
        $AddressName = $recordAddress.TrimStart($Env_Short)
        $fixed_Name = $NewEnv_Short + $AddressName
        $recordAddress1 = $fixed_Name
        
        If ($_.RecordData -match $Range -or $AddressName -eq $recordAddress) {
           #adding records with ips and non-short names
           $RecordAdd = “dnscmd $DnsServer /RecordAdd $DNSZone $recordName $recordType $recordAddress"
           Write-Host “Running the following command: $RecordAdd"
           Invoke-Expression $RecordAdd 
        } 
        Else {    
           #adding short-name containing records
           $RecordAdd = “dnscmd $DnsServer /RecordAdd $DNSZone $recordName $recordType $recordAddress1"
           Write-Host “Running the following command: $RecordAdd"
           Invoke-Expression $RecordAdd
        }
    }

    #clearing csv files
    Remove-Item "C:\DNS\*" -Recurse

} catch {
    throw ("Please Check Parameters for Errors")
} 