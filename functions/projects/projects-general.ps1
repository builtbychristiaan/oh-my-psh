# if (-not (Get-Variable -Name Projects -Scope Script -ErrorAction SilentlyContinue)) {
#     $script:Projects = @{}
# }

function Expand-ProjectPath {
    param([string]$Path)

    if ($Path -match '^~[\\/]?') {
        return Join-Path $HOME $Path.Substring($Path.IndexOf('~') + 1).TrimStart('\', '/')
    }

    return $Path
}

function Get-ProjectPath {
    param([Parameter(Mandatory)][string]$ProjectName)

    return $script:Projects[$ProjectName].Path
}

function Get-ProjectNodeVersion {
    param([Parameter(Mandatory)][string]$ProjectName)

    $project = $script:Projects[$ProjectName]
    if ($project.NodeVersion) {
        return $project.NodeVersion
    }

    return $null
}

function Get-ProjectRunCommands {
    param([Parameter(Mandatory)][string]$ProjectName)

    $commands = $script:Projects[$ProjectName].RunCommands
    if ($null -eq $commands) {
        return @()
    }

    if ($commands -is [string]) {
        return @($commands)
    }

    return @($commands)
}

function Test-ProjectAlias {
    param([Parameter(Mandatory)][string]$ProjectAlias)

    return $script:Projects.ContainsKey($ProjectAlias) -and
        $null -ne $script:Projects[$ProjectAlias].Path
}
