# Get-DetailedWindowsUpdateHistory.ps1
# Alternative script that doesn't require PSWindowsUpdate module

# Create a COM object for Windows Update
$session = New-Object -ComObject "Microsoft.Update.Session"
$searcher = $session.CreateUpdateSearcher()

# Get update history (0-20 are different update types, we'll use 1 which is 'Installation')
# This will retrieve the last 1000 updates (adjust number if needed)
$updateHistory = $searcher.GetUpdateHistory(0, 1000) | Where-Object {$_.Operation -eq 1}

# Process and format the update information
$formattedUpdates = $updateHistory | ForEach-Object {
    # Parse KB number from title when available
    $kbNumber = if ($_.Title -match "KB\d+") { $matches[0] } else { "N/A" }
    
    # Get result description
    $resultText = switch ($_.ResultCode) {
        0 { "Not Started" }
        1 { "In Progress" }
        2 { "Succeeded" }
        3 { "Succeeded With Errors" }
        4 { "Failed" }
        5 { "Aborted" }
        default { "Unknown ($($_.ResultCode))" }
    }
    
    # Create custom object with formatted properties
    [PSCustomObject]@{
        "Date" = $_.Date.ToString("yyyy-MM-dd")
        "KB Number" = $kbNumber
        "Title" = $_.Title
        "Result" = $resultText
        "Description" = $_.Description
        "Client Application" = $_.ClientApplicationID
    }
}

# Output header
Write-Host "`nDETAILED WINDOWS UPDATE HISTORY" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Check if updates were found
if ($formattedUpdates.Count -eq 0) {
    Write-Host "`nNo Windows update history found on this system.`n" -ForegroundColor Yellow
} 
else {
    # Display update count
    Write-Host "`nFound $($formattedUpdates.Count) updates in history.`n" -ForegroundColor Green
    
    # Output formatted table (limit display width for better readability)
    $formattedUpdates | Select-Object Date, "KB Number", Result, Title | 
        Format-Table -AutoSize -Wrap
    
    # Summary statistics
    $succeededCount = ($formattedUpdates | Where-Object Result -eq "Succeeded").Count
    $failedCount = ($formattedUpdates | Where-Object Result -eq "Failed").Count
    
    Write-Host "`nSUMMARY:" -ForegroundColor Cyan
    Write-Host "Total Updates: $($formattedUpdates.Count)" -ForegroundColor White
    Write-Host "Succeeded: $succeededCount" -ForegroundColor Green
    Write-Host "Failed: $failedCount" -ForegroundColor $(if ($failedCount -gt 0) { "Red" } else { "Green" })
    Write-Host "Most Recent Update: $($formattedUpdates[0].Date)" -ForegroundColor White
    
    # Export option
    Write-Host "`nTo export this data to CSV, run:" -ForegroundColor Cyan
    Write-Host '$session = New-Object -ComObject "Microsoft.Update.Session"; $searcher = $session.CreateUpdateSearcher(); $updateHistory = $searcher.GetUpdateHistory(0, 1000) | Where-Object {$_.Operation -eq 1}; $updateHistory | Select-Object Date, Title, Description | Export-Csv -Path "C:\WindowsUpdateHistory.csv" -NoTypeInformation' -ForegroundColor White
    
    # Offer to show detailed information for a specific update
    Write-Host "`nFor detailed information about a specific update, use:" -ForegroundColor Cyan
    Write-Host '$formattedUpdates | Where-Object "KB Number" -eq "KB5036892" | Format-List *' -ForegroundColor White
}
