# Get-WindowsUpdateHistory.ps1
# Script to display all installed Windows updates in a formatted table

# Get all installed Windows updates
$updates = Get-WmiObject -Class Win32_QuickFixEngineering | 
    Select-Object HotFixID, Description, InstalledOn, InstalledBy |
    Sort-Object InstalledOn -Descending

# Define table formatting
$tableFormat = @{
    Property = "HotFixID", "Description", "InstalledOn", "InstalledBy"
    AutoSize = $true
    Wrap = $false
}

# Output header
Write-Host "`nWINDOWS UPDATE HISTORY" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

# Check if updates were found
if ($updates.Count -eq 0) {
    Write-Host "`nNo Windows updates were found on this system.`n" -ForegroundColor Yellow
} 
else {
    # Display update count
    Write-Host "`nFound $($updates.Count) installed updates.`n" -ForegroundColor Green
    
    # Output formatted table
    $updates | Format-Table @tableFormat
    
    # Output summary
    Write-Host "Most recent update: $($updates[0].InstalledOn)" -ForegroundColor Green
    Write-Host "Oldest update: $($updates[-1].InstalledOn)" -ForegroundColor Yellow
}

# Display additional information about how to get more detailed update info
Write-Host "`nNote: For more detailed update information, consider using:`n" -ForegroundColor Cyan
Write-Host "Get-WindowsUpdate -History | Format-Table" -ForegroundColor Cyan
Write-Host "(Requires the PSWindowsUpdate module)`n"
