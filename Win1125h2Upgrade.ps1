<#
.SYNOPSIS
    Automated Windows 11 Upgrade via Installation Assistant - Enhanced Version
.DESCRIPTION
    Downloads and runs Windows 11 Installation Assistant with fallback methods
    Designed for RMM deployment under SYSTEM context
#>

$ErrorActionPreference = "Stop"
$LogPath = "C:\Windows\Temp\Win11_Upgrade_Enhanced.log"

function Write-Log {
    param($Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -FilePath $LogPath -Append
    Write-Host $Message
}

Write-Log "=== Windows 11 Upgrade Script - Enhanced Version ==="

# Check current OS version
try {
    $OSInfo = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $OSVersion = $OSInfo.DisplayVersion
    $CurrentBuild = $OSInfo.CurrentBuild
    $UBR = $OSInfo.UBR
    Write-Log "Current OS: Windows 11 $OSVersion (Build: $CurrentBuild.$UBR)"
} catch {
    Write-Log "Warning: Could not determine OS version"
}

# Check available disk space
try {
    $CDrive = Get-PSDrive C
    $FreeSpaceGB = [math]::Round($CDrive.Free / 1GB, 2)
    Write-Log "Available disk space on C: $FreeSpaceGB GB"
    
    if ($FreeSpaceGB -lt 20) {
        Write-Log "WARNING: Less than 20GB free space. Upgrade may fail."
    }
} catch {
    Write-Log "Warning: Could not check disk space"
}

# Method 1: Try Installation Assistant
$DownloadPath = "C:\Windows\Temp\Windows11InstallationAssistant.exe"
$AssistantURL = "https://go.microsoft.com/fwlink/?linkid=2171764"

Write-Log "Method 1: Attempting Windows 11 Installation Assistant..."

try {
    if (Test-Path $DownloadPath) {
        Remove-Item $DownloadPath -Force
    }
    
    # Download
    Write-Log "Downloading Installation Assistant..."
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $AssistantURL -OutFile $DownloadPath -UseBasicParsing
    
    $FileInfo = Get-Item $DownloadPath
    Write-Log "Downloaded: $([math]::Round($FileInfo.Length/1MB, 2)) MB"
    
    # Try multiple parameter combinations
    $ParamSets = @(
        "/quietinstall /skipeula /auto upgrade",
        "/quiet /norestart",
        "/S /quiet"
    )
    
    $Success = $false
    foreach ($Params in $ParamSets) {
        Write-Log "Attempting with parameters: $Params"
        
        try {
            $Process = Start-Process -FilePath $DownloadPath -ArgumentList $Params -PassThru -Wait -NoNewWindow
            $ExitCode = $Process.ExitCode
            Write-Log "Process exited with code: $ExitCode"
            
            if ($ExitCode -eq 0) {
                $Success = $true
                Write-Log "Installation Assistant launched successfully!"
                break
            }
        } catch {
            Write-Log "Failed with params '$Params': $($_.Exception.Message)"
        }
    }
    
    if (-not $Success) {
        Write-Log "Installation Assistant failed with all parameter sets"
        Write-Log "Falling back to Method 2..."
    }
    
} catch {
    Write-Log "Method 1 failed: $($_.Exception.Message)"
}

# Method 2: Use Windows Update Assistant (alternative)
if (-not $Success) {
    Write-Log "Method 2: Attempting Windows Update Assistant..."
    
    $UpdateAssistantPath = "C:\Windows\Temp\Windows11UpdateAssistant.exe"
    $UpdateAssistantURL = "https://go.microsoft.com/fwlink/?LinkID=799445"
    
    try {
        if (Test-Path $UpdateAssistantPath) {
            Remove-Item $UpdateAssistantPath -Force
        }
        
        Write-Log "Downloading Update Assistant..."
        Invoke-WebRequest -Uri $UpdateAssistantURL -OutFile $UpdateAssistantPath -UseBasicParsing
        
        Write-Log "Launching Update Assistant..."
        Start-Process -FilePath $UpdateAssistantPath -ArgumentList "/quietinstall /skipeula /auto upgrade" -NoNewWindow
        
        Write-Log "Update Assistant launched"
    } catch {
        Write-Log "Method 2 failed: $($_.Exception.Message)"
    }
}

# Method 3: Use Media Creation Tool for in-place upgrade
Write-Log "Method 3: Using Media Creation Tool approach..."

$MediaCreationToolPath = "C:\Windows\Temp\MediaCreationTool.exe"
$MediaCreationURL = "https://go.microsoft.com/fwlink/?LinkId=2156292"

try {
    if (Test-Path $MediaCreationToolPath) {
        Remove-Item $MediaCreationToolPath -Force
    }
    
    Write-Log "Downloading Media Creation Tool..."
    Invoke-WebRequest -Uri $MediaCreationURL -OutFile $MediaCreationToolPath -UseBasicParsing
    
    # Create unattend.xml for automated setup
    $UnattendPath = "C:\Windows\Temp\unattend.xml"
    $UnattendXML = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <UserData>
                <AcceptEula>true</AcceptEula>
            </UserData>
        </component>
    </settings>
</unattend>
"@
    
    Set-Content -Path $UnattendPath -Value $UnattendXML -Force
    Write-Log "Created unattend.xml"
    
    # Launch Media Creation Tool
    Write-Log "Launching Media Creation Tool for upgrade..."
    Start-Process -FilePath $MediaCreationToolPath -ArgumentList "/auto upgrade /quiet /noreboot" -NoNewWindow
    
    Write-Log "Media Creation Tool launched"
    
} catch {
    Write-Log "Method 3 failed: $($_.Exception.Message)"
}

# Check if upgrade process is running
Write-Log "Checking for active upgrade processes..."
Start-Sleep -Seconds 5

$UpgradeProcesses = @("Windows11InstallationAssistant", "Windows10UpgraderApp", "SetupHost", "setup")
$RunningUpgrade = $false

foreach ($ProcessName in $UpgradeProcesses) {
    if (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue) {
        Write-Log "Found running upgrade process: $ProcessName"
        $RunningUpgrade = $true
    }
}

if ($RunningUpgrade) {
    Write-Log "Upgrade is in progress!"
} else {
    Write-Log "WARNING: No upgrade process detected"
    Write-Log "Please check logs at: C:\`$WINDOWS.~BT\Sources\Panther"
}

# Create monitoring script
$MonitorScriptPath = "C:\Windows\Temp\Monitor-Win11Upgrade.ps1"
$MonitorScript = @'
$LogFile = "C:\Windows\Temp\Win11_Upgrade_Monitor.log"
function Write-UpgradeLog {
    param($Message)
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $Message" | Out-File -FilePath $LogFile -Append
}

Write-UpgradeLog "=== Monitoring Windows 11 Upgrade ==="

while ($true) {
    $UpgradeProcesses = Get-Process -Name "Windows11InstallationAssistant","SetupHost","setup" -ErrorAction SilentlyContinue
    
    if ($UpgradeProcesses) {
        Write-UpgradeLog "Upgrade in progress..."
        
        # Check Panther logs
        if (Test-Path "C:\`$WINDOWS.~BT\Sources\Panther\setupact.log") {
            $SetupLog = Get-Content "C:\`$WINDOWS.~BT\Sources\Panther\setupact.log" -Tail 5
            Write-UpgradeLog "Recent setup activity: $($SetupLog -join ' | ')"
        }
    } else {
        Write-UpgradeLog "No upgrade process found. Exiting monitor."
        break
    }
    
    Start-Sleep -Seconds 60
}
'@

Set-Content -Path $MonitorScriptPath -Value $MonitorScript -Force
Write-Log "Created monitoring script at: $MonitorScriptPath"

# Start monitor in background
Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$MonitorScriptPath`"" -WindowStyle Hidden

Write-Log "=== Script Completed ==="
Write-Log "Main log: $LogPath"
Write-Log "Monitor log: C:\Windows\Temp\Win11_Upgrade_Monitor.log"
Write-Log "Setup logs: C:\`$WINDOWS.~BT\Sources\Panther"

exit 0
