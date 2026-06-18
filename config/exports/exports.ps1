# Environment variables and PATH additions.
# Add machine-specific overrides in private-exports.ps1 (gitignored).

if (Test-Path "$HOME\dotfiles\oh-my-psh\config\exports\private-exports.ps1") {
    . "$HOME\dotfiles\oh-my-psh\config\exports\private-exports.ps1"
}
