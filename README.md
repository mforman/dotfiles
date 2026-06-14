# dotfiles

The files that turn a fresh machine into a terminal I actually want to look at. Managed with [chezmoi](https://www.chezmoi.io/).

macOS and Linux/WSL are both first-class targets — a single `chezmoi apply` bootstraps the full environment on either. Windows gets the door politely closed on most configs.

## 🗺 The tour

| Area            | Tool                                                                                                |
| --------------- | --------------------------------------------------------------------------------------------------- |
| Shell           | zsh (vi-mode, autosuggestions, fzf, zoxide); bash on Linux only                                    |
| Prompt          | [starship](https://starship.rs/)                                                                    |
| Terminal        | [wezterm](https://wezfurlong.org/wezterm/); status bar via tmux (macOS + Windows host for WSL)      |
| Multiplexer     | tmux — prefix `C-a`, vi mode, tpm, session persistence                                              |
| Editor          | Neovim — single-file `init.lua`, native `vim.pack`, built-in LSP/completion (needs Neovim 0.12+)    |
| VCS             | git with SSH signing and a work/personal email split via `includeIf`                                |
| Runtimes        | [mise](https://mise.jdx.dev/) — manages Node and Python (replaces nvm + pyenv)                     |
| Packages        | Homebrew on macOS †, apt on Linux                                                                   |
| Keyboard        | karabiner-elements †                                                                                |
| Odds and ends   | direnv, fzf, zoxide, ripgrep, libpq, lazygit, lazydocker, PowerShell (Linux)                       |

† macOS only

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

Install [WezTerm for Windows](https://wezfurlong.org/wezterm/installation.html) — it's the terminal used on this setup. Then install WSL (`wsl --install` in PowerShell, reboot), open WezTerm (it'll land in WSL), and continue:

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

# 4. Install chezmoi to ~/.local/bin (the dotfiles put it on PATH) and bootstrap
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply mforman
```

chezmoi will prompt for `name`, `email`, `isPersonal`, `workEmail`, `workDir`, and `sshSignKey` on first run.

The Linux package script bootstraps the full environment: zsh (set as login shell), starship, mise + pinned Node/Python runtimes, Neovim, lazygit, lazydocker, Docker Engine, postgresql-client, ripgrep, tmux plugins, and PowerShell. WSL additionally gets a `wslview` shim (opens URLs in the Windows browser) and wires up the Windows Git Credential Manager.

Open a fresh shell (`exec zsh`) after the first apply — `~/.zshenv` sources `~/.shellenv`, which puts `~/.local/bin` (and therefore `chezmoi`) on the PATH.

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
# 1. Grab chezmoi (installs to ~/.local/bin, which the dotfiles put on PATH)
#    and init from this repo — it'll prompt for name, email, and whether
#    this is a work machine. Answer and put the kettle on.
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" init --apply mforman
```

First apply is the slow one. It also runs:

- `run_onchange_brewfile-install.sh.tmpl` — `brew bundle` against `Brewfile.tmpl` (macOS)
- `run_onchange_install-packages.sh.tmpl` — apt install + mise install (Linux)
- `run_onchange_install-work-gitconfig.sh.tmpl` — writes `~/<workDir>/.gitconfig` on work machines

After apply, run `mise install` to pull down the pinned Node and Python versions.

## 🔁 Day to day

```sh
chezmoi apply         # Apply pending changes to $HOME
chezmoi diff          # Dry run — show what apply would do
chezmoi edit <file>   # Edit the managed source (not the live copy)
chezmoi re-add        # Pull the current $HOME state back into the repo
chezmoi edit-config   # Change the prompt answers in ~/.config/chezmoi/chezmoi.toml

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

Some variables are **computed** from machine state rather than prompted:

| Variable | How it's set                                                              |
| -------- | ------------------------------------------------------------------------- |
| `isWSL`  | `true` when the Linux kernel reports a Microsoft osrelease (WSL detection) |

Use `{{ if .isWSL }}` in templates instead of re-deriving inline.

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
├── dot_shellenv.tmpl                      exports-only env (PATH, XDG redirects) — safe in non-interactive shells
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
├── run_onchange_install-packages.sh.tmpl
└── run_onchange_install-work-gitconfig.sh.tmpl
```

For the deeper cuts, see `CLAUDE.md` and `private_dot_config/nvim/CLAUDE.md`.
