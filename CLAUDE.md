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
- `empty_*` → creates an empty file (ensures directory structure)

### Templating
`.chezmoi.toml.tmpl` prompts for data variables on first run: `name`, `email`, `isPersonal`, `workEmail`, `workDir`, `sshSignKey`. These are available as `{{ .name }}`, `{{ .sshSignKey }}` etc. in all `.tmpl` files. Shared templates live in `.chezmoitemplates/`.

### XDG Base Directory
All configs follow the XDG Base Directory spec. `~/.zshenv` sets the XDG vars (`XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`) and `ZDOTDIR` for every zsh invocation, then sources `~/.shellenv` for everything else (PATH + XDG redirects like `AZURE_CONFIG_DIR`, `DOCKER_CONFIG`, `CARGO_HOME`, etc.). `~/.shellenv` is exports-only and safe in non-interactive contexts; bash on Linux sources it from `~/.bashrc` and `~/.bash_profile`. Use bare `$XDG_CONFIG_HOME` etc. — never the `${XDG_CONFIG_HOME:-$HOME/.config}` fallback pattern inline.

### OS-Specific Handling
`.chezmoiignore` gates by OS:
- macOS only: `Brewfile`, `run_onchange_brewfile-install.sh.tmpl`, `private_dot_config/karabiner/`
- Linux only: `run_onchange_install-packages.sh`, `.bash_profile`, `.bashrc`
- Windows: excluded from shells, neovim, tmux, most terminal configs

### Key Managed Configurations

| Source path | Destination | Notes |
|---|---|---|
| `dot_zshenv` | `~/.zshenv` | Sets XDG vars and `ZDOTDIR`, then sources `~/.shellenv`; read by every zsh invocation |
| `dot_shellenv.tmpl` | `~/.shellenv` | Exports-only env file (PATH + XDG redirects: `AZURE_CONFIG_DIR`, `DOCKER_CONFIG`, `CARGO_HOME`, `NPM_CONFIG_CACHE`, etc.). Safe in non-interactive shells. Sourced by `~/.zshenv` (zsh) and `~/.bashrc`/`~/.bash_profile` (bash on Linux) |
| `private_dot_config/zsh/dot_zshrc.tmpl` | `~/.config/zsh/.zshrc` | Primary shell; vi-mode, fzf, zoxide, mise activation; inline functions (`cls`, `dotcheck`, `cm_add_vim`, `cm_add_nvim`) |
| `private_dot_config/zsh/dot_zsh_aliases` | `~/.config/zsh/.zsh_aliases` | Global aliases (`alias -g`) — intentional; keeps history portable |
| `private_dot_config/git/config.tmpl` | `~/.config/git/config` | SSH signing, conditional include for work dir, difftastic difftool |
| `private_dot_config/git/ignore` | `~/.config/git/ignore` | Global gitignore |
| `private_dot_config/mise/config.toml` | `~/.config/mise/config.toml` | Global runtime pins (node, python) |
| `private_dot_config/nvim/` | `~/.config/nvim/` | Modular `init.lua` → `lua/core/` (options, keymaps, autocmds) + `lua/packages/` (one file per feature), native `vim.pack` (Neovim 0.12+), built-in LSP/completion. Has its own `CLAUDE.md`. |
| `private_dot_config/tmux/` | `~/.config/tmux/` | Prefix=Ctrl-A, vi-mode, Catppuccin, tpm plugins |
| `private_dot_config/wezterm/` | `~/.config/wezterm/` | Wezterm terminal emulator; minimal config, one keybind (Shift+Enter); status bar is tmux |
| `private_dot_config/docker/` | `~/.config/docker/` | Docker config; `DOCKER_CONFIG` points here |
| `private_dot_config/psql/psqlrc` | `~/.config/psql/psqlrc` | PostgreSQL prompt; `PSQLRC` points here |
| `private_dot_config/readline/inputrc` | `~/.config/readline/inputrc` | Readline vi-mode; `INPUTRC` points here |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt |
| `Brewfile.tmpl` | `~/Brewfile` | Homebrew packages; applied by `run_onchange_brewfile-install.sh.tmpl` |

### Git Config Conditionals (`private_dot_config/git/config.tmpl`)
- `includeIf "gitdir:~/<workDir>/"` pulls in `~/<workDir>/.gitconfig` for work repos, overriding `user.email` with `workEmail`.
- Personal machines skip the work gitconfig entirely.
