#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Silently uninstalls Microsoft Office Professional Plus 2019 Volume License
.DESCRIPTION
    This script removes MS Office Pro 2019 using the ClickToRun engine in silent mode
    Designed to run under SYSTEM account via RMM deployment
.NOTES
    Author: IT Admin
    Date: 2025-01-06
    Version: 1.0
#>

# Set up logging
$LogPath = "$env:ProgramData\OfficeUninstall"
$LogFile = "$LogPath\OfficeUninstall_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Create log directory if it doesn't exist
if (-not (Test-Path -Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('Info','Warning','Error')]
        [string]$Level = 'Info'
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage
    
    # Also output to console for debugging
    switch ($Level) {
        'Warning' { Write-Warning $Message }
        'Error' { Write-Error $Message }
        default { Write-Host $Message }
    }
}

# Start logging
Write-Log "========================================" -Level Info
Write-Log "Office Uninstall Script Started" -Level Info
Write-Log "Running as: $env:USERNAME" -Level Info
Write-Log "Computer: $env:COMPUTERNAME" -Level Info

try {
    # Define the ClickToRun executable path
    $ClickToRunPath = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
    
    # Verify ClickToRun exists
    if (-not (Test-Path -Path $ClickToRunPath)) {
        Write-Log "ClickToRun executable not found at: $ClickToRunPath" -Level Error
        exit 1
    }
    
    Write-Log "ClickToRun executable found at: $ClickToRunPath" -Level Info
    
    # Check if Office is currently running and close it
    Write-Log "Checking for running Office applications..." -Level Info
    $OfficeApps = @('WINWORD', 'EXCEL', 'POWERPNT', 'OUTLOOK', 'ONENOTE', 'MSACCESS', 'MSPUB', 'VISIO', 'PROJECT')
    
    foreach ($App in $OfficeApps) {
        $Process = Get-Process -Name $App -ErrorAction SilentlyContinue
        if ($Process) {
            Write-Log "Closing $App..." -Level Warning
            Stop-Process -Name $App -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }
    }
    
    # Build the uninstall arguments
    $Arguments = @(
        'scenario=install'
        'scenariosubtype=ARP'
        'sourcetype=None'
        'productstoremove=ProPlus2019Volume.16_en-us_x-none'
        'culture=en-us'
        'version.16=16.0'
        'DisplayLevel=False'  # This ensures silent mode
        'AcceptEULA=True'     # Automatically accept EULA
        'ForceCloseApps=True' # Force close any running Office apps
    )
    
    $ArgumentString = $Arguments -join ' '
    
    Write-Log "Executing uninstall with arguments: $ArgumentString" -Level Info
    
    # Start the uninstall process
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $ClickToRunPath
    $ProcessInfo.Arguments = $ArgumentString
    $ProcessInfo.RedirectStandardOutput = $true
    $ProcessInfo.RedirectStandardError = $true
    $ProcessInfo.UseShellExecute = $false
    $ProcessInfo.CreateNoWindow = $true
    
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessInfo
    
    Write-Log "Starting Office uninstall process..." -Level Info
    $Process.Start() | Out-Null
    
    # Wait for the process to complete (timeout after 30 minutes)
    $Timeout = 1800000 # 30 minutes in milliseconds
    if ($Process.WaitForExit($Timeout)) {
        $ExitCode = $Process.ExitCode
        $StdOut = $Process.StandardOutput.ReadToEnd()
        $StdErr = $Process.StandardError.ReadToEnd()
        
        if ($StdOut) {
            Write-Log "Process Output: $StdOut" -Level Info
        }
        
        if ($StdErr) {
            Write-Log "Process Errors: $StdErr" -Level Warning
        }
        
        Write-Log "Uninstall process completed with exit code: $ExitCode" -Level Info
        
        # Check exit code
        switch ($ExitCode) {
            0 { 
                Write-Log "Office uninstall completed successfully!" -Level Info
                $Success = $true
            }
            3010 { 
                Write-Log "Office uninstall completed successfully but requires restart." -Level Warning
                $Success = $true
                $RequiresRestart = $true
            }
            default { 
                Write-Log "Office uninstall may have failed. Exit code: $ExitCode" -Level Error
                $Success = $false
            }
        }
    }
    else {
        Write-Log "Uninstall process timed out after 30 minutes" -Level Error
        $Process.Kill()
        $Success = $false
    }
    
    # Clean up the process
    $Process.Dispose()
    
    # Verify Office removal by checking registry
    Write-Log "Verifying Office removal..." -Level Info
    $UninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $OfficeKeys = Get-ChildItem -Path $UninstallKey -ErrorAction SilentlyContinue | 
                  Where-Object { $_.GetValue("DisplayName") -like "*Office Professional Plus 2019*" }
    
    if ($OfficeKeys) {
        Write-Log "Warning: Office registry entries still present after uninstall" -Level Warning
        foreach ($Key in $OfficeKeys) {
            Write-Log "  Found: $($Key.GetValue('DisplayName'))" -Level Warning
        }
    }
    else {
        Write-Log "Office registry entries successfully removed" -Level Info
    }
    
    # Clean up leftover Office scheduled tasks
    Write-Log "Cleaning up Office scheduled tasks..." -Level Info
    $OfficeTasks = Get-ScheduledTask -TaskPath "\Microsoft\Office\*" -ErrorAction SilentlyContinue
    if ($OfficeTasks) {
        foreach ($Task in $OfficeTasks) {
            try {
                Unregister-ScheduledTask -TaskName $Task.TaskName -TaskPath $Task.TaskPath -Confirm:$false -ErrorAction Stop
                Write-Log "Removed scheduled task: $($Task.TaskName)" -Level Info
            }
            catch {
                Write-Log "Failed to remove scheduled task: $($Task.TaskName) - $_" -Level Warning
            }
        }
    }
    
    # Final status
    if ($Success) {
        Write-Log "========================================" -Level Info
        Write-Log "Office uninstall completed successfully!" -Level Info
        
        if ($RequiresRestart) {
            Write-Log "IMPORTANT: System restart required to complete uninstall" -Level Warning
            
            # Create a marker file for RMM to detect restart requirement
            $RestartMarker = "$LogPath\RESTART_REQUIRED.txt"
            "Restart required after Office uninstall - $(Get-Date)" | Out-File -FilePath $RestartMarker
        }
        
        exit 0
    }
    else {
        Write-Log "========================================" -Level Info
        Write-Log "Office uninstall encountered errors. Check log for details." -Level Error
        exit 1
    }
}
catch {
    Write-Log "Critical error during uninstall: $_" -Level Error
    Write-Log "Stack Trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}
finally {
    Write-Log "Script execution completed at $(Get-Date)" -Level Info
    Write-Log "Log file saved to: $LogFile" -Level Info
    Write-Log "========================================" -Level Info
}
