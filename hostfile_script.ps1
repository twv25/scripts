<#

.NOTES
    AUTHOR: THOMAS VASILE
    CONTACT: TWV25@DREXEL.EDU
    DNSSHELL MODULE NEEDED.
.SYNOPSIS
    Creates deployment host file for production  
.DESCRIPTION 
    To be used to create a master host file of production when doing deployments.
    Part of Near Zero Down Time.
.PARAMETERS
    DnsServer: [string]
    DNSZone: [string]
    Env: [array]
.EXAMPLE
    
#>

#Parameters are named here
param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$false)]
    [string]
    $DnsServer,

    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false)]
    [string]
    $DNSZone,

    [Parameter(Mandatory=$true,Position=2,ValueFromPipeline=$false)]
    [array]
    $Env)

#DNS MODULE REQUIRED!!!
#http://dnsshell.codeplex.com/
Import-Module DNSSHELL

$Directory = "C:\Deploy"
$host_file = "C:\Windows\System32\drivers\etc\deployhosts"

#Testing if Dir exists already
If (!(Test-Path $Directory)){
[system.io.directory]::CreateDirectory($Directory)
} else { Remove-Item $Directory"\*" -Recurse }

#Looping through all supplied enviroments
foreach ($enviroment in $Env) {
    $prod = "$Directory\" + "$enviroment" + ".csv"
    
    #Gets DNS for supplied Enviroment and export as csv to Directory
    Get-DnsRecord -server $DnsServer -name $enviroment -zonename $DNSZone | `
    Select-object name, recordtype, recorddata | export-csv -path $prod

    $Csv = Import-Csv $prod
    [array]$New_csv = $null 
    ($Csv) | foreach {
        $address = $_.RecordData
        $FQDN = $_.name
        $FQDN = $FQDN -replace '^([^.]+\.)','$1deploy.'  #Adding deploy into fqdn
        [array] $IP = $null
        #Getting Ip Addresses
        $ip = [System.Net.Dns]::GetHostAddresses("$address").IPAddressToString    
        #Creating columns for new csv
        $New_csv += New-Object PSObject -Property @{FQDN=$FQDN;IPAddress=$ip[0]} 
    }

    ($New_csv) | Export-CSV "$Directory\Deploy.csv" -notype

    #Grouping ip and fqdn for host file
    $Deploy_csv = Import-Csv "$Directory\Deploy.csv"
    [array]$output = $null
    $Deploy_csv | Group IPAddress | ForEach {
        $output+="$($_.Name) $(($_.Group | Select -expand FQDN) -join ' ')"
    }
    #Outing host file
    $output | out-file $host_file -Encoding ascii -Append
}