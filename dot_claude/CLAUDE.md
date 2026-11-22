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
- macOS, zsh, neovim, wezterm + herdr.
- Dotfiles managed with chezmoi (`~/.local/share/chezmoi`).
- Expana work: start sessions from `~/expana` (local-only home repo). Its `CLAUDE.md` catalogs every repo, `.claude/skills/` holds the Expana skills (`entra-pim`, `databricks-uc`), and Expana memories live in that project's store. If a session starts inside a single Expana repo, read `~/expana/CLAUDE.md` and `~/.claude/projects/-Users-michael-forman-expana/memory/MEMORY.md` before cross-repo or Azure work.
