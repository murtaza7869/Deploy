Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/blob/master/CuyahogaLibUpdateCustomerSite.exe' -OutFile 'C:\Windows\temp\CuyahogaLibUpdateCustomerSite.exe'
# Start-Process -FilePath "CuyahogalibUpdateCustomerSite.exe" -WorkingDirectory "C:\Windows\temp"
Start-Process -FilePath "C:\Windows\temp\CuyahogalibUpdateCustomerSite.exe"

