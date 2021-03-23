Invoke-WebRequest 'https://github.com/murtaza7869/Deploy/blob/master/UpdateCustomerSiteMay21.exe' -OutFile 'C:\Windows\temp\UpdateCustomerSiteMay21.exe'
# Start-Process -FilePath "CuyahogalibUpdateCustomerSite.exe" -WorkingDirectory "C:\Windows\temp"
Start-Process -FilePath "C:\Windows\temp\UpdateCustomerSiteMay21.exe"

