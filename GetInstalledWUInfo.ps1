# Get-WindowsUpdateHistory-Simple.ps1
# A reliable script to display Windows update information

# Get all Windows updates using WMI
Write-Host "Retrieving Windows updates..." -ForegroundColor Cyan
$updates = Get-WmiObject -Class Win32_QuickFixEngineering | 
    Select-Object @{Name="InstallDate";Expression={
        # Convert date format if available
        if ($_.InstalledOn) {
            $_.InstalledOn
        } else {
            # Some updates store date differently
            $date = $null
            if ($_.InstallDate) {
                try {
                    $year = $_.InstallDate.Substring(0,4)
                    $month = $_.InstallDate.Substring(4,2)
                    $day = $_.InstallDate.Substring(6,2)
                    $date = Get-Date -Year $year -Month $month -Day $day -ErrorAction SilentlyContinue
                } catch {}
            }
            $date
        }
    }}, 
    HotFixID, Description, InstalledBy |
    Sort-Object InstallDate -Descending

# Display header
Write-Host "`nWINDOWS UPDATE HISTORY" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

# Check if updates were found
if (!$updates -or $updates.Count -eq 0) {
    Write-Host "`nNo Windows updates were found using this method.`n" -ForegroundColor Yellow
    
    # Alternative approach
    Write-Host "Trying alternative approach..." -ForegroundColor Yellow
    $hotfixes = Get-HotFix | Sort-Object InstalledOn -Descending
    
    if ($hotfixes -and $hotfixes.Count -gt 0) {
        Write-Host "Found $($hotfixes.Count) updates using Get-HotFix cmdlet.`n" -ForegroundColor Green
        $hotfixes | Format-Table -Property HotFixID, Description, InstalledOn, InstalledBy -AutoSize
    } else {
        Write-Host "No updates found with alternative method either.`n" -ForegroundColor Red
        Write-Host "This may be due to system configuration or permissions.`n"
    }
} 
else {
    # Display update count
    Write-Host "`nFound $($updates.Count) installed updates.`n" -ForegroundColor Green
    
    # Output formatted table
    $updates | Format-Table -Property HotFixID, Description, InstallDate, InstalledBy -AutoSize
    
    # Export option
    Write-Host "`nTo export this data to CSV, run:" -ForegroundColor Cyan
    Write-Host 'Get-WmiObject -Class Win32_QuickFixEngineering | Export-Csv -Path "C:\WindowsUpdateHistory.csv" -NoTypeInformation' -ForegroundColor White
    
    # Alternative method info
    Write-Host "`nAlternative method to view updates:" -ForegroundColor Cyan
    Write-Host 'Get-HotFix | Sort-Object InstalledOn -Descending | Format-Table' -ForegroundColor White
}

# Provide additional info about Windows Update log
Write-Host "`nADDITIONAL INFORMATION:" -ForegroundColor Cyan
Write-Host "Windows Update logs can be found at: C:\Windows\Logs\WindowsUpdate\" -ForegroundColor White
Write-Host "You can also check update history in Settings > Windows Update > Update History" -ForegroundColor White
