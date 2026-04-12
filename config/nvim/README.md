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
- PowerShell with `$env:XDG_CONFIG_HOME = "$HOME/.config"` in your profile
- Optional: fzf (`winget install junegunn.fzf` or `scoop install fzf`)

## First Run

Installation and deployment are documented in the repository root README.
After applying dotfiles, first-run Neovim setup:

1. Start Neovim
2. Run `:Lazy sync` to install plugins
3. Restart Neovim

On first use, Mason will install LSP servers and Treesitter will compile parsers. Both may take a few minutes.

## Test From Repo (Dev Mode)

Run directly from the repository with isolated state (no copy or symlink). After applying dotfiles, use the `nvim-dev` command from the repo root:

**Bash**

```bash
cd ~/.dotfiles
nvim-dev
```

**Zsh**

```bash
cd ~/.dotfiles
nvim-dev
```

**PowerShell**

```powershell
cd $env:USERPROFILE\.dotfiles
$env:XDG_CONFIG_HOME = "$PWD/config"
$env:XDG_DATA_HOME = "$PWD/.devstate/data"
$env:XDG_STATE_HOME = "$PWD/.devstate/state"
$env:XDG_CACHE_HOME = "$PWD/.devstate/cache"
try { nvim }
finally {
  'XDG_CONFIG_HOME','XDG_DATA_HOME','XDG_STATE_HOME','XDG_CACHE_HOME' | ForEach-Object { Remove-Item "Env:$_" -ErrorAction SilentlyContinue }
}
```

To pass arguments (e.g., `--clean` for fresh state):

```bash
nvim-dev --clean
```

Isolated state directory `.devstate/` is gitignored and can be safely deleted to reset dev state.

## Project Layout

- [init.lua](init.lua): entrypoint and lazy bootstrap
- [lua/core](lua/core): base options, keymaps, utilities, autocmds
- [lua/plugins](lua/plugins): plugin specs and configuration

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
