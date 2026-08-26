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

    return $global:Projects[$ProjectName].Path
}

function Get-ProjectNodeVersion {
    param([Parameter(Mandatory)][string]$ProjectName)

    $project = $global:Projects[$ProjectName]
    if ($project.NodeVersion) {
        return $project.NodeVersion
    }

    return $null
}

function Get-ProjectRunCommands {
    param([Parameter(Mandatory)][string]$ProjectName)

    $commands = $global:Projects[$ProjectName].RunCommands
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

    return $global:Projects.ContainsKey($ProjectAlias) -and
        $null -ne $global:Projects[$ProjectAlias].Path
}
