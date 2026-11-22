# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/). Targets macOS primarily, with partial Linux/WSL support. Windows is excluded from most configs via `.chezmoiignore`.

## Common Commands

```sh
chezmoi apply              # Apply changes to the home directory
chezmoi diff               # Preview what chezmoi apply would change
chezmoi add <file>         # Add/update a file in this repo from its live location
chezmoi edit <file>        # Edit a managed file (opens the source, not the destination)
chezmoi edit-config        # Edit ~/.config/chezmoi/chezmoi.toml
chezmoi re-add             # Re-add all managed files from their live state
chezmoi execute-template   # Test a template file
```

## Repository Architecture

### Chezmoi Naming Conventions
- `dot_*` → `.*` (e.g., `dot_zshenv` → `~/.zshenv`)
- `private_*` → file with mode 0600
- `exact_*` → directory contents are managed exactly (extra files removed on apply)
- `*.tmpl` → Go template processed by chezmoi
- `run_onchange_*` → script run when the file changes
- `run_once_before_*` → script run once per machine, before file targets are applied
- `encrypted_*` → file encrypted with age; decrypted on `chezmoi apply` using `~/.config/chezmoi/key.txt`
- `empty_*` → creates an empty file (ensures directory structure)

### Templating
`.chezmoi.toml.tmpl` defines data variables available in all `.tmpl` files:

**Prompted** (stored in `~/.config/chezmoi/chezmoi.toml` after `chezmoi init`): `name`, `email`, `isPersonal`, `workEmail`, `workDir`, `adminEmail`, `sshSignKey`.

**Computed** (derived from machine state, not prompted):
- `isWSL` — `true` when running under WSL (Linux kernel with "microsoft" in osrelease). Use `{{ if .isWSL }}` in templates; do **not** re-derive inline with the `and`/`contains`/`lower` expression — that pattern is what `isWSL` replaces. Note: Go templates do not short-circuit `and`, so `.chezmoi.kernel.osrelease` must only be accessed inside a `{{ if eq .chezmoi.os "linux" }}` guard (which is how `isWSL` is computed in `.chezmoi.toml.tmpl`).

Shared templates live in `.chezmoitemplates/`.

### XDG Base Directory
All configs follow the XDG Base Directory spec. `~/.zshenv` sets the XDG vars (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`) and `ZDOTDIR` for every zsh invocation, then sources `~/.shellenv` for everything else (PATH + XDG redirects like `AZURE_CONFIG_DIR`, `DOCKER_CONFIG`, `CARGO_HOME`, etc.). `~/.shellenv` is exports-only and safe in non-interactive contexts; bash on Linux sources it from `~/.bashrc` and `~/.bash_profile`. Use bare `$XDG_CONFIG_HOME` etc. — never the `${XDG_CONFIG_HOME:-$HOME/.config}` fallback pattern inline.

### Package Managers: mise vs brew
- **mise** (`private_dot_config/mise/config.toml.tmpl`): language runtimes and their package managers (node, python, pnpm), plus CLIs that are missing or lag in brew/apt (herdr, worktrunk). mise itself comes from the official installer, never brew.
- **brew** (`Brewfile.tmpl`): everything else on macOS — casks, fonts, and system/C-library tools. Avoid formulae that pull in brew's node/python; install npm/pip CLIs via mise (`npm:<pkg>`, `pipx:<pkg>`) instead.
- **Mason** (nvim): LSPs and formatters used only by nvim (e.g. stylua, prettierd) — don't duplicate them in the Brewfile.

### OS-Specific Handling
`.chezmoiignore` gates by OS:
- macOS only: `Brewfile`, `run_onchange_brewfile-install.sh.tmpl`, `private_dot_config/karabiner/`
- Linux only: `run_onchange_install-packages.sh.tmpl`, `.bash_profile`, `.bashrc`
- Windows: excluded from shells, neovim, most terminal configs

### Key Managed Configurations

| Source path | Destination | Notes |
|---|---|---|
| `dot_zshenv` | `~/.zshenv` | Sets XDG vars and `ZDOTDIR`, then sources `~/.shellenv`; read by every zsh invocation |
| `dot_shellenv.tmpl` | `~/.shellenv` | Exports-only env file (PATH + XDG redirects: `AZURE_CONFIG_DIR`, `DOCKER_CONFIG`, `CARGO_HOME`, `NPM_CONFIG_CACHE`, etc.). Safe in non-interactive shells. Sourced by `~/.zshenv` (zsh) and `~/.bashrc`/`~/.bash_profile` (bash on Linux). **No `tput`, subshells, or anything requiring a TTY** — those belong in `.zshrc`. |
| `private_dot_config/zsh/dot_zshrc.tmpl` | `~/.config/zsh/.zshrc` | Primary shell; vi-mode, fzf, zoxide, mise activation; inline functions (`cls`, `dotcheck`, `cm_add_vim`, `cm_add_nvim`) |
| `private_dot_config/zsh/dot_zsh_aliases` | `~/.config/zsh/.zsh_aliases` | Global aliases (`alias -g`) — intentional; keeps history portable |
| `private_dot_config/git/config.tmpl` | `~/.config/git/config` | SSH signing, conditional include for work dir, difftastic difftool |
| `private_dot_config/git/ignore` | `~/.config/git/ignore` | Global gitignore |
| `private_dot_config/mise/config.toml.tmpl` | `~/.config/mise/config.toml` | Global runtime pins (node, python) |
| `private_dot_config/nvim/` | `~/.config/nvim/` | Modular `init.lua` → `lua/core/` (options, keymaps, autocmds) + `lua/packages/` (one file per feature), native `vim.pack` (Neovim 0.12+), built-in LSP/completion. Has its own `CLAUDE.md`. |
| `private_dot_config/herdr/config.toml` | `~/.config/herdr/config.toml` | herdr multiplexer (installed via mise); rest of `~/.config/herdr/` is ignored |
| `private_dot_config/wezterm/` | `~/.config/wezterm/` | Wezterm terminal emulator; minimal config, one keybind (Shift+Enter) |
| `private_dot_config/docker/` | `~/.config/docker/` | Docker config; `DOCKER_CONFIG` points here |
| `private_dot_config/psql/psqlrc` | `~/.config/psql/psqlrc` | PostgreSQL prompt; `PSQLRC` points here |
| `private_dot_config/readline/inputrc` | `~/.config/readline/inputrc` | Readline vi-mode; `INPUTRC` points here |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt |
| `Brewfile.tmpl` | `~/Brewfile` | Homebrew packages; applied by `run_onchange_brewfile-install.sh.tmpl` |
| `private_dot_config/zsh/encrypted_executable_expana-db.sh.age` | `~/.config/zsh/expana-db.sh` | Work-only Azure Postgres helper (source to define `expana-db`); age-encrypted, key in 1Password (`op://Expana/chezmoi-age`) |
| `run_once_before_decrypt-age-key.sh.tmpl` | _(script)_ | Fetches age key from 1Password on first apply; work machines only |

### Git Config Conditionals (`private_dot_config/git/config.tmpl`)
- `includeIf "gitdir:~/<workDir>/"` pulls in `~/<workDir>/.gitconfig` for work repos, overriding `user.email` with `workEmail`.
- Personal machines skip the work gitconfig entirely.
