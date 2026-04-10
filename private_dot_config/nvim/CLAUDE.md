# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration based on kickstart.nvim. It is a single-file config (`init.lua`) using the native `vim.pack` plugin manager (not lazy.nvim). Targets Neovim 0.12+ (uses `vim.pack.add`, `vim.lsp.config`, `vim.lsp.enable`, and built-in completion via `vim.lsp.completion.enable`).

## Architecture

- **`init.lua`** — The entire config lives in one file: options, keymaps, autocommands, plugin declarations, and all plugin configuration. Sections are clearly marked with comment headers.
- **`lsp/`** — Native LSP config files loaded by `vim.lsp.config` (currently just `lua_ls.lua`, but the main server configs are defined inline in `init.lua`'s `servers` table).
- **`after/ftplugin/`** — Filetype-specific overrides (e.g., `markdown.lua` enables spell check and wrap).

## Key Design Decisions

- **Plugin management**: Uses `vim.pack.add()` (native Neovim 0.12 pack API), not lazy.nvim. Plugins are declared in a single `vim.pack.add({...})` call. After first install of telescope-fzf-native, you must manually run `make` in its directory.
- **LSP**: All LSP servers are configured in the `servers` table in `init.lua` using `vim.lsp.config[name]` and lazily enabled via `FileType` autocmds. Mason handles installation. Uses built-in `vim.lsp.completion.enable()` instead of nvim-cmp.
- **Formatting**: Conform.nvim with format-on-save. Lua uses stylua (2-space indent). JS/TS uses prettierd/prettier.
- **Colorscheme**: Catppuccin Macchiato with transparent background.
- **Statusline**: Heavily customized lualine with Catppuccin Frappe colors and transparent background.
- **Python**: Uses pyenv virtualenv named `neovim` for `python3_host_prog`.
- **Custom filetypes**: Helm chart templates and docker-compose files have custom filetype detection patterns.
- **TypeScript/JavaScript**: Uses vtsls as the LSP server (configured in the `servers` table, installed via Mason).

## Formatting

Lua files in this repo use 2-space indentation (spaces, not tabs). Stylua is configured with `--indent-type Spaces --indent-width 2`.
