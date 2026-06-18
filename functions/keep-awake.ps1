Function keep-awake {
    Clear-Host
    Write-Host "System is now being kept awake. Press Ctrl+C to stop." -ForegroundColor Green

    # Create a Windows Shell object to simulate keystrokes
    $WShell = New-Object -ComObject "Wscript.Shell"

    # Infinite loop
    while ($true) {
        # Send the F15 keystroke
        $WShell.SendKeys("{F15}")
        
        # Wait for 30 seconds before pressing it again
        Start-Sleep -Seconds 30
    }
}