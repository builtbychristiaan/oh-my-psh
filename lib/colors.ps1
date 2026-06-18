# Console color helpers for scripts and functions.

function Write-Color {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $ForegroundColor
}
