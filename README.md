# Terminal Setup

A one-shot script to configure a modern terminal environment on macOS.

## What gets installed

| Tool | Purpose |
|------|---------|
| Ghostty | Terminal emulator |
| MesloLGM Nerd Font | Font with icons |
| Oh My Posh (atomic) | Shell prompt |
| eza | Colorful `ls` replacement |
| bat | Colorful `cat` replacement |
| fzf | Fuzzy file/history finder |
| zoxide | Smart `cd` with frecency |
| vim-plug | Vim plugin manager |
| gruvbox | Vim color theme |
| NERDTree | Vim file explorer |
| vim-airline | Vim status bar |
| vim-commentary | Comment toggling |
| vim-surround | Edit surrounding brackets/quotes |
| vim-gitgutter | Git diff signs in vim gutter |

---

## Installation

```bash
bash setup-terminal.sh
```

Then:
1. Open Ghostty from Applications (allow it on first launch)
2. Run `source ~/.zshrc`
3. Optional: set Ghostty as default in System Settings → Desktop & Dock → Default terminal app

---

## Terminal Cheatsheet

### Shell aliases

| Command | Description |
|---------|-------------|
| `ls` | eza with icons |
| `ll` | Long list with git status |
| `la` | List all including hidden |
| `tree` | Directory tree with icons |
| `cat` | bat with syntax highlighting |

### fzf

| Shortcut | Description |
|----------|-------------|
| `Ctrl+r` | Fuzzy search shell history |
| `Ctrl+t` | Fuzzy search files in current dir |
| `Alt+c` | Fuzzy cd into a subdirectory |

### zoxide

| Command | Description |
|---------|-------------|
| `z foo` | Jump to most frecent dir matching "foo" |
| `zi` | Interactive fuzzy directory picker |

---

## Vim Cheatsheet

### Modes

| Key | Description |
|-----|-------------|
| `i` | Enter insert mode |
| `Esc` | Return to normal mode |
| `v` | Enter visual mode |
| `:` | Enter command mode |

### File explorer (NERDTree)

| Key | Description |
|-----|-------------|
| `Space+e` | Toggle NERDTree sidebar |
| `Enter` | Open file |
| `i` | Open file in horizontal split |
| `s` | Open file in vertical split |
| `?` | NERDTree help |

### Splits

| Key | Description |
|-----|-------------|
| `Space+v` | New vertical split |
| `Space+h` | New horizontal split |
| `Ctrl+h` | Move to left pane |
| `Ctrl+l` | Move to right pane |
| `Ctrl+j` | Move to lower pane |
| `Ctrl+k` | Move to upper pane |

### Search

| Key | Description |
|-----|-------------|
| `/foo` | Search for "foo" |
| `n` | Next match |
| `N` | Previous match |
| `Space+/` | Clear search highlight |

### Commenting (vim-commentary)

| Key | Description |
|-----|-------------|
| `gcc` | Toggle comment on current line |
| `gc` + motion | Toggle comment on range (e.g. `gc3j`) |

### Surround (vim-surround)

| Key | Description |
|-----|-------------|
| `cs"'` | Change surrounding `"` to `'` |
| `ds"` | Delete surrounding `"` |
| `ysiw"` | Surround word with `"` |

### General

| Key | Description |
|-----|-------------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |
| `u` | Undo |
| `Ctrl+r` | Redo |
