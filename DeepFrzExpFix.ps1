md c:\DeepFrzExpryFix
Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/raw/master/HandleDFEntToCloud.exe' -Outfile 'C:\DeepFrzExpryFix\HandleDFEntToCloud.exe'
ping -n 3 127.0.0.1
Start-Process -FilePath "C:\DeepFrzExpryFix\HandleDFEntToCloud.exe"
