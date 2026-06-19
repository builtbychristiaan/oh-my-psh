function run {
    param(
        [Parameter(Mandatory)]
        [string]$ProjectName
    )

    if (-not (Test-ProjectAlias $ProjectName)) {
        Write-Host "Error: Invalid project alias '$ProjectName'" -ForegroundColor Red
        return
    }

    $projectPath = Expand-ProjectPath (Get-ProjectPath $ProjectName)
    if (-not (Test-Path $projectPath)) {
        Write-Error "Project path not found: $projectPath"
        return
    }

    $runCommands = Get-ProjectRunCommands $ProjectName
    if ($runCommands.Count -eq 0) {
        Write-Host "Error: No run commands configured for '$ProjectName'" -ForegroundColor Red
        return
    }

    Set-Location $projectPath

    foreach ($command in $runCommands) {
        Write-Host "Executing: $command" -ForegroundColor Magenta
        Invoke-Expression $command
        if ($LASTEXITCODE -ne 0) { return $LASTEXITCODE }
    }
}
