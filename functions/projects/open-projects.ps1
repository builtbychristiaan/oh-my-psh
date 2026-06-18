function go {
    if ($args.Count -eq 0) {
        Write-Host 'Error: Please provide at least one project name' -ForegroundColor Red
        return
    }

    foreach ($projectAlias in $args) {
        if (-not (Test-ProjectAlias $projectAlias)) {
            Write-Host "Error: Invalid project alias '$projectAlias'" -ForegroundColor Red
            return
        }
    }

    foreach ($projectAlias in $args) {
        $projectPath = Expand-ProjectPath (Get-ProjectPath $projectAlias)
        cursor $projectPath
        Write-Host "Opened $projectAlias" -ForegroundColor Blue
    }
}
