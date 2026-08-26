function go {
    param(
        [Parameter(Mandatory, ValueFromRemainingArguments)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            $global:Projects.Keys | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object
        })]
        [string[]]$ProjectAliases
    )

    foreach ($projectAlias in $ProjectAliases) {
        if (-not (Test-ProjectAlias $projectAlias)) {
            Write-Host "Error: Invalid project alias '$projectAlias'" -ForegroundColor Red
            return
        }
    }

    foreach ($projectAlias in $ProjectAliases) {
        $projectPath = Expand-ProjectPath (Get-ProjectPath $projectAlias)
        code $projectPath
        Write-Host "Opened $projectAlias" -ForegroundColor Blue
    }
}
