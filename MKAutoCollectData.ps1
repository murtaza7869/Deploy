$url = "https://s3-us-west-2.amazonaws.com/faronics-techsupport-utilities/Download/FaronicsDataCollectionTools.exe"
$outputDir = "C:\Windows\Temp\Faronics\DCT\"
$downloadedFilePath = $outputDir + "FaronicsDCT.exe"
$DCTFolderPath = $outputDir + "FaronicsDataCollectionTools\"
$AgentDataCollectorPath = $outputDir + "FaronicsDataCollectionTools\FaronicsAgentDataCollection.exe"
$MaximumRuntimeSeconds = 5

$uploadUrl = "https://www.dropbox.com/request/Osl0qiXmEtmplyw3MNkq"
$uploadPath = "c:\Windows\Temp\Faronics\DCT\*.zip"
If (Test-Path $outputDir) {
    rm -r "$outputDir" | out-null
}

If (Test-Path $DCTFolderPath) {
	rm -r "$DCTFolderPath" | out-null
}

mkdir "$outputDir" | out-null

Invoke-WebRequest -Uri $url -OutFile $downloadedFilePath

$process = Start-Process -FilePath "$downloadedFilePath" -PassThru
try
{
    $process | Wait-Process -Timeout $MaximumRuntimeSeconds -ErrorAction Stop
    # Write-Warning -Message 'Process successfully completed within timeout.'
}
catch
{
    # Write-Warning -Message 'Process exceeded timeout, will be killed now.'
    $process | Stop-Process -Force
}

Write-Warning -Message "Tool path is '$AgentDataCollectorPath'"

Start-Process -FilePath "$AgentDataCollectorPath" -ArgumentList "/dbg:n" -WorkingDirectory "$DCTFolderPath" -Wait

$zipFileName = Get-ChildItem -Path "$DCTFolderPath" -Filter *.zip |Select -First 1
$fileToUpload = $DCTFolderPath + $zipFileName

Write-Warning -Message "Path of ZIP file to upload is '$fileToUpload'"

Invoke-RestMethod -Uri $uploadUrl -Method Post -InFile "$fileToUpload" -UseDefaultCredentials
