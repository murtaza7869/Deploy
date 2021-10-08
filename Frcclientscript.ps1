mkdir C:\ProgramData\Faronics\RemoteConnect
Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/master/FRCClientCUHag.exe' -OutFile 'C:\ProgramData\Faronics\RemoteConnect\FRCClient.EXE'
Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/master/RegFRCC.reg' -OutFile 'C:\ProgramData\Faronics\RemoteConnect\RegFRCC.reg'
Start-Process -NoNewWindow -FilePath "C:\ProgramData\Faronics\RemoteConnect\RegFRCC.reg"
Start-Process -NoNewWindow -FilePath "C:\ProgramData\Faronics\RemoteConnect\FRCClient.EXE"
