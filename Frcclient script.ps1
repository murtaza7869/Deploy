mkdir C:\ProgramData\Faronics\RemoteConnect
Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/master/FRCClient.EXE' -OutFile 'C:\ProgramData\Faronics\RemoteConnect\FRCClient.EXE'
Start-Process -FilePath "C:\ProgramData\Faronics\RemoteConnect\FRCClient.EXE /regserver"