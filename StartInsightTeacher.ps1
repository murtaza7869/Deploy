# Stop all running instances of FITeacherConsole.exe
Write-Host "Searching for running instances of FITeacherConsole.exe..."
Get-Process -Name "FITeacherConsole" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Terminating process $($_.Id)..."
    Stop-Process -Id $_.Id -Force
}

# Wait for a moment to ensure all processes are terminated
Start-Sleep -Seconds 2

# Launch a new instance of FITeacherConsole.exe maximized and in focus
Write-Host "Launching new instance of FITeacherConsole.exe..."
Start-Process -FilePath "C:\Program Files\Faronics\Insight Teacher\FITeacherConsole.exe" -ArgumentList "/showUI" -WindowStyle Maximized

# Inform the user that the operation is complete
Write-Host "Operation completed successfully."
