function list-skipped() {
  git ls-files -v | Select-String -Pattern '^S' | ForEach-Object { $_.Line.Split(' ')[1] }
}

function skip() {
    param(
        [Parameter(Mandatory)]
        [string]$File
    )
    git update-index --skip-worktree $File
}

function unskip() {
    param(
        [Parameter(Mandatory)]
        [string]$File
    )
    git update-index --no-skip-worktree $File
}