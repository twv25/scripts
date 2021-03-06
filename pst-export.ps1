<#

.NOTES
    AUTHOR: THOMAS VASILE
    CONTACT: TWV25@DREXEL.EDU
    pst-export.ps1

.SYNOPSIS
    Exports disabled account's mailboxes to share.
     
.DESCRIPTION 
    Exports diabled user's mailboxed as .pst files to a network share for
    consolidation of Exchange servers.
    
.PARAMETERS
    None
    
.EXAMPLE

#>

#  Module used
Import-Module ActiveDirectory

# List of disabled accounts
$group = Get-ADUser -Filter * -SearchBase "ou=disabled accounts,dc=mickey,dc=mouse,dc=org"

# Foreach disabled account
foreach ($x in $group) { 
    
    # used to queary alias
    $user = $x.SamAccountName
    
    # Naming convention for .pst files 
    $pstFolder = "\\NETWORKSHARE"  +"$user" + ".pst"
    
    # If .pst does not exist 
    if (!(Test-Path $pstFolder)) 
    {
    # Export mailbox as .pst
    New-MailboxExportRequest -Mailbox $user -FilePath $pstFolder 
    }
}