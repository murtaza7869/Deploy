
Set-ExecutionPolicy RemoteSigned
md C:\temp\toshiba
Invoke-WebRequest 'https://business.toshiba.com/downloads/KB/f1Ulds/18128/eb4-ebn-Uni-3264bit-7212483517.zip?_ga=2.155413755.1507334097.1627496542-1831136956.1627042885' -Outfile 'C:\Temp\toshiba.zip'
ping -n 5 127.0.0.1
Expand-Archive -LiteralPath C:\Temp\toshiba.zip -DestinationPath C:\Temp\toshiba
ping -n 5 127.0.0.1
Start-Process -Wait -FilePath "C:\Temp\toshiba\essetup.exe" -ArgumentList "/S" -PassThru
