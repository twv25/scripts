#☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻#
#☻ Author: Thomas Vasile     ☻#
#☻ Enviroment_Replicator     ☻#
#☻ Contact: Twv25@drexel.edu ☻#
#☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻☻#

###################################################################
# Prerequisite: Reference_Creator.ps1                             #
# Purpose: To take supplied reference enviroment and replicate it #
# Parameters: -Reference <string>, -Ref_short <string>            #
# -NewEnv <string>, and -NewEnv_short <string>                    #
#   •Reference will be the Enviroment to be replicated            #
#   •Ref_short = shortname                                        #
#   •NewEnv will be the name of the Enviroment being created      #
#   •NewEnv_short = shortname                                     #
###################################################################

###########################################################################
#_______________________________ATTENTION_________________________________#
# The passsword for accounts are set to "TempP@ss1" and should be changed #
###########################################################################

param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$false)]
    [string]
    $Reference,

    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false)]
    [string]
    $Ref_short,

    [Parameter(Mandatory=$true,Position=2,ValueFromPipeline=$false)]
    [string]
    $NewEnv,

    [Parameter(Mandatory=$true,Position=3,ValueFromPipeline=$false)]
    [string]
    $NewEnv_short)

#Reference OU Folder and Files
$Directory = "C:\CSV\" + "$Reference" + "_" + "csv"
$Ou_csv = "$Directory\Ou.csv"
$Comp_csv = "$Directory\Computers.csv"
$User_csv = "$Directory\Users.csv"
$UsrMemberof_csv = "$Directory\UsrMemberof.csv"
$CompMemberof_csv = "$Directory\CompMemberof.csv"

#New Enviroment Folder and Files
$NewEnv_Dir = "C:\CSV\" + "$NewEnv" + "_" + "csv"
$NewOu_csv = "$NewEnv_Dir\Ou.csv"
$NewComp_csv = "$NewEnv_Dir\Computers.csv"
$NewUser_csv = "$NewEnv_Dir\Users.csv"
$NewUsrMemberof_csv = "$NewEnv_Dir\UsrMemberof.csv"
$NewCompMemberof_csv = "$NewEnv_Dir\CompMemberof.csv"

#Testing if Dir exists already
$Dir_Test = Test-Path $Directory

#New OU path
$New_Ou = "ou=" + $NewEnv + ",ou=servers,dc=pmienvs,dc=pmihq,dc=org"

#used in test env
#$New_Ou = "ou=" + $NewEnv + ",ou=servers,dc=tsthq,dc=org"

