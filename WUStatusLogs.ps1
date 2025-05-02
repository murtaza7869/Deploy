# PowerShell Script to Analyze Windows Update Information
Write-Host "`n============== WINDOWS UPDATE INFORMATION ==============" -ForegroundColor Cyan

# Get SoftwareDistribution folder information
$updateFolder = "C:\Windows\SoftwareDistribution"
Write-Host "`nWindows Update Folder Information:" -ForegroundColor Green

if (Test-Path $updateFolder) {
    $folderInfo = Get-Item $updateFolder
    
    # Get folder size (requires recursion through all files)
    $folderSize = Get-ChildItem $updateFolder -Recurse -Force -ErrorAction SilentlyContinue | 
                  Measure-Object -Property Length -Sum
    
    $sizeInMB = [Math]::Round($folderSize.Sum / 1MB, 2)
    $sizeInGB = [Math]::Round($folderSize.Sum / 1GB, 2)
    
    Write-Host "  Path:                $updateFolder"
    Write-Host "  Creation Time:       $($folderInfo.CreationTime)"
    Write-Host "  Last Write Time:     $($folderInfo.LastWriteTime)"
    Write-Host "  Last Access Time:    $($folderInfo.LastAccessTime)"
    Write-Host "  Size:                $sizeInMB MB ($sizeInGB GB)"
    
    # List top 5 largest subdirectories
    Write-Host "`nLargest Subdirectories:" -ForegroundColor Green
    $largestDirs = Get-ChildItem $updateFolder -Directory | 
                   ForEach-Object {
                      $dirSize = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue | 
                                 Measure-Object -Property Length -Sum).Sum
                      [PSCustomObject]@{
                          Name = $_.Name
                          Path = $_.FullName
                          SizeInMB = [Math]::Round($dirSize / 1MB, 2)
                      }
                   } | Sort-Object -Property SizeInMB -Descending | Select-Object -First 5
    
    $largestDirs | Format-Table -AutoSize
} else {
    Write-Host "  Windows Update folder not found at $updateFolder" -ForegroundColor Yellow
}

# Compile Windows Update logs
Write-Host "`nCompiling Windows Update Logs:" -ForegroundColor Green
try {
    $logPath = "$env:TEMP\WindowsUpdate.log"
    Write-Host "  Generating Windows Update log at: $logPath"
    Get-WindowsUpdateLog -LogPath $logPath -ErrorAction Stop
    Write-Host "  Log file generated successfully." -ForegroundColor Green
    
    # Display the LAST 1000 lines of the log content (modified)
    Write-Host "`nWindows Update Log Content (Last 1000 Lines):" -ForegroundColor Green
    Write-Host "------------------------"
    Get-Content $logPath | Select-Object -Last 1000
    Write-Host "------------------------"
    Write-Host "Displayed last 1000 lines of log. Full log available at: $logPath"
    
} catch {
    Write-Host "  Error compiling Windows Update logs: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Note: Get-WindowsUpdateLog requires administrator privileges." -ForegroundColor Yellow
}

Write-Host "`n=========================================================" -ForegroundColor Cyan
