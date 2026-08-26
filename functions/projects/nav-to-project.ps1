# Navigate to a project in terminal
function nav {
    param(
        [Parameter(Mandatory)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $global:Projects.Keys | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
        })]
        [string]$ProjectName
    )

    $projectPath = Get-ProjectPath $ProjectName
    if (-not (Test-Path $projectPath)) {
        Write-Error "Project not found: $ProjectName"
        return
    }

    cd $projectPath
}
function Set-AppTheme {
    param (
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # 1. Define your static list of options
            $themeList = @('Cyberpunk', 'Classic-Dark', 'Classic-Light', 'Matrix-Green', 'Ocean-Blue')
            
            # 2. Filter the array based on what the user has typed so far
            $themeList | Where-Object { $_ -like "$wordToComplete*" }
        })]
        [string]$Theme
    )
    Write-Host "Setting theme to: $Theme"
}
