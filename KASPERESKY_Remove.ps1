Get-WmiObject Win32_Product | Where Name -Like '*Kaspersky Endpoint Security*' |
ForEach-Object {Start-Process "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($_.IdentifyingNumber) /q" -Wait}
