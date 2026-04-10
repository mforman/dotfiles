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
- `dot_*` → `.*` (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_*` → file with mode 0600
- `exact_*` → directory contents are managed exactly (extra files removed on apply)
- `*.tmpl` → Jinja-like template processed by chezmoi
- `run_onchange_*` → script run when the file changes
- `empty_*` → creates an empty file (ensures directory structure)

### Templating
`.chezmoi.toml.tmpl` prompts for four data variables on first run: `name`, `email`, `workEmail`, `workDir`. These are available as `{{ .chezmoi.data.name }}` etc. in all `.tmpl` files. Shared templates live in `.chezmoitemplates/`.

### OS-Specific Handling
`.chezmoiignore` gates by OS:
- macOS only: `Brewfile`, `run_onchange_brewfile-install.sh.tmpl`, `private_dot_config/karabiner/`
- Linux only: `run_onchange_install-packages.sh`
- Windows: excluded from shells, neovim, tmux, most terminal configs

### Key Managed Configurations

| Source path | Destination | Notes |
|---|---|---|
| `dot_zshrc` | `~/.zshrc` | Primary shell; vi-mode, fzf, zoxide, nvm lazy-load |
| `dot_commonprofile.tmpl` | `~/.commonprofile` | Shared aliases/env sourced by zsh and bash; PATH setup for Go, .NET, pyenv, pipx, libpq |
| `dot_gitconfig.tmpl` | `~/.gitconfig` | GPG signing via SSH, conditional include for work dir, difftastic difftool |
| `private_dot_config/nvim/` | `~/.config/nvim/` | Single-file `init.lua`, native `vim.pack` (Neovim 0.12+), built-in LSP/completion. Has its own `CLAUDE.md`. |
| `private_dot_config/tmux/` | `~/.config/tmux/` | Prefix=Ctrl-A, vi-mode, Catppuccin, tpm plugins |
| `private_dot_config/kitty/` | `~/.config/kitty/` | Catppuccin theme |
| `private_dot_config/ghostty/` | `~/.config/ghostty/` | Ghostty terminal |
| `private_dot_config/wezterm/` + `dot_wezterm.lua.tmpl` | `~/.config/wezterm/`, `~/.wezterm.lua` | Wezterm with custom bar and keybinds |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt |
| `Brewfile` | `~/Brewfile` | Homebrew packages; applied by `run_onchange_brewfile-install.sh.tmpl` |
| `dot_psqlrc` | `~/.psqlrc` | PostgreSQL prompt |

### Git Config Conditionals (`dot_gitconfig.tmpl`)
- Includes `~/.gitconfig.local` for machine-local overrides.
- Includes `~/.gitconfig` (work config) when inside the `workDir` path — allows different email/signing for work repos.
