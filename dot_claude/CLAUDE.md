# Global Claude Instructions

## Communication
- Be terse. One sentence per update while working.
- No trailing summaries of what was just done — the diff speaks for itself.
- For exploratory questions, give a recommendation and the main tradeoff in 2-3 sentences. Don't implement until confirmed.

## Code
- No comments unless the why is non-obvious.
- No docstrings, no multi-line comment blocks.
- Don't add error handling or abstractions beyond what the task requires.
- Don't clean up surrounding code unless asked.

## Working style
- Prefer editing existing files over creating new ones.
- Show diffs or previews before destructive changes. Ask before deleting files, force-pushing, or modifying shared state.
- Tag git state before large refactors.
- Run `chezmoi diff` before `chezmoi apply` when working in this repo.

## Environment
- macOS, zsh, neovim, wezterm + tmux.
- Dotfiles managed with chezmoi (`~/.local/share/chezmoi`).
