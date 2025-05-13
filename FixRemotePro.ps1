# Script to download, extract, and replace Faronics Remote service files

# Define the download URL and file paths
$downloadUrl = "https://faronics.digitalpigeon.com/shr/p3bEcBDhEfChfQZ43S09tQ/tsEZwrEc2doM8GjNk4Spxw/file/2d628c10-3052-11f0-9340-028629d47f7b/download"
$serviceName = "FaronicsRemoteSvc"
$installDir = "C:\Program Files\Faronics\FaronicsRemote"
$svcExePath = Join-Path $installDir "FaronicsRemoteSvc.exe"
$helperExePath = Join-Path $installDir "FarRemoteHelper.exe"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Create a temporary directory
$tempDir = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "FaronicsUpdate_$timestamp")
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
$zipFile = Join-Path $tempDir "faronics_update.zip"

Write-Host "Temporary directory created at: $tempDir" -ForegroundColor Cyan

# Function to download the file
function Download-File {
    Write-Host "Downloading zip file from: $downloadUrl" -ForegroundColor Cyan
    try {
        # Use TLS 1.2 for secure downloads
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # Download the file
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
        
        if (Test-Path $zipFile) {
            Write-Host "Download completed successfully." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Download failed. Zip file not found." -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error downloading file: $_" -ForegroundColor Red
        return $false
    }
}

# Function to extract the zip file
function Extract-ZipFile {
    Write-Host "Extracting zip file to: $tempDir" -ForegroundColor Cyan
    try {
        # Extract the zip file
        Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
        
        # List extracted files
        $extractedFiles = Get-ChildItem -Path $tempDir -File | Where-Object { $_.Name -ne (Split-Path $zipFile -Leaf) }
        
        if ($extractedFiles.Count -eq 0) {
            Write-Host "Extraction completed but no files were found." -ForegroundColor Yellow
            return $false
        }
        
        Write-Host "Extracted files:" -ForegroundColor Green
        $extractedFiles | ForEach-Object { Write-Host "  - $($_.Name)" }
        
        return $true
    } catch {
        Write-Host "Error extracting zip file: $_" -ForegroundColor Red
        return $false
    }
}

# Function to stop the service
function Stop-FaronicsService {
    Write-Host "Stopping service: $serviceName" -ForegroundColor Cyan
    try {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        
        if ($null -eq $service) {
            Write-Host "Service $serviceName not found." -ForegroundColor Red
            return $false
        }
        
        # Check if the service is already stopped
        if ($service.Status -eq "Stopped") {
            Write-Host "Service is already stopped." -ForegroundColor Yellow
            return $true
        }
        
        # Try to stop gracefully first
        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
        
        # Wait a bit and check if it stopped
        Start-Sleep -Seconds 3
        $service.Refresh()
        
        # If still not stopped, try more aggressive methods
        if ($service.Status -ne "Stopped") {
            Write-Host "Service did not stop gracefully, using forceful method..." -ForegroundColor Yellow
            
            # Use sc.exe to force stop
            $scResult = cmd /c "sc stop $serviceName"
            Start-Sleep -Seconds 2
            
            # As a last resort, kill the process
            $processes = Get-WmiObject Win32_Service | Where-Object { $_.Name -eq $serviceName } | Select-Object -ExpandProperty ProcessId
            if ($processes) {
                foreach ($pid in $processes) {
                    if ($pid -gt 0) {
                        Write-Host "Forcefully terminating process ID: $pid" -ForegroundColor Yellow
                        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
                    }
                }
            }
            
            # Check one more time
            Start-Sleep -Seconds 2
            $service.Refresh()
        }
        
        if ($service.Status -eq "Stopped") {
            Write-Host "Service stopped successfully." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to stop service. Current status: $($service.Status)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error stopping service: $_" -ForegroundColor Red
        return $false
    }
}

# Function to replace the files
function Replace-Files {
    Write-Host "Replacing Faronics Remote service files..." -ForegroundColor Cyan
    try {
        # Check if original files exist
        $svcExists = Test-Path $svcExePath
        $helperExists = Test-Path $helperExePath
        
        if (-not $svcExists -and -not $helperExists) {
            Write-Host "Original files not found at expected locations." -ForegroundColor Red
            return $false
        }
        
        # Find the files in the extracted directory
        $extractedFiles = Get-ChildItem -Path $tempDir -File | Where-Object { $_.Name -ne (Split-Path $zipFile -Leaf) }
        $newSvcExe = $extractedFiles | Where-Object { $_.Name -eq "FaronicsRemoteSvc.exe" } | Select-Object -First 1
        $newHelperExe = $extractedFiles | Where-Object { $_.Name -eq "FarRemoteHelper.exe" } | Select-Object -First 1
        
        if (-not $newSvcExe -and -not $newHelperExe) {
            Write-Host "Required files not found in the extracted content." -ForegroundColor Red
            return $false
        }
        
        # Backup the original files
        if ($svcExists) {
            $backupSvcPath = "$svcExePath.backup_$timestamp"
            Write-Host "Renaming $svcExePath to $backupSvcPath" -ForegroundColor Cyan
            Rename-Item -Path $svcExePath -NewName $backupSvcPath -Force
        }
        
        if ($helperExists) {
            $backupHelperPath = "$helperExePath.backup_$timestamp"
            Write-Host "Renaming $helperExePath to $backupHelperPath" -ForegroundColor Cyan
            Rename-Item -Path $helperExePath -NewName $backupHelperPath -Force
        }
        
        # Copy the new files
        if ($newSvcExe) {
            Write-Host "Copying new FaronicsRemoteSvc.exe to $svcExePath" -ForegroundColor Cyan
            Copy-Item -Path $newSvcExe.FullName -Destination $svcExePath -Force
        }
        
        if ($newHelperExe) {
            Write-Host "Copying new FarRemoteHelper.exe to $helperExePath" -ForegroundColor Cyan
            Copy-Item -Path $newHelperExe.FullName -Destination $helperExePath -Force
        }
        
        # Verify the files were copied correctly
        $newSvcExists = Test-Path $svcExePath
        $newHelperExists = Test-Path $helperExePath
        
        if (($svcExists -and -not $newSvcExists) -or ($helperExists -and -not $newHelperExists)) {
            Write-Host "Failed to copy one or more files to their destinations." -ForegroundColor Red
            return $false
        }
        
        Write-Host "Files replaced successfully." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Error replacing files: $_" -ForegroundColor Red
        return $false
    }
}

# Function to start the service
function Start-FaronicsService {
    Write-Host "Starting service: $serviceName" -ForegroundColor Cyan
    try {
        Start-Service -Name $serviceName
        
        # Check if service started successfully
        $service = Get-Service -Name $serviceName
        if ($service.Status -eq "Running") {
            Write-Host "Service started successfully." -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to start service. Current status: $($service.Status)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "Error starting service: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution flow
Write-Host "=== Faronics Remote Service Update Script ===" -ForegroundColor Magenta

# Step 1: Download the zip file
$downloadSuccess = Download-File
if (-not $downloadSuccess) {
    Write-Host "Update process aborted due to download failure." -ForegroundColor Red
    exit 1
}

# Step 2: Extract the zip file
$extractSuccess = Extract-ZipFile
if (-not $extractSuccess) {
    Write-Host "Update process aborted due to extraction failure." -ForegroundColor Red
    exit 1
}

# Step 3: Stop the Faronics Remote service
$stopSuccess = Stop-FaronicsService
if (-not $stopSuccess) {
    Write-Host "Warning: Service could not be stopped properly. Continuing anyway..." -ForegroundColor Yellow
    # We continue anyway as we might still be able to replace the files
}

# Step 4: Replace the files
$replaceSuccess = Replace-Files
if (-not $replaceSuccess) {
    Write-Host "Update process aborted due to file replacement failure." -ForegroundColor Red
    exit 1
}

# Step 5: Start the service back
$startSuccess = Start-FaronicsService
if (-not $startSuccess) {
    Write-Host "Warning: Service could not be started. You may need to restart it manually or reboot the system." -ForegroundColor Yellow
}

# Final status message
if ($downloadSuccess -and $extractSuccess -and $replaceSuccess) {
    Write-Host "Update completed successfully!" -ForegroundColor Green
    
    if (-not $startSuccess) {
        Write-Host "Note: Service could not be started automatically. Please try starting it manually or reboot the system." -ForegroundColor Yellow
    }
} else {
    Write-Host "Update completed with errors. Please check the logs above." -ForegroundColor Red
}

Write-Host "Temporary directory with downloaded files: $tempDir" -ForegroundColor Cyan
Write-Host "You may delete this directory once you've confirmed everything is working properly." -ForegroundColor Cyan
