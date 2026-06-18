# Oh-My-PSH

Modular PowerShell configuration for Windows — the PowerShell counterpart to [oh-my-czsh](https://github.com/Christiaan-code/oh-my-czsh).

## Installation

1. Clone this repository:

```powershell
git clone <your-repo-url> $HOME\dotfiles\oh-my-psh
```

2. Run the install script:

```powershell
powershell -ExecutionPolicy Bypass -File $HOME\dotfiles\oh-my-psh\config\install.ps1
```

3. Restart your shell or reload your profile:

```powershell
. $PROFILE
```

## Directory Structure

Everything in `config/` is loaded in explicit order via `config\config.ps1`.

All other `.ps1` files are auto-sourced on shell startup (excluding `config\`).

```
oh-my-psh/
  config/
    config.ps1          # Ordered config entry point
    install.ps1         # Installation script
    exports/
      exports.ps1       # Environment variables
  aliases/
  functions/
  lib/
```

## Usage

1. Add new `.ps1` files under `aliases/`, `functions/`, or `lib/`
2. Files are auto-loaded on shell startup
3. Reload with `. $PROFILE`

## Local Overrides

- `config/exports/private-exports.ps1` — machine-specific env vars (gitignored)
- `functions/projects/projects.config.ps1` — project definitions (gitignored)
