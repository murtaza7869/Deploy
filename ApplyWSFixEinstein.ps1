Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/master/WSFix.zip' -Outfile 'C:\Windows\Temp\WSFix.zip'
ping -n 5 127.0.0.1
md 'C:\Program Files\Faronics\WINSelect\Temp'
Expand-Archive -LiteralPath C:\Windows\Temp\WSFix.zip -DestinationPath 'C:\Program Files\Faronics\WINSelect\Temp\' -Force
Rename-Item -Path "C:\Program Files\Faronics\WINSelect\Win32\WSProtector.dll" -NewName "org_WSProtector.dll" -Force
Copy-Item -Path 'C:\Program Files\Faronics\WINSelect\Temp\WSFix\Win32\WSProtector.dll'-Destination 'C:\Program Files\Faronics\WINSelect\Win32\' -Force
Rename-Item -Path "C:\Program Files\Faronics\WINSelect\WSProtector.dll" -NewName "org_WSProtector.dll" -Force
Copy-Item -Path 'C:\Program Files\Faronics\WINSelect\Temp\WSFix\x64\WSProtector.dll' -Destination 'C:\Program Files\Faronics\WINSelect\' -Force
ping -n 5 127.0.0.1
Restart-Computer
