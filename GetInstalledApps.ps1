Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize | Out-File -FilePath "'C:\windows\temp\InstalledProgram.log'"
cat "'C:\windows\temp\InstalledProgram.log'"
