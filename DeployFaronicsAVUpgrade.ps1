# Faronics Anti-Virus Check and Update Script
# This script checks for Faronics Anti-Virus installation, verifies the version,
# and downloads/installs the latest version if needed.

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# Define variables
$latestVersion = "4.38.8102.638"
$installerUrl = "https://faronics-deploy-na-production-installers.s3.us-west-2.amazonaws.com/Download/ProductInstallers/AntiVirus_BD_64.msi"
$installerPath = "$env:TEMP\FaronicsAV.msi"
$logPath = "$env:TEMP\FaronicsAV_Install.log"

# Function to write to console with timestamp
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $false)]
        [string]$ForegroundColor = "White"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $ForegroundColor
}

# Function to check if Faronics Anti-Virus is installed and get its version
function Get-FaronicsAVInfo {
    try {
        # Check in the 64-bit registry path first
        $uninstallKeys = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue
        
        # Then check the 32-bit registry path if on a 64-bit system
        if (Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") {
            $uninstallKeys += Get-ChildItem -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue
        }
        
        foreach ($key in $uninstallKeys) {
            $keyPath = $key.PSPath
            $displayName = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).DisplayName
            
            if ($displayName -eq "Faronics Anti-Virus") {
                $displayVersion = (Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue).DisplayVersion
                return @{
                    Installed = $true
                    Version = $displayVersion
                }
            }
        }
        
        # If we get here, Faronics Anti-Virus is not installed
        return @{
            Installed = $false
            Version = $null
        }
    }
    catch {
        Write-Log "Error checking for Faronics Anti-Virus: $_" -ForegroundColor "Red"
        return @{
            Installed = $false
            Version = $null
        }
    }
}

# Function to download the installer
function Download-Installer {
    try {
        Write-Log "Downloading Faronics Anti-Virus installer..." -ForegroundColor "Yellow"
        
        # Create a WebClient object
        $webClient = New-Object System.Net.WebClient
        
        # Download the file
        $webClient.DownloadFile($installerUrl, $installerPath)
        
        # Check if file was downloaded successfully
        if (Test-Path $installerPath) {
            Write-Log "Download completed successfully." -ForegroundColor "Green"
            return $true
        }
        else {
            Write-Log "Download failed - file not found at destination." -ForegroundColor "Red"
            return $false
        }
    }
    catch {
        Write-Log "Error downloading installer: $_" -ForegroundColor "Red"
        return $false
    }
}

# Function to install Faronics Anti-Virus
function Install-FaronicsAV {
    try {
        Write-Log "Starting Faronics Anti-Virus installation..." -ForegroundColor "Yellow"
        Write-Log "The machine may reboot once installation is complete." -ForegroundColor "Yellow"
        
        # Run the MSI installer silently
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /qn /l*v `"$logPath`"" -PassThru -Wait
        
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            # 3010 means success but reboot required
            Write-Log "Installation initiated successfully." -ForegroundColor "Green"
            return $true
        }
        else {
            Write-Log "Installation failed with exit code: $($process.ExitCode)" -ForegroundColor "Red"
            Write-Log "Check the log file at $logPath for details." -ForegroundColor "Red"
            return $false
        }
    }
    catch {
        Write-Log "Error during installation: $_" -ForegroundColor "Red"
        return $false
    }
}

# Main script execution
try {
    Write-Log "Checking for Faronics Anti-Virus installation..." -ForegroundColor "Cyan"
    
    $avInfo = Get-FaronicsAVInfo
    
    if (-not $avInfo.Installed) {
        Write-Log "Faronics AV Not installed" -ForegroundColor "Yellow"
        
        # Download and install the latest version
        if (Download-Installer) {
            Install-FaronicsAV
        }
    }
    else {
        # Compare versions
        if ([System.Version]$avInfo.Version -ge [System.Version]$latestVersion) {
            Write-Log "Latest Faronics AV version $latestVersion is already installed" -ForegroundColor "Green"
        }
        else {
            Write-Log "Faronics AV version $($avInfo.Version) is installed, but the latest version is $latestVersion" -ForegroundColor "Yellow"
            
            # Download and install the latest version
            if (Download-Installer) {
                Install-FaronicsAV
            }
        }
    }
}
catch {
    Write-Log "An unexpected error occurred: $_" -ForegroundColor "Red"
    exit 1
}

# Exit gracefully
exit 0
