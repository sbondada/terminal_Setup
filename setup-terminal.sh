#!/usr/bin/env bash
# setup-terminal.sh
# Installs and configures: Ghostty + iTerm2 Solarized Dark theme,
# MesloLGM Nerd Font, Oh My Posh (atomic theme), eza, bat, fzf, zoxide
# Compatible with: macOS on Apple Silicon or Intel

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

step() { echo "${BOLD}${BLUE}==>${RESET}${BOLD} $1${RESET}"; }
ok()   { echo "${GREEN}  ✓ $1${RESET}"; }
warn() { echo "${YELLOW}  ! $1${RESET}"; }
err()  { echo "${RED}  ✗ $1${RESET}"; }

FAILED_STEPS=()

# ── Homebrew PATH ─────────────────────────────────────────────────────────────

[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -f /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"

# ── Helpers ───────────────────────────────────────────────────────────────────

brew_install() {
  local pkg="$1" flag="${2:-}"
  local n=3
  for i in $(seq 1 $n); do
    brew install $flag "$pkg" && return 0
    warn "Attempt $i/$n failed for '$pkg', retrying in 3s..."
    sleep 3
  done
  err "Failed to install '$pkg' after $n attempts — skipping"
  FAILED_STEPS+=("$pkg")
  return 1
}

# ── Homebrew ──────────────────────────────────────────────────────────────────

step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
else
  ok "Homebrew already installed"
fi

# ── Ghostty ───────────────────────────────────────────────────────────────────

step "Installing Ghostty"
if brew list --cask ghostty &>/dev/null 2>&1; then
  ok "Ghostty already installed"
else
  brew_install ghostty --cask
fi

# ── Nerd Font ─────────────────────────────────────────────────────────────────

step "Installing MesloLGM Nerd Font"
if brew list --cask font-meslo-lg-nerd-font &>/dev/null 2>&1; then
  ok "MesloLGM Nerd Font already installed"
else
  brew_install font-meslo-lg-nerd-font --cask
fi

# ── Ghostty config ────────────────────────────────────────────────────────────

step "Writing Ghostty config"
mkdir -p "$HOME/.config/ghostty"

cat > "$HOME/.config/ghostty/config" << 'EOF'
# Font
font-family = MesloLGM Nerd Font Mono
font-size = 13

# Theme (built-in — sourced from iterm2-color-schemes)
theme = iTerm2 Solarized Dark

# Window
window-padding-x = 10
window-padding-y = 8
window-padding-balance = true
window-save-state = always

# Cursor
cursor-style = bar
cursor-style-blink = false

# macOS
macos-titlebar-style = native
macos-option-as-alt = left

# Shell Integration
shell-integration = zsh

# Quality of Life
mouse-hide-while-typing = true
copy-on-select = clipboard
scrollback-limit = 100000000
EOF

ok "Ghostty config written to ~/.config/ghostty/config"

# ── Oh My Posh ────────────────────────────────────────────────────────────────

step "Installing Oh My Posh"
if brew list oh-my-posh &>/dev/null 2>&1 || brew list --cask oh-my-posh &>/dev/null 2>&1; then
  ok "Oh My Posh already installed"
else
  brew_install jandedobbeleer/oh-my-posh/oh-my-posh
fi

# ── eza + bat ─────────────────────────────────────────────────────────────────

step "Installing eza and bat"
brew_install eza
brew_install bat

# ── fzf ───────────────────────────────────────────────────────────────────────

step "Installing fzf"
if brew list fzf &>/dev/null 2>&1; then
  ok "fzf already installed"
else
  brew_install fzf
fi

# ── zoxide ────────────────────────────────────────────────────────────────────

step "Installing zoxide"
if brew list zoxide &>/dev/null 2>&1; then
  ok "zoxide already installed"
else
  brew_install zoxide
fi

# ── ~/.zshrc ──────────────────────────────────────────────────────────────────

step "Configuring ~/.zshrc"

ZSHRC="$HOME/.zshrc"

if [[ -s "$ZSHRC" ]]; then
  BACKUP="$ZSHRC.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$ZSHRC" "$BACKUP"
  warn "Existing .zshrc backed up to $BACKUP"
fi

cat > "$ZSHRC" << 'EOF'
export PATH="$HOME/.local/bin:$PATH"

# Oh My Posh prompt
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/atomic.omp.json)"

