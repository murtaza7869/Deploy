# Install-PSWindowsUpdate-And-ShowHistory.ps1
# Script to install PSWindowsUpdate module and display detailed Windows update history

# Check if PSWindowsUpdate module is already installed
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "PSWindowsUpdate module not found. Installing..." -ForegroundColor Yellow
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "This script requires administrator privileges to install modules." -ForegroundColor Red
        Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Red
        exit
    }
    
    # Set PSGallery as trusted repository if needed
    if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne "Trusted") {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Write-Host "PSGallery set as trusted repository." -ForegroundColor Green
    }
    
    # Install the module
    try {
        Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
        Write-Host "PSWindowsUpdate module installed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install PSWindowsUpdate module: $_" -ForegroundColor Red
        exit
    }
}

# Import the module
Import-Module PSWindowsUpdate

# Get Windows Update history with detailed information
Write-Host "`nRETRIEVING DETAILED WINDOWS UPDATE HISTORY" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Get update history
$detailedUpdates = Get-WindowsUpdate -History | 
    Select-Object Date, Title, Status, Description, SupportUrl, ResultCode |
    Sort-Object Date -Descending

# Check if updates were found
if ($detailedUpdates.Count -eq 0) {
    Write-Host "`nNo Windows update history found on this system.`n" -ForegroundColor Yellow
} 
else {
    # Create a formatted table with custom columns
    $formattedUpdates = $detailedUpdates | ForEach-Object {
        [PSCustomObject]@{
            "Date" = $_.Date.ToString("yyyy-MM-dd")
            "Status" = $_.Status
            "KB Number" = if ($_.Title -match "KB\d+") { $matches[0] } else { "N/A" }
            "Title" = $_.Title
            "Result" = switch ($_.ResultCode) {
                0 { "Not Started" }
                1 { "In Progress" }
                2 { "Succeeded" }
                3 { "Succeeded With Errors" }
                4 { "Failed" }
                5 { "Aborted" }
                default { "Unknown ($($_.ResultCode))" }
            }
        }
    }
    
    # Display update count
    Write-Host "`nFound $($formattedUpdates.Count) updates in history.`n" -ForegroundColor Green
    
    # Output formatted table
    $formattedUpdates | Format-Table -AutoSize -Wrap
    
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
    Write-Host 'Get-WindowsUpdate -History | Export-Csv -Path "C:\WindowsUpdateHistory.csv" -NoTypeInformation' -ForegroundColor White
}
