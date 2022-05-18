Stop-Service wuauserv
Remove-Item -Path 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\*' -recurse -force
Start-Service wuauserv
