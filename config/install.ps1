# Oh-My-PSH installation script
# Wires your PowerShell profile to source this modular configuration.

$ErrorActionPreference = 'Stop'

$OhMyPshRoot = "$HOME\dotfiles\oh-my-psh"

function Write-Status  { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Blue }
function Write-Success { param($Message) Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Warn    { param($Message) Write-Host "[WARNING] $Message" -ForegroundColor Yellow }

Write-Host "Starting Oh-My-PSH installation..." -ForegroundColor Cyan

if (-not (Test-Path $OhMyPshRoot)) {
    throw "Oh-My-PSH root not found at $OhMyPshRoot"
}

$profileContent = @"
# Oh-My-PSH - modular PowerShell configuration
`$OhMyPshRoot = "`$HOME\dotfiles\oh-my-psh"

. "`$OhMyPshRoot\config\config.ps1"

Get-ChildItem -Path `$OhMyPshRoot -Recurse -Filter *.ps1 |
    Where-Object { `$_.FullName -notmatch '\\config\\' } |
    ForEach-Object { . `$_.FullName }
"@

$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    Write-Status "Creating profile directory: $profileDir"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

if ((Test-Path $PROFILE) -and (Select-String -Path $PROFILE -Pattern 'oh-my-psh' -Quiet)) {
    Write-Warn "Oh-My-PSH configuration already present in profile"
}
elseif (Test-Path $PROFILE) {
    $backup = "$PROFILE.backup"
    Write-Warn "Backing up existing profile to $backup"
    Copy-Item -Path $PROFILE -Destination $backup -Force
    Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8
    Write-Success "Updated profile at $PROFILE"
}
else {
    Set-Content -Path $PROFILE -Value $profileContent -Encoding UTF8
    Write-Success "Created profile at $PROFILE"
}

$projectsConfigDir = "$OhMyPshRoot\functions\projects"
$projectsConfigFile = "$projectsConfigDir\projects.config.ps1"

if (-not (Test-Path $projectsConfigDir)) {
    New-Item -ItemType Directory -Path $projectsConfigDir -Force | Out-Null
}

if (Test-Path $projectsConfigFile) {
    Write-Warn "projects.config.ps1 already exists"
}
else {
    Set-Content -Path $projectsConfigFile -Value @'
# Machine-specific project definitions (gitignored).
# Example:
# $script:Projects = @{
#     myapp = @{
#         Path = "C:\projects\myapp"
#         RunCommands = @("npm start")
#     }
# }
'@ -Encoding UTF8
    Write-Success "Created projects.config.ps1"
}

Write-Success "Oh-My-PSH installation completed!"
Write-Status "Next steps:"
Write-Host "  1. Restart your shell or run: . `$PROFILE"
Write-Host "  2. Add project configs to: $projectsConfigFile"
