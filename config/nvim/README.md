# Neovim Config

Personal Neovim setup built on lazy.nvim, with a Mason-first LSP workflow, Telescope-driven navigation, and practical defaults for daily coding.

For migration history and detailed technical rationale, see [migration-notes](migration-notes/).

## Highlights

- Lazy-loaded plugin architecture through lazy.nvim
- Mason-managed LSP installations
- Modern Neovim LSP setup using vim.lsp.config and vim.lsp.enable
- Completion stack with nvim-cmp and LuaSnip
- Telescope for fuzzy finding and grep workflows
- Neo-tree for project and buffer browsing
- Treesitter-based syntax and textobjects
- DAP support with nvim-dap and dap-ui

## Requirements

Required on both platforms unless noted.

**Linux**

- Neovim 0.11 or newer
- Git
- Ripgrep (`rg`)
- A C compiler (gcc or clang) — for Treesitter parsers and native plugins
- Optional: fzf and make — for `telescope-fzf-native`

**Windows**

- Neovim 0.11 or newer (winget: `winget install Neovim.Neovim`)
- Git for Windows
- Ripgrep (`winget install BurntSushi.ripgrep.MSVC` or `scoop install ripgrep`)
- A C compiler — zig is the easiest choice (`winget install zig.zig`); MSVC works too
- PowerShell with `$env:XDG_CONFIG_HOME = "$HOME/.config"` in your profile (see [Installation](#installation))
- Optional: fzf (`winget install junegunn.fzf` or `scoop install fzf`)

## Installation

This config is part of a dotfiles repository managed as a bare git repo. Each platform has a one-liner bootstrap that clones it and sets up the `dotfiles` alias.

**Linux**

```sh
curl https://gist.githubusercontent.com/PhoenixWyllow/3ca15ab36343cdb7647633b9538bfdb0/raw/linux-apply-dotfiles.sh | /bin/bash
```

**Windows** (PowerShell)

```powershell
Invoke-WebRequest https://gist.githubusercontent.com/PhoenixWyllow/f9f3950ec3bb4ef11e229d6761c77c5e/raw/win-apply-dotfiles.ps1 | Invoke-Expression
```

Both scripts place the Neovim config at `~/.config/nvim/`. On Windows this works because the PowerShell profile sets `$env:XDG_CONFIG_HOME = "$HOME/.config"`, which Neovim respects.

After the dotfiles bootstrap, first-run Neovim setup:

1. Start Neovim
2. Run `:Lazy sync` to install plugins
3. Restart Neovim

On first use, Mason will install LSP servers and Treesitter will compile parsers. Both may take a few minutes.

## Project Layout

- [init.lua](init.lua): entrypoint and lazy bootstrap
- [lua/core](lua/core): base options, keymaps, utilities, autocmds
- [lua/plugins](lua/plugins): plugin specs and configuration
- [lazy-lock.json](lazy-lock.json): pinned plugin commits

## Core Workflows

### Plugin Management

- Update plugins: :Lazy sync
- Inspect plugin UI: :Lazy

### LSP and Mason

- Open Mason UI: :Mason
- Install LSP server: :LspInstall <server>
- Uninstall LSP server: :LspUninstall <server>
- LSP status: :LspInfo
- LSP health: :checkhealth vim.lsp

Primary LSP configuration lives in [lua/plugins/lsp-config.lua](lua/plugins/lsp-config.lua).

### Search and Navigation

- Find files: <leader>sf
- Live grep: <leader>sg
- Search open files: <leader>s/
- Git files: <leader>gf
- Git root grep: <leader>gg
- Buffers: <leader><space>
- Recent files: <leader>_

Telescope config is in [lua/plugins/telescope.lua](lua/plugins/telescope.lua).

### File Tree and Buffers

- Toggle/focus explorer: <leader>e
- Show open buffers in Neo-tree: <leader>b

Neo-tree config is in [lua/plugins/neo-tree.lua](lua/plugins/neo-tree.lua).

### Diagnostics and LSP Actions

- Prev diagnostic: [d
- Next diagnostic: ]d
- Diagnostic float: <leader>Q
- Diagnostics list: <leader>q
- Rename: <leader>rn
- Code action: <leader>ca
- Go to definition: <leader>gd
- References: <leader>gr

### Debugging

- Continue: F5
- Step over: F10
- Step into: F11
- Step out: Shift+F11
- Terminate: Shift+F5
- Toggle breakpoint: F9

DAP config is in [lua/plugins/debug.lua](lua/plugins/debug.lua).

## How To Add a New LSP Server

1. Open [lua/plugins/lsp-config.lua](lua/plugins/lsp-config.lua)
2. Add the server under the servers table
3. Add optional settings, filetypes, or cmd overrides if needed
4. Run :Lazy sync
5. Restart Neovim and verify with :LspInfo

## Update and Validation Routine

1. Run :Lazy sync
2. Run :Mason and update/install missing tools if needed
3. Run :checkhealth vim.lsp
4. Run :checkhealth mason
5. Open representative files and confirm:
   - LSP attaches
   - completion works
   - diagnostics appear
   - Treesitter highlighting works

## Notes

- Telescope is configured to track stable releases.
- Treesitter is intentionally pinned to the compatibility branch in [lua/plugins/treesitter.lua](lua/plugins/treesitter.lua) to avoid accidental migration to incompatible rewrite behavior without a deliberate Neovim 0.12 plan.
- Full migration record is kept in [migration-notes/](migration-notes/).
