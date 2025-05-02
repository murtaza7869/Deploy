# PowerShell Script to Display Windows Version Details
Write-Host "`n============== WINDOWS VERSION INFORMATION ==============" -ForegroundColor Cyan

# Get basic OS information
$osInfo = Get-CimInstance Win32_OperatingSystem
Write-Host "`nOperating System:" -ForegroundColor Green
Write-Host "  Caption:             $($osInfo.Caption)"
Write-Host "  Version:             $($osInfo.Version)"
Write-Host "  Build Number:        $($osInfo.BuildNumber)"
Write-Host "  OS Architecture:     $($osInfo.OSArchitecture)"
Write-Host "  Windows Directory:   $($osInfo.WindowsDirectory)"
Write-Host "  Serial Number:       $($osInfo.SerialNumber)"
Write-Host "  Install Date:        $($osInfo.InstallDate)"
Write-Host "  Last Boot Up Time:   $($osInfo.LastBootUpTime)"

# Get more detailed Windows version information
$winver = [System.Environment]::OSVersion.Version
Write-Host "`nDetailed Version Info:" -ForegroundColor Green
Write-Host "  Major Version:       $($winver.Major)"
Write-Host "  Minor Version:       $($winver.Minor)"
Write-Host "  Build:               $($winver.Build)"
Write-Host "  Revision:            $($winver.Revision)"

# Get Windows product information
try {
    $productInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    Write-Host "`nProduct Information:" -ForegroundColor Green
    Write-Host "  Product Name:        $($productInfo.ProductName)"
    Write-Host "  Edition ID:          $($productInfo.EditionID)"
    Write-Host "  Release ID:          $($productInfo.ReleaseId)"
    Write-Host "  Display Version:     $($productInfo.DisplayVersion)"
    Write-Host "  UBR:                 $($productInfo.UBR)"
    
    # Get Windows 10/11 specific version info (if available)
    if ($null -ne $productInfo.CurrentBuildNumber) {
        Write-Host "  Current Build:       $($productInfo.CurrentBuildNumber)"
    }
    if ($null -ne $productInfo.CurrentBuild) {
        Write-Host "  Current Build:       $($productInfo.CurrentBuild)"
    }
} catch {
    Write-Host "  Could not retrieve registry product information." -ForegroundColor Yellow
}

# Get Windows Update information
try {
    $hotFixes = Get-HotFix | Sort-Object -Property InstalledOn -Descending
    Write-Host "`nUpdate Information:" -ForegroundColor Green
    Write-Host "  Installed Updates:   $($hotFixes.Count) updates found"
    Write-Host "  Latest Updates:" 
    $hotFixes | Select-Object -First 5 | ForEach-Object {
        Write-Host "    $($_.HotFixID) - Installed: $($_.InstalledOn)"
    }
} catch {
    Write-Host "  Could not retrieve Windows Update information." -ForegroundColor Yellow
}

# Get BIOS information
try {
    $biosInfo = Get-CimInstance Win32_BIOS
    Write-Host "`nBIOS Information:" -ForegroundColor Green
    Write-Host "  Manufacturer:        $($biosInfo.Manufacturer)"
    Write-Host "  Version:             $($biosInfo.SMBIOSBIOSVersion)" 
    Write-Host "  Serial Number:       $($biosInfo.SerialNumber)"
    Write-Host "  Release Date:        $($biosInfo.ReleaseDate)"
} catch {
    Write-Host "  Could not retrieve BIOS information." -ForegroundColor Yellow
}

Write-Host "`n=========================================================" -ForegroundColor Cyan
