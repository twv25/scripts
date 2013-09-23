<#

.NOTES
    AUTHOR: THOMAS VASILE
    CONTACT: TWV25@DREXEL.EDU

.SYNOPSIS
    WILL MOVE WEBTRENDS PROFILES.
        
.DESCRIPTION 
    
.PARAMETERS
    CSV_FILE: PATH TO EXCEL SHEET CONTAINING PROFILES TO BE DELETED.

.EXAMPLE
    NONE

#>

param(
    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $CSV_File,

    [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$false)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Move_To,

    [Parameter(Mandatory=$true,Position=2,ValueFromPipeline=$false)]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Drives
    )

#importing csv
$CSV = Import-Csv $CSV_File

$CSV | foreach {
    if ( $_."Delete (Y/N)" -imatch "y" ) { 
        $profile_del = $_."Profile File Name"
        foreach ($drive in $Drives) {
            $drive_letter = $drive.Split(':')[0]
            $move_dir = "$Move_To"+"_$drive_letter"
            #Testing if folder exists
            If (!(Test-Path $move_dir)) {
                [system.io.directory]::CreateDirectory($move_dir) }
            dir $drive -Recurse -Filter *$profile_del* | Move-Item -Destination $Move_dir -Force
            }             
    }
}