function Execute-Project {
    param(
        [Parameter(Mandatory)]
        [string]$ProjectAlias,
        [string]$Branch = ''
    )

    $projectPath = Expand-ProjectPath (Get-ProjectPath $ProjectAlias)
    $runCommands = Get-ProjectRunCommands $ProjectAlias
    $nodeVersion = Get-ProjectNodeVersion $ProjectAlias

    if ($nodeVersion) {
        Write-Host "Executing: nvm use $nodeVersion" -ForegroundColor Magenta
        nvm use $nodeVersion
        if ($LASTEXITCODE -ne 0) { return $LASTEXITCODE }
    }

    Set-Location $projectPath

    if ($Branch) {
        Write-Host "Executing: co $Branch" -ForegroundColor Magenta
        if (Get-Command co -ErrorAction SilentlyContinue) {
            co $Branch
        }
        else {
            git checkout $Branch
        }
        if ($LASTEXITCODE -ne 0) { return $LASTEXITCODE }
    }

    if ($ProjectAlias -eq 'coeditor') {
        Write-Host 'Executing: pnpm install' -ForegroundColor Magenta
        pnpm install
    }
    else {
        Write-Host 'Executing: yarn' -ForegroundColor Magenta
        yarn
    }
    if ($LASTEXITCODE -ne 0) { return $LASTEXITCODE }

    if ($runCommands.Count -gt 0) {
        $commandText = $runCommands -join '; '
        Write-Host "Executing: $commandText" -ForegroundColor Magenta
        foreach ($command in $runCommands) {
            Invoke-Expression $command
            if ($LASTEXITCODE -ne 0) { return $LASTEXITCODE }
        }
    }
}

function Watch-ProjectLogs {
    param(
        [Parameter(Mandatory)][string]$LogDir,
        [Parameter(Mandatory)][string[]]$ProjectAliases
    )

    Write-Host "`nAll projects started! Tailing logs...`n" -ForegroundColor Cyan

    $positions = @{}
    foreach ($projectAlias in $ProjectAliases) {
        $positions[$projectAlias] = 0
    }

    while ($true) {
        foreach ($projectAlias in $ProjectAliases) {
            $logFile = Join-Path $LogDir "$projectAlias.log"
            if (-not (Test-Path $logFile)) {
                continue
            }

            $content = [System.IO.File]::ReadAllText($logFile)
            if ($content.Length -le $positions[$projectAlias]) {
                continue
            }

            $newContent = $content.Substring($positions[$projectAlias]).TrimEnd()
            if ($newContent) {
                Write-Host "`n$projectAlias" -ForegroundColor Cyan
                Write-Host $newContent
            }

            $positions[$projectAlias] = $content.Length
        }

        Start-Sleep -Milliseconds 300
    }
}

function run {
    $branch = ''
    $projects = @()
    $pids = @()
    $logDir = Join-Path $env:TEMP 'dev-projects'
    $useSubshells = $false
    $i = 0

    function Invoke-RunCleanup {
        param(
            [string[]]$ProcessIds,
            [bool]$ShouldStopProcesses,
            [string]$ProjectsLogDir
        )

        if ($ShouldStopProcesses -and $ProcessIds.Count -gt 0) {
            Write-Host "`nStopping all projects..." -ForegroundColor Cyan
            foreach ($processId in $ProcessIds) {
                Stop-Process -Id $processId -Force -ErrorAction SilentlyContinue
            }
        }

        if (Test-Path $ProjectsLogDir) {
            Remove-Item -Path $ProjectsLogDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    while ($i -lt $args.Count) {
        switch ($args[$i]) {
            '-b' {
                if ($i + 1 -ge $args.Count) {
                    Write-Host 'Error: No branch name provided after -b flag' -ForegroundColor Red
                    return
                }

                $branch = $args[$i + 1]
                $i += 2
            }
            { $_ -in '-s', '--subshell' } {
                $useSubshells = $true
                $i += 1
            }
            default {
                $projects += $args[$i]
                $i += 1
            }
        }
    }

    if ($projects.Count -eq 0) {
        Write-Host 'Error: No project aliases provided' -ForegroundColor Red
        return
    }

    foreach ($projectAlias in $projects) {
        if (-not (Test-ProjectAlias $projectAlias)) {
            Write-Host "Error: Invalid project alias '$projectAlias'" -ForegroundColor Red
            return
        }
    }

    if ($branch) {
        Write-Host "Running $($projects.Count) project(s) on branch: $branch" -ForegroundColor Cyan
    }
    else {
        Write-Host "Running $($projects.Count) project(s)" -ForegroundColor Cyan
    }

    if (Test-Path $logDir) {
        Remove-Item -Path $logDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -Path $logDir -ItemType Directory -Force | Out-Null

    if ($projects.Count -eq 1) {
        Execute-Project -ProjectAlias $projects[0] -Branch $branch
        return
    }

    $shellExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { 'pwsh' } else { 'powershell' }

    if ($useSubshells) {
        $shouldStopProcesses = $true

        try {
            foreach ($projectAlias in $projects) {
                $logFile = Join-Path $logDir "$projectAlias.log"
                $tempScript = Join-Path $logDir "$projectAlias.ps1"

                @"
. `"`$PROFILE`"
Execute-Project -ProjectAlias '$projectAlias' -Branch '$branch' *>&1 | Tee-Object -FilePath '$logFile'
"@ | Set-Content -Path $tempScript -Encoding UTF8

                $process = Start-Process -FilePath $shellExe -ArgumentList @(
                    '-NoProfile',
                    '-ExecutionPolicy', 'Bypass',
                    '-File', $tempScript
                ) -PassThru -WindowStyle Hidden

                $pids += $process.Id
                Write-Host "Started $projectAlias in subshell (PID: $($process.Id))" -ForegroundColor Green
            }

            Watch-ProjectLogs -LogDir $logDir -ProjectAliases $projects
        }
        finally {
            Invoke-RunCleanup -ProcessIds $pids -ShouldStopProcesses $shouldStopProcesses -ProjectsLogDir $logDir
        }

        return
    }

    foreach ($projectAlias in $projects) {
        $projectPath = Expand-ProjectPath (Get-ProjectPath $projectAlias)
        $tempScript = Join-Path $logDir "$projectAlias.ps1"

        @"
Set-Location '$projectPath'
. `"`$PROFILE`"
Execute-Project -ProjectAlias '$projectAlias' -Branch '$branch'
"@ | Set-Content -Path $tempScript -Encoding UTF8

        if (Get-Command wt -ErrorAction SilentlyContinue) {
            Start-Process wt -ArgumentList @(
                '-w', '0', 'nt',
                '-d', $projectPath,
                $shellExe, '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $tempScript
            ) | Out-Null
        }
        else {
            Start-Process -FilePath $shellExe -ArgumentList @(
                '-NoExit', '-ExecutionPolicy', 'Bypass', '-File', $tempScript
            ) | Out-Null
        }

        Write-Host "Started $projectAlias in new window" -ForegroundColor Green
    }
}
