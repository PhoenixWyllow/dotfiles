# Dotfiles

This repository uses a normal non-bare git layout plus repo-owned scripts for deployment and capture.

## Layout

```text
.
├── home/                    # maps to ~/.
├── config/                  # maps to ~/.config/
├── scripts/
├── manifest.yaml
```

## Installation

```sh
git clone https://github.com/PhoenixWyllow/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Then run the appropriate apply script for your platform:
- Linux and WSL: 
  ```sh
  bash scripts/apply.sh
  ```
- Windows-native PowerShell 7:
  ```powershell
  ./scripts/apply.ps1
  ```

Optional convenience aliases (run once per clone or machine):

- Linux and WSL:
  ```sh
  bash scripts/bootstrap-git-aliases.sh
  ```
- Windows-native PowerShell 7:
  ```powershell
  ./scripts/bootstrap-git-aliases.ps1
  ```

This adds `git df-*` aliases for the daily commands below.

After bootstrap, aliases can be refreshed anytime with `git df-bootstrap`.

## Daily commands

Without bootstrap aliases:

```sh
bash scripts/doctor.sh
bash scripts/apply.sh --dry-run
bash scripts/apply.sh
bash scripts/capture.sh
```

With bootstrap aliases:

```sh
git df-doctor
git df-apply --dry-run
git df-apply
git df-capture
```

These aliases intentionally use the `df-` prefix because `git apply` is already a built-in git command.

## Requirements

- Linux and WSL: `git`, `bash`, `rg`, `nvim`
- Windows-native: `git`, `pwsh`, `rg`, `nvim`
- recommended: `starship`, `lazygit`
- optional for Treesitter workflows:

```sh
npm install -g tree-sitter-cli
```

## Windows

Native Windows deployment is supported through the PowerShell scripts in `scripts/*.ps1`.

WSL is treated as Linux, so `linux:` manifest entries apply there. Native Windows uses the PowerShell scripts and the `windows:` manifest section.

The `.gitattributes` file in this repo enforces LF line endings so the bash scripts keep working on Linux and WSL even if the repo is also cloned from Windows.

For XDG-style portability, configure your PowerShell profile:

```powershell
$env:XDG_CONFIG_HOME = "$HOME/.config"
starship init powershell | Invoke-Expression
```
