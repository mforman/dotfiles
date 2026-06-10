# dotfiles

The files that turn a fresh Mac into a terminal I actually want to look at. Managed with [chezmoi](https://www.chezmoi.io/).

Primary target is macOS. Linux and WSL work for the shells, git, tmux, and Neovim bits. Windows gets the door politely closed on most configs.

## 🗺 The tour

| Area            | Tool                                                                                                |
| --------------- | --------------------------------------------------------------------------------------------------- |
| Shell           | zsh (vi-mode, autosuggestions, fzf, zoxide); bash on Linux only                                    |
| Prompt          | [starship](https://starship.rs/)                                                                    |
| Terminal        | [wezterm](https://wezfurlong.org/wezterm/); status bar via tmux                                     |
| Multiplexer     | tmux — prefix `C-a`, vi mode, tpm, session persistence                                              |
| Editor          | Neovim — single-file `init.lua`, native `vim.pack`, built-in LSP/completion (needs Neovim 0.12+)    |
| VCS             | git with SSH signing and a work/personal email split via `includeIf`                                |
| Runtimes        | [mise](https://mise.jdx.dev/) — manages Node and Python (replaces nvm + pyenv)                     |
| Packages        | Homebrew on macOS, apt on Linux                                                                     |
| Keyboard (mac)  | karabiner-elements                                                                                  |
| Odds and ends   | direnv, fzf, zoxide, libpq, lazygit, lazydocker                                                     |

Everything wears Catppuccin Macchiato.

## 🪟 WSL bootstrap

### Part A — Windows, before installing WSL

1. Install [1Password for Windows](https://1password.com/downloads/windows/) and sign in.
2. Install [1Password CLI for Windows](https://developer.1password.com/docs/cli/get-started/#install-1password-cli). This puts `op.exe` on the Windows PATH, which WSL inherits via interop — it's what chezmoi uses to fetch the age key.
3. Sign in to the CLI (run in PowerShell):
   ```powershell
   op account add
   op signin
   ```
   Keep 1Password desktop open and unlocked during the chezmoi apply.

Now install WSL (`wsl --install` in PowerShell, then reboot), open an Ubuntu terminal, and continue:

---

### Part B — WSL, before chezmoi

```sh
# 1. Base deps
sudo apt update && sudo apt install -y git curl

# 2. Prevent Git from converting LF → CRLF on checkout
git config --global core.autocrlf false

# 3. SSH key for GitHub — retrieve from 1Password and place in ~/.ssh/
mkdir -p ~/.ssh && chmod 700 ~/.ssh
# write private key to ~/.ssh/<keyname>, then:
chmod 600 ~/.ssh/<keyname>
ssh -T git@github.com       # verify

# 4. Install chezmoi and bootstrap
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply mforman
```

chezmoi will prompt for `name`, `email`, `isPersonal`, `workEmail`, `workDir`, and `sshSignKey` on first run.

### Wiping and starting over

```sh
# Nuke the WSL distro entirely (run in PowerShell — fastest clean slate)
wsl --unregister Ubuntu

# Fix CRLF without wiping — if the source was cloned before .gitattributes was added
cd ~/.local/share/chezmoi
git pull
git rm --cached -r .
git reset --hard
chezmoi apply

# Reset chezmoi run-script state (forces run_once/run_onchange scripts to re-run)
chezmoi state delete-bucket --bucket=scriptState
rm -f ~/.config/chezmoi/key.txt   # also re-fetches age key on next apply
```

---

## 🧰 Bootstrap a new machine

```sh
# 1. Grab chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# 2. Init from this repo — it'll prompt for name, email, and whether
#    this is a work machine. Answer and put the kettle on.
chezmoi init --apply mforman
```

First apply is the slow one. It also runs:

- `run_onchange_brewfile-install.sh.tmpl` — `brew bundle` against `Brewfile.tmpl` (macOS)
- `run_onchange_install-packages.sh` — apt install + mise install (Linux)
- `run_onchange_install-work-gitconfig.sh.tmpl` — writes `~/<workDir>/.gitconfig` on work machines

After apply, run `mise install` to pull down the pinned Node and Python versions.

## 🔁 Day to day

```sh
chezmoi apply         # Apply pending changes to $HOME
chezmoi diff          # Dry run — show what apply would do
chezmoi edit <file>   # Edit the managed source (not the live copy)
chezmoi re-add        # Pull the current $HOME state back into the repo
chezmoi edit-config   # Change the prompt answers in ~/.config/chezmoi/chezmoi.toml

# Shell helper from dot_commonprofile.tmpl:
dotcheck              # chezmoi diff + list unmanaged ~/.config dirs
```

Rule of thumb: if you tweaked something live and want to keep it, `chezmoi re-add` it. Otherwise `chezmoi apply` on the next machine will quietly un-tweak it.

## 💬 The prompts

`chezmoi init` asks, once, and stashes answers in `~/.config/chezmoi/chezmoi.toml`:

| Variable     | What it's for                                                |
| ------------ | ------------------------------------------------------------ |
| `name`       | Full name — git author, etc.                                 |
| `email`      | Personal email — default git identity                        |
| `isPersonal` | Is this a personal (non-work) machine?                       |
| `workEmail`  | Work email — only asked when `isPersonal` is false           |
| `workDir`    | Path under `$HOME` where work repos live (e.g. `work`)       |
| `sshSignKey` | SSH key filename in `~/.ssh/` used for signing and auth      |

Templates reach them with `{{ .name }}`, `{{ .email }}`, and friends. Shared partials live in `.chezmoitemplates/`.

## 🏠 For the home and the office

A quiet source of embarrassment is pushing a commit with the wrong email attached. This repo avoids that:

- Personal and open-source repos go under `~/src/`. The main `~/.config/git/config` uses the personal email.
- Work repos go under `~/<workDir>/`. The git config has an `includeIf "gitdir:~/<workDir>/"` that pulls in `~/<workDir>/.gitconfig`, which overrides `user.email` with the work one.
- That per-workdir gitconfig is generated by `run_onchange_install-work-gitconfig.sh.tmpl`, so it stays in sync when `workEmail` changes. Personal machines skip it entirely.

## 📁 Chezmoi source conventions

| Prefix / suffix   | Meaning                                                     |
| ----------------- | ----------------------------------------------------------- |
| `dot_foo`         | → `~/.foo`                                                  |
| `private_foo`     | → `~/foo` with mode `0600`                                  |
| `exact_foo/`      | contents managed exactly — extras in the destination go     |
| `empty_foo`       | creates `~/foo` if missing; won't clobber                   |
| `foo.tmpl`        | Go-template, rendered with chezmoi data                     |
| `run_onchange_*`  | script re-run whenever its rendered content changes         |

OS gating lives in `.chezmoiignore`.

## 🌳 Layout

```
├── Brewfile.tmpl                          Homebrew bundle (macOS)
├── CLAUDE.md                              Notes for Claude Code sessions
├── README.md                              You are here
├── dot_zshenv                             sets XDG_* vars and ZDOTDIR for all zsh invocations
├── dot_commonprofile.tmpl                 shared aliases + env for zsh and bash
├── private_dot_config/
│   ├── zsh/                               zsh config (ZDOTDIR = ~/.config/zsh)
│   │   ├── dot_zshrc.tmpl
│   │   └── dot_zsh_aliases
│   ├── git/                               git config (XDG location)
│   │   ├── config.tmpl
│   │   └── ignore
│   ├── mise/                              runtime version pins (node, python)
│   │   └── config.toml
│   ├── nvim/                              Neovim (has its own CLAUDE.md)
│   ├── tmux/
│   ├── wezterm/
│   ├── docker/                            DOCKER_CONFIG points here
│   ├── psql/                              PSQLRC points here
│   ├── readline/                          INPUTRC points here
│   ├── direnv/
│   ├── private_karabiner/                 karabiner-elements (macOS)
│   └── starship.toml
├── private_Library/                       macOS-only app support files
├── .chezmoitemplates/                     shared template partials
├── .chezmoi.toml.tmpl                     init prompts
├── .chezmoiignore                         OS gating
├── .chezmoiremove                         paths to remove from $HOME after migration
├── run_onchange_brewfile-install.sh.tmpl
├── run_onchange_install-packages.sh
└── run_onchange_install-work-gitconfig.sh.tmpl
```

For the deeper cuts, see `CLAUDE.md` and `private_dot_config/nvim/CLAUDE.md`.
