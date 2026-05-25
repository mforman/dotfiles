# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A modular Neovim configuration using the native `vim.pack` plugin manager (not lazy.nvim). Targets Neovim 0.12+ (uses `vim.pack.add`, `vim.lsp.config`, `vim.lsp.enable`, and built-in completion via `vim.lsp.completion.enable`).

## Architecture

- **`init.lua`** — Minimal entry point: `require 'core'` then `require 'packages'`.
- **`lua/core/`** — Editor settings with no plugin dependencies.
  - `init.lua` — requires the four submodules below.
  - `options.lua` — leader key, `vim.g`/`vim.opt` settings, env vars (PSQLRC, python3_host_prog).
  - `keymaps.lua` — basic keymaps (window navigation, clipboard, scroll centering).
  - `autocmds.lua` — highlight-on-yank autocommand.
  - `filetypes.lua` — custom filetype patterns (Helm, docker-compose).
  - `util.lua` — `gh(x)` helper that expands short `user/repo` strings to full GitHub URLs.
- **`lua/packages/`** — One file per feature group; the loader (`init.lua`) wires everything together.
  - `init.lua` — auto-scans `lua/packages/*.lua`, collects `{ plugins, setup, priority? }` specs, calls `vim.pack.add` once with all plugins, then runs each `setup` in priority order.
  - Feature files: `ai`, `colorscheme`, `database`, `deps`, `editor`, `formatting`, `git`, `lsp`, `markdown`, `telescope`, `treesitter`, `ui`.
- **`after/ftplugin/`** — Filetype-specific overrides (e.g., `markdown.lua` enables spell check and wrap).

## Key Design Decisions

- **Plugin management**: Uses `vim.pack.add()` (native Neovim 0.12 pack API), not lazy.nvim. All plugin specs are collected into one `vim.pack.add(all)` call. After first install of telescope-fzf-native, run `make` in its pack directory.
- **Package loader**: `lua/packages/init.lua` scans the directory at runtime. Adding a new plugin group = drop a new `packages/foo.lua` file returning `{ plugins = {...}, setup = fn }`. Use `priority` (integer, higher = earlier) to control setup order; `colorscheme` is `100`, `deps` is `90`, everything else defaults to `0`.
- **LSP**: All LSP server configs live in the `servers` table in `lua/packages/lsp.lua`. Servers are registered via `vim.lsp.config[name]` and lazily enabled by `FileType` autocmds. Mason handles installation. Built-in `vim.lsp.completion.enable()` instead of nvim-cmp.
- **Formatting**: Conform.nvim with format-on-save (`lua/packages/formatting.lua`). Lua uses stylua (2-space indent). JS/TS uses prettierd/prettier.
- **Colorscheme**: Catppuccin Macchiato with transparent background (`lua/packages/colorscheme.lua`).
- **Statusline**: Heavily customized lualine with hardcoded Catppuccin Frappe hex colors and transparent background (`lua/packages/ui.lua`).
- **Python**: Uses pyenv virtualenv named `neovim` for `python3_host_prog` (set in `lua/core/options.lua`).
- **Custom filetypes**: Helm and docker-compose detection in `lua/core/filetypes.lua`.
- **TypeScript/JavaScript**: Uses vtsls LSP server (in `servers` table in `lsp.lua`).

## Formatting

Lua files in this repo use 2-space indentation (spaces, not tabs). Stylua is configured with `--indent-type Spaces --indent-width 2`.
