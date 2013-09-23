<#

.NOTES
    AUTHOR: THOMAS VASILE

.SYNOPSIS
    WILL MOVE WEBTRENDS PROFILES.
        
.DESCRIPTION 
    
.PARAMETERS
    EXCEL_FILE: PATH TO EXCEL SHEET CONTAINING PROFILES TO BE DELETED.

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

#Testing if folder exists
If (!(Test-Path $Move_To)) {
[system.io.directory]::CreateDirectory($Move_To) }

$CSV = Import-Csv $CSV_File

$CSV | foreach {
    if ( $_."Delete (Y/N)" -imatch "y" ) { 
        $profile_del = $_."Profile File Name"
        foreach ($drive in $Drives) {
            dir $drive -Recurse -Filter *$profile_del* | Move-Item -Destination $Move_To -Force
            }             
    }
}