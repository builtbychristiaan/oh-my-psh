# Navigate to a project in terminal
function nav {
    param(
        [Parameter(Mandatory)]
        [string]$ProjectName
    )

    $projectPath = Get-ProjectPath $ProjectName
    if (-not (Test-Path $projectPath)) {
        Write-Error "Project not found: $ProjectName"
        return
    }

    cd $projectPath
}