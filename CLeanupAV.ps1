$url = "https://github.com/murtaza7869/MK/raw/main/AVBD_Cleanup_Utility_Tool.exe"
$outputDir = "C:\Windows\Temp\"
$downloadedFilePath = $outputDir + "AVcleanUP.exe"

Invoke-WebRequest -Uri $url -OutFile $downloadedFilePath

Start-Process -FilePath "$downloadedFilePath" -PassThru -Wait
