$cacheIP=$args[0]
If (Test-Path -Path C:\Windows\temp\WUCoreCacheSrvFix.zip ){
Remove-Item 'C:\Windows\temp\WUCoreCacheSrvFix.zip' -Recurse | out-null
}
Invoke-WebRequest 'https://faronics.digitalpigeon.com/msg/3ZRlkJ44EeydrQa5ZeB_WQ/1ksikRfRJq28xVU9KAd9FA/file/ddb3d470-9e38-11ec-a2cc-02d7d55f1e7d/download# - WUCoreCacheSrvFix - Override Cache server with reg key - WUCoreCacheSrvFix.zip' -OutFile 'C:\Windows\temp\WUCoreCacheSrvFix.zip'
If (Test-Path -Path C:\ProgramData\Faronics\CustomFix ){
Remove-Item 'C:\ProgramData\Faronics\CustomFix' -Recurse | out-null
}
md C:\ProgramData\Faronics\CustomFix
Expand-Archive -LiteralPath C:\Windows\temp\WUCoreCacheSrvFix.zip -DestinationPath C:\ProgramData\Faronics\CustomFix
Stop-Service -Name "FWUSvc" -Force
ping localhost -n 15
If (Test-Path -Path C:\ProgramData\Faronics\StorageSpace\SUC\Org_WuCore.dis ){
Remove-Item 'C:\ProgramData\Faronics\StorageSpace\SUC\Org_WuCore.dis' -Recurse | out-null
}
Rename-Item C:\ProgramData\Faronics\StorageSpace\SUC\WUCore.dll Org_WuCore.dis
Copy-Item "C:\ProgramData\Faronics\customFix\WUCore-64bit.dll" -Destination "C:\ProgramData\Faronics\StorageSpace\SUC\WUCore.dll"
New-Item -Path HKLM:\SOFTWARE\Faronics
New-Item -Path HKLM:\SOFTWARE\Faronics\CacheServerOverride
Set-ItemProperty HKLM:\SOFTWARE\Faronics\CacheServerOverride -Name ServerIP -Value $cacheIP -Type String
Set-ItemProperty HKLM:\SOFTWARE\Faronics\CacheServerOverride -Name PortNo -Value "7726" -Type Dword
ping localhost -n 5
Start-Service -Name "FWUSvc"
ping localhost