#Checks Ref/NewEnv to see if they exist or formatted correctly
try {
        if ($Dir_Test -eq $False) 
        {
            throw ( Write-Error "Reference Folder does not exist.")

        } else {
                if (!([adsi]::Exists("LDAP://$New_Ou"))) {

                    Import-Module ActiveDirectory
                                    
                    #Creates NewEnv Directory
                    [system.io.directory]::CreateDirectory($NewEnv_Dir)
                
                    #Replaces Reference names with NewEnv
                    (Get-Content $Ou_csv) | Foreach-Object {$_ -ireplace $Reference, $NewEnv} `
                    | Set-Content $NewOu_csv

                    #Edit Computer and users ou name in csv
                    (Get-Content $Comp_csv) | Foreach-Object {
                        $_ -ireplace $Reference, $NewEnv } `
                        | Set-Content $NewComp_csv 

                    (Get-Content $user_csv) | Foreach-Object {
                        $_ -ireplace $Reference, $NewEnv} `
                        | Set-Content $Newuser_csv
                                         
                    #fixing all short names                  
                    $csv = import-csv "$NewComp_csv"
                    foreach ($x in $csv) {
                    $name= $x.name
                    $name_fixed = $name -ireplace ("$Ref_short","$NewEnv_short")
                    (Get-Content $NewComp_csv) | ForEach-Object {
                    $_ -ireplace $name,$name_fixed } | Set-Content $NewComp_csv }

                    $csv = import-csv "$Newuser_csv"
                    foreach ($x in $csv) {
                    $name= $x.name
                    $name_fixed = $name -ireplace ("$ref_short","$NewEnv_short")
                    (Get-Content $Newuser_csv) | ForEach-Object {
                    $_ -ireplace $name,$name_fixed } | Set-Content "$Newuser_csv" } 

                    $csv = import-csv "$UsrMemberof_csv"
                    foreach ($x in $csv) {
                    $name= $x.username
                    $name_fixed = $name -ireplace ("$ref_short","$NewEnv_short")
                    (Get-Content $UsrMemberof_csv) | ForEach-Object {
                    $_ -ireplace $name,$name_fixed } | Set-Content "$NewUsrMemberof_csv" }
                    
                    $csv = import-csv "$CompMemberof_csv"
                    foreach ($x in $csv) {
                    $name= $x.username
                    $name = $name.TrimEnd("$")
                    $name_fixed = $name -ireplace ("$ref_short","$NewEnv_short")
                    (Get-Content $CompMemberof_csv) | ForEach-Object {
                    $_ -ireplace $name,$name_fixed } | Set-Content "$NewCompMemberof_csv" } 
                                                          
                } else {
                        throw (Write-Error "The Enviroment You Are Trying To Create Already Exists")
                       }
               }
} catch {
    Throw ("Please Check Reference/NewEnv Information For Errors.") 
}

#Importing in Ou Csv       
$CSV_Import = Import-Csv $NewOu_csv
                    
#Creating Ou Structure
$CSV_Import | foreach {
    $DN = $_.DistinguishedName
    #Splits Off CN name because it does not exist yet
    $Split = $DN -split ',',2
    New-ADOrganizationalUnit -name $_.Name -path $Split[1]
}

#Begin Computers section
$bad = 0
$good = 0

#Importing in Computer Csv       
$CSV_Import = Import-Csv $NewComp_csv
                    
#Populating Computers
$CSV_Import | foreach {
    $DN = $_.DistinguishedName
    $Split = $DN -split ',',2
    [Boolean]$Enabled = [System.Convert]::ToBoolean($_.Enabled)
    $name = $_.name

    try {
        New-ADComputer -Name $_.Name -DisplayName $_.DisplayName `
        -DNSHostName $_.DNSHostName -Enabled $Enabled -Path $split[1] `
        -SAMAccountName $_.SAMAccountName
        $good++
        } catch {
            Write-host "Error creating user: $Name"
            $bad++
    }
}
Write-host "Created $good computers with $bad errors"

#Begin Users Sections
$bad = 0
$good = 0

#Importing in User Csv       
$CSV_Import = Import-Csv $NewUser_csv
                    
#Populating Users section
$CSV_Import | foreach {
    $DN = $_.DistinguishedName
    $Split = $DN -split ',',2
    $name = $_.name

    #Used to avoid boolean error
    [Boolean]$Enabled = [System.Convert]::ToBoolean($_.Enabled)
    [Boolean]$pass = [System.Convert]::ToBoolean($_.PasswordNeverExpires)
    $pwd = "TempP@ss1"

    #Creating user
    try {
        New-ADUser -Name $_.Name -AccountPassword (ConvertTo-SecureString -AsPlainText `
        $pwd -Force) -ChangePasswordAtLogon $true -DisplayName $_.DisplayName `
        -Enabled $Enabled -GivenName $_.GivenName -PasswordNeverExpires `
        $pass -Path $split[1] -SamAccountName $_.SamAccountName `
        -UserPrincipalName $_.UserPrincipalName
        $good++
    } catch {
        Write-host "Error creating user: $name "
        $bad++
    }
}
Write-host "Created $good users with $bad errors"

#Begin User Memberof Section
$bad = 0
$good = 0

$CSV_Import = Import-Csv $NewUsrMemberof_csv
$CSV_Import | foreach { 

    #Fixup DN by removing cn and dc, leaving only name
    $groupdn = $_.groupdn -replace , "CN=", ""
	$Split = $groupdn -split ',',2
    $Username =  $_.Username 
    $Groupname= $split[0]
    Write-Host "Adding: $Username to $Groupname"
    
    #Adding memberships
    try {    
        get-ADUser -identity $username -EA stop| Add-ADPrincipalGroupMembership `
        -memberof $Groupname -EA Stop -WA SilentlyContinue
        Write-Host "Added: "$username" to: "$Groupname""
        $good++
    } Catch {
        Write-host "Error adding:"$username" to: "$Groupname""
        $bad++
    }
}
Write-host "Imported "$good" memberships; saw "$bad" errors"

#Begin Comp Memberof Section
$bad = 0
$good = 0

$CSV_Import = Import-Csv $NewCompMemberof_csv
$CSV_Import | foreach { 

    #Fixup DN by removing cn and dc, leaving only name
    $groupdn = $_.groupdn -replace , "CN=", ""
	$Split = $groupdn -split ',',2
    $Username =  $_.Username 
    $Groupname= $split[0]
    Write-Host "Adding: $Username to $Groupname"
    
    #Adding memberships
    try {    
        get-ADComputer -identity $username -EA stop| Add-ADPrincipalGroupMembership `
        -memberof $Groupname -EA Stop -WA SilentlyContinue
        Write-Host "Added: "$username" to: "$Groupname""
        $good++
    } Catch {
        Write-host "Error adding:"$username" to: "$Groupname""
        $bad++
    }
}
Write-host "Imported "$good" memberships; saw "$bad" errors"

#=============#
# GPO Section #
#=============#

try {
    Import-Module GroupPolicy

    #GPO and New GPO Name
    $Gpo = "PMIENVS_Servers_" +"$Reference" + "_Servers"
    $New_Gpo = "PMIENVS_Server_" +"$NewEnv" + "_Servers"

    #Copies and Links Gpo
    Copy-GPO -SourceName $gpo -TargetName $New_Gpo
    New-GPLink $New_Gpo -target "$New_Ou" -LinkEnabled Yes
} catch { throw "Gpo was not linked." }