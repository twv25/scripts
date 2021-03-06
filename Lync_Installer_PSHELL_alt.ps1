#Authored by Thomas Vasile
#Automated Deployment of Lync
#An alternative to my batch script using poweshell

#Path to the Setup.exe
$64_Install = "FILE"
$32_Install = "FILE"

#Switches used
$Arguments = @( '/install' , '/silent')

#Check for 64 Bit
$Determine_Bit = Test-Path "C:\Program Files (x86)\"

#Checks to see if Lync is already installed
$32_Installed_already = Test-Path "C:\Program Files\Microsoft Lync\Media\" 
$64_Installed_already = Test-Path "C:\Program Files (x86)\Microsoft Lync\Media\"

#Checks if Lync is already installed
If ($32_Installed_already -or $64_Installed_already -eq $true) {
    Write-Host "Lync Client Already Installed" 
    Exit
}

#Installs Lync based on Bit
If ($Determine_Bit -eq $true) {
    Start-Process $64_Install -ArgumentList $Arguments 
    Exit
}

else {
    Start-Process $32_Install -ArgumentList $Arguments 
    Exit
}