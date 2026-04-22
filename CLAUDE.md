# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the Setup

```bash
bash setup-terminal.sh
```

The script is idempotent — re-running it safely skips already-installed tools.

## What the Script Does

Single-file Bash installer (`setup-terminal.sh`) that bootstraps a macOS terminal environment end-to-end:

1. **Homebrew** — installs if missing, handles Apple Silicon PATH
2. **Ghostty** (cask) — terminal emulator with config written to `~/.config/ghostty/config`
3. **MesloLGM Nerd Font** (cask) — required for Oh My Posh and eza icons
4. **Oh My Posh** — prompt engine using the `atomic` theme
5. **eza, bat** — colorized `ls` and `cat` replacements, aliased in `.zshrc`
6. **fzf** — fuzzy finder with shell integration (`source <(fzf --zsh)`)
7. **zoxide** — frecency-based `cd` replacement (`z` / `zi` commands)
8. **vim-plug + Vim config** — installs plugins (gruvbox, NERDTree, airline, gitgutter, commentary, surround) and writes `~/.vimrc`

## Key Behaviors

- **Destructive writes**: The script overwrites `~/.zshrc` and `~/.vimrc` wholesale. It backs up a non-empty `.zshrc` to `~/.zshrc.bak.<timestamp>` before overwriting — no backup for `.vimrc`.
- **No `set -e`**: The script uses per-step error handling with a `FAILED_STEPS` array so one failure doesn't abort everything. Failed steps are reported at the end.
- **macOS-only**: Ghostty config uses `macos-titlebar-style` and `macos-option-as-alt`; Homebrew paths assume `/opt/homebrew` (Apple Silicon) or standard Intel paths.

## Architecture Note

All configuration is inlined as heredocs inside the script — there are no external config template files. Changes to Ghostty config, `.zshrc`, or `.vimrc` content must be made inside the heredocs in `setup-terminal.sh`.

## Known Environment Pitfalls

- **Homebrew not on PATH in non-interactive shells**: The script auto-loads `brew shellenv` at the top for both Apple Silicon (`/opt/homebrew`) and Intel (`/usr/local`). If running via Claude Code's Bash tool, always prepend `eval "$(/opt/homebrew/bin/brew shellenv)"`.
- **Corporate network SSL issues**: `raw.githubusercontent.com` and `ghcr.io` may fail SSL verification in corporate environments. The vim-plug curl step falls back to `-k` (skip SSL verify) automatically.
- **Transient brew download failures**: All `brew install` calls use a `brew_install` helper with 3 retries and 3s delay. Re-running the script is always safe — already-installed steps are skipped.
- **`vim +PlugInstall` requires a TTY**: The script checks `[[ -t 1 ]]` and skips the plugin install in non-interactive shells, printing a manual instruction instead. Run `vim +PlugInstall +qall` manually after the script completes.
- **Activate changes after running**: The script overwrites `~/.zshrc` but does not source it. Run `source ~/.zshrc` (or open a new terminal) to activate Oh My Posh and aliases.
