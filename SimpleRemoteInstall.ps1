md c:\Deploy
Invoke-WebRequest 'http://remote.synq3.net/access/Remote%20Access-windows64-online.exe?language=en&hostname=http%3A%2F%2Fremote.synq3.net&ie=ie.exe' -Outfile 'C:\Deploy\SimpleRemote.exe'
ping -n 5 127.0.0.1
Start-Process -FilePath "C:\Deploy\SimpleRemote.exe" "/S /Name=Oklahoma City /AutoDetect /Host=udp://remote.synq3.net"
