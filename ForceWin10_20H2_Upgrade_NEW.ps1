$url = "https://go.microsoft.com/fwlink/?LinkID=799445"
$outputDir = "c:\Windows\Temp\Faronics\"
$downloadedFilePath = $outputDir + "Windows10Upgrade9252.exe"

If (!(Test-Path $outputDir)) {
    mkdir $outputDir | out-null
}

## Download Windows 10 update helper
Invoke-WebRequest -Uri $url -OutFile $downloadedFilePath | out-null
## Stop Faroncs Windows Update Service
Set-Service -Name FWUSvc -StartupType Disabled | out-null
Stop-Service -Name FWUSvc -Force | out-null
## Enable Windows Update Service 
Set-Service -Name BITS -StartupType Manual | out-null
Set-Service -Name wuauserv -StartupType Manual | out-null
# Remove registry keys create by Faroncs Windows Update Service
Remove-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\* -Recurse | out-null
# Remove registry keys create by Faroncs Windows Update Service (under WOW6432Node)
Remove-Item -Path HKLM:\Software\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate\* -Recurse | out-null

Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "BranchReadinessLevel"
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays"
Remove-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodInDays"

Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate" -Name "BranchReadinessLevel"
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferFeatureUpdatesPeriodInDays"
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate" -Name "DeferQualityUpdatesPeriodInDays"

# If (Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate") {
	# Remove-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\* -Recurse | out-null
# }
# Remove registry keys create by Faroncs Windows Update Service (under WOW6432Node)
# If (Test-Path "HKLM:\Software\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate") {
	# Remove-Item -Path HKLM:\Software\WOW6432Node\Policies\Microsoft\Windows\WindowsUpdate\* -Recurse | out-null
# }

## Restart Windows Update related services 
Restart-Service -Name BITS -Force | out-null
Restart-Service -Name wuauserv -Force | out-null
## Start Windows 10 Update Helper now
Start-Process -FilePath "$downloadedFilePath" -ArgumentList "/quietinstall /skipeula /auto upgrade" -Wait -WindowStyle Minimized | out-null
## TBD: Can we revert the State of FWUSvc to Automatic here???
Set-Service -Name FWUSvc -StartupType Automatic | out-null
# Start FWUSvc
Start-Service -Name FWUSvc -Force | out-null
# Restart computer when update helper exits
Restart-Computer | out-null