# Colorful ls (eza)
alias ls='eza --icons --color=always'
alias ll='eza -la --icons --color=always --git'
alias la='eza -a --icons --color=always'
alias tree='eza --tree --icons --color=always'

# Colorful cat (bat)
alias cat='bat --style=auto'

# fzf shell integration (key bindings + completion)
source <(fzf --zsh)

# zoxide (smart cd with frecency)
eval "$(zoxide init zsh)"
EOF

ok "~/.zshrc configured"

# ── Vim ───────────────────────────────────────────────────────────────────────

step "Installing vim-plug"
PLUG_PATH="$HOME/.vim/autoload/plug.vim"
if [[ -f "$PLUG_PATH" ]]; then
  ok "vim-plug already installed"
else
  curl -fLo "$PLUG_PATH" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    || curl -fkLo "$PLUG_PATH" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    || { err "vim-plug download failed — download plug.vim manually to ~/.vim/autoload/plug.vim"; FAILED_STEPS+=("vim-plug"); }
fi

step "Writing ~/.vimrc"
mkdir -p "$HOME/.vim/undo"

cat > "$HOME/.vimrc" << 'EOF'
" ── Plugins (vim-plug) ────────────────────────────────────────────────────────
call plug#begin('~/.vim/plugged')
  Plug 'morhetz/gruvbox'
  Plug 'preservim/nerdtree'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-surround'
  Plug 'airblade/vim-gitgutter'
call plug#end()

" ── Theme ─────────────────────────────────────────────────────────────────────
set termguicolors
set background=dark
colorscheme gruvbox
let g:airline_theme = 'gruvbox'
let g:airline_powerline_fonts = 1

" ── Core Usability ────────────────────────────────────────────────────────────
set number relativenumber
set cursorline
set scrolloff=8
set mouse=a
set clipboard=unnamed
set splitright splitbelow

" ── Search ────────────────────────────────────────────────────────────────────
set hlsearch incsearch ignorecase smartcase

" ── Indentation ───────────────────────────────────────────────────────────────
set expandtab tabstop=4 shiftwidth=4 softtabstop=4
set smartindent autoindent

" ── Files ─────────────────────────────────────────────────────────────────────
set noswapfile nobackup undofile
set undodir=~/.vim/undo

" ── Key Mappings ──────────────────────────────────────────────────────────────
let mapleader = " "
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>/ :nohlsearch<CR>
nnoremap <leader>v :vsp<CR>
nnoremap <leader>h :sp<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
EOF

ok "~/.vimrc written"

step "Installing vim plugins"
if [[ -t 1 ]]; then
  vim +PlugInstall +qall
  ok "Vim plugins installed"
else
  warn "Non-interactive shell detected — run 'vim +PlugInstall +qall' manually to install Vim plugins"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "${BOLD}${GREEN}All done!${RESET}"
echo ""

if [[ ${#FAILED_STEPS[@]} -gt 0 ]]; then
  echo "${YELLOW}The following steps failed and need manual attention:${RESET}"
  for s in "${FAILED_STEPS[@]}"; do
    echo "  - $s"
  done
  echo ""
fi

echo "Next steps:"
echo "  1. Run: ${BOLD}source ~/.zshrc${RESET}  (or open a new terminal to activate the prompt)"
echo "  2. Open Ghostty from your Applications folder"
echo "     (macOS will prompt you to allow it on first launch — click Open)"
echo "  3. Optional: set Ghostty as your default terminal in"
echo "     System Settings → Desktop & Dock → Default terminal app"
echo ""
echo "Theme: iTerm2 Solarized Dark  |  Font: MesloLGM Nerd Font Mono"
echo "Prompt: Oh My Posh (atomic)   |  ls: eza  |  cat: bat"
echo "Fuzzy find: fzf               |  Smart cd: zoxide (z / zi)"
echo "Vim theme: gruvbox            |  Plugins: NERDTree, airline, gitgutter"
