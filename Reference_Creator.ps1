#=======================#
# Author: Thomas Vasile #
#   Reference_Creator   #
#=======================#

############################################################################
# Purpose: Creates .CSV files containing attributes of the supplied domain #
# Parameters: -CopyFrom <string>                                           #
#   •CopyFrom must be a pre-existing Enviroment                            #
############################################################################

param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$false)]
    [string]
    $CopyFrom)

#OU path to supplied Enviroment
$ou_name = "ou=" + $copyfrom + ",ou=servers,dc=pmienvs,dc=pmihq,dc=org"

#Test to make sure supplied enviroment is valid
[string] $Path = $ou_name
try {
        if (!([adsi]::Exists("LDAP://$Path"))) 
        {
            Throw( Write-Error "Supplied Path does not exist.")
        } else {                
               Import-Module ActiveDirectory 
               
               #Dir where Candidate csv will be stored
               $Directory = "C:\" +"CSV\" + "$copyfrom" + "_" + "csv"

               #Testing if Dir exists already
               $Dir_Test = Test-Path $Directory

               #Create Dir if it does not exist
               if ($Dir_Test -ne $true) {
                   [system.io.directory]::CreateDirectory($Directory)
               }

               #Sets Up CSV Names
               $ou = "$Directory\" + "OU.csv"
               $computers = "$Directory\" + "Computers.csv"
               $Users = "$Directory\" + "Users.csv"
               $UsrMemberof = "$Directory\" + "UsrMemberof.csv"
               $CompMemberof = "$Directory\" + "CompMemberof.csv"

               #Creates ou csv
               Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase `
               $ou_name -Properties "*" | Export-Csv $ou

               #Gets computers from ou and exports as csv
               Get-ADComputer -filter "*" -SearchBase $ou_name `
               -Properties "*" | Export-Csv $computers

               #Gets users from ou and exports as csv
               Get-ADUser -filter "*" -SearchBase $ou_name -Properties "*" `
               | Export-Csv $users

               #Gets MemberOf for users and exports as csv
               $mbrcnt = 0
               $usrcnt = 0
               $memberships = @()
               $mem= new-object object
               $mem |add-member noteproperty username "samaccountname"
               $mem |add-member noteproperty groupdn "group"
               get-aduser -filter * -searchbase $ou_name -property memberof| foreach {
                   $usrcnt++
                   $sam = $_.samaccountname
                   foreach ($group in $_.memberof) {
                      $mbrcnt++
                      $mem= new-object object
	                  $mem |add-member noteproperty username $sam
	                  $mem |add-member noteproperty groupdn $group
                      $memberships += $mem
                   }
       
               }
               $memberships |export-csv $UsrMemberof
               write-host "$mbrcnt group memberships exported for $usrcnt users"

               #Gets MemberOf for Computers and exports as csv
               $mbrcnt = 0
               $compcnt = 0
               $memberships = @()
               $mem= new-object object
               $mem |add-member noteproperty username "samaccountname"
               $mem |add-member noteproperty groupdn "group"
               get-adcomputer -filter * -searchbase $ou_name -property memberof| foreach {
                   $compcnt++
                   $sam = $_.samaccountname
                   foreach ($group in $_.memberof) {
                      $mbrcnt++
                      $mem= new-object object
	                  $mem |add-member noteproperty username $sam
	                  $mem |add-member noteproperty groupdn $group
                      $memberships += $mem
                   }
       
               }
               $memberships |export-csv $CompMemberof
               write-host "$mbrcnt group memberships exported for $compcnt computers"
          } 
 } catch {
    # If invalid format, error is thrown.
    Throw("Supplied Path Has An Invalid Format")
}