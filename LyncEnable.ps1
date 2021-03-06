#Authored by Thomas Vasile
################################################
##-------------LOG DELETE SECTION-------------##
################################################

#This section deletes the Lync log file if its older than 1 week
$Lyncfolder = "C:\Lync Log Folder"

# set minimum age of files and folders
$max_days = "-7"

# get the current date
$curr_date = Get-Date

# determine how far back we go based on current date
$del_date = $curr_date.AddDays($max_days)

# delete the Log

Get-ChildItem $LyncFolder  | Where-Object { $_.CreationTime -lt $del_date } | Remove-Item 

#######################################################
##-------------Start of Enabling section-------------##
#######################################################

#hiding errors to keep logs clean
$ErrorActionPreference = "silentlycontinue"

#imports Lync and AD Modules.
import-module "C:\Program Files\Common Files\Microsoft Lync Server 2010\Modules\Lync\Lync.psd1"

import-module activedirectory

#Gets current date and time
$DateandTime = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
$date = Get-date -Format "MM-dd-yyyy"

#define folder where files are located
$LogLync = "C:\Lync Log Folder\" + "Lync" + "$date" + ".log"

#Defines the distro groups that will be looked at
$Distro = @(#DISTROS)

#only searches through defined AD distribution groups in $Distro
foreach ($distrogroup in $distro) 
{
    #Personal Format for breaking up the log file
    Write-Output "
    Start of $distrogroup Users

    " | Out-File $LogLync -Append -force | KILL

    $strFilter = "(&(objectCategory=Group)(SamAccountName=$distrogroup))"

    $objDomain = New-Object System.DirectoryServices.DirectoryEntry

    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher

    $objSearcher.SearchRoot = $objDomain

    $objSearcher.Filter = $strFilter

    $objSearcher.SearchScope = "Subtree"

    $colProplist = "member"

    foreach ($i in $colPropList) {
    	[void] $objSearcher.PropertiesToLoad.Add($i)
    }

    $colResults = $objSearcher.FindAll()

    foreach ($objResult in $colResults) {
    	$objItem = $objResult.Properties; $group = $objItem.member  
    }

    foreach ($x in $group) {
    	$Lync_Status_Check = Get-CsADUser $x	
    	$DN = $Lync_Status_Check.Name		
    	$AD_Status_Check = get-aduser $x	
        
        if($AD_Status_Check.givenname -ne "_TemplateSDU") 
            {
                if ($AD_Status_Check.enabled -eq $true)		
            		{
            			If ($Lync_Status_Check.Enabled -ne $true) 	
            				{
                            
            				#Writes user to the log file                            
                            "Enabling for Lync : $DN Date: $DateandTime
                            " | out-file $LogLync -Append -force | KILL  
                            
                            #Enables user for Lync                         		
            				Enable-CSUser $x -RegistrarPool #POOL -SipAddressType SamAccountName –SipDomain #DOMAIN
            				}
            		}
                else         #Checks to see if user is AD Disabled
                    	{
                       		 If ($Lync_Status_Check.Enabled -eq $true)      
                            		{
                                   
                                    #Writes user to the log file                                  
                                	"Disabling for Lync : $DN Date: $DateandTime
                                    " | out-file $LogLync -Append -force | KILL
                               		 
                                     Disable-CsUser $x     
                           			}
                   		 }                    
            }
    }
}

###################################
##---------Email Section---------##
###################################

Send-mailmessage -from #EMAIL `
 -to #EMAIL `
 -Subject "Lync Log for $date" `
 -Body "This is an automated message to Service Desk containing the Lync changes for the date: $date." `
 -Attachment "$LogLync" `
 -smtpServer #RELAY