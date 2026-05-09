#!/bin/sh
# One-time migration: move tool dirs to XDG locations after env-var redirects were added.

move_if_exists() {
  src="$1"
  dst="$2"
  if [ -e "$src" ] && [ ! -e "$dst" ]; then
    mkdir -p "$(dirname "$dst")"
    mv "$src" "$dst"
  fi
}

move_if_exists "$HOME/.cargo"      "${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
move_if_exists "$HOME/.rustup"     "${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
move_if_exists "$HOME/.azure"      "${XDG_DATA_HOME:-$HOME/.local/share}/azure"
move_if_exists "$HOME/.terminfo"   "${XDG_DATA_HOME:-$HOME/.local/share}/terminfo"
move_if_exists "$HOME/.colima"     "${XDG_CONFIG_HOME:-$HOME/.config}/colima"
move_if_exists "$HOME/.ipython"    "${XDG_CONFIG_HOME:-$HOME/.config}/ipython"
move_if_exists "$HOME/.jupyter"    "${XDG_CONFIG_HOME:-$HOME/.config}/jupyter"

# Remove old history/cache files; tools will recreate at new XDG paths.
rm -f "$HOME/.lesshst" "$HOME/.node_repl_history" "$HOME/.python_history" \
      "$HOME/.ts_node_repl_history" "$HOME/.zsh_history" "$HOME/.psql_history" \
      "$HOME/.zcompdump" "$HOME/.wget-hsts"
rm -rf "$HOME/.npm" "$HOME/.matplotlib"

# Stale dirs and files
rm -rf "$HOME/dotfiles" "$HOME/dotnet"
rm -f "$HOME/wezterm.sh" "$HOME/.bash_history"
