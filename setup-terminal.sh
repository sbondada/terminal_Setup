#!/usr/bin/env bash
# setup-terminal.sh
# Installs and configures: Ghostty + iTerm2 Solarized Dark theme,
# MesloLGM Nerd Font, Oh My Posh (atomic theme), eza, bat, fzf, zoxide
# Compatible with: macOS on Apple Silicon or Intel

set -e

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

step() { echo "${BOLD}${BLUE}==>${RESET}${BOLD} $1${RESET}"; }
ok()   { echo "${GREEN}  ✓ $1${RESET}"; }
warn() { echo "${YELLOW}  ! $1${RESET}"; }

# ── Homebrew ──────────────────────────────────────────────────────────────────

step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for Apple Silicon
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  ok "Homebrew already installed"
fi

# ── Ghostty ───────────────────────────────────────────────────────────────────

step "Installing Ghostty"
if brew list --cask ghostty &>/dev/null 2>&1; then
  ok "Ghostty already installed"
else
  brew install --cask ghostty
  ok "Ghostty installed"
fi

# ── Nerd Font ─────────────────────────────────────────────────────────────────

step "Installing MesloLGM Nerd Font"
if brew list --cask font-meslo-lg-nerd-font &>/dev/null 2>&1; then
  ok "MesloLGM Nerd Font already installed"
else
  brew install --cask font-meslo-lg-nerd-font
  ok "MesloLGM Nerd Font installed"
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
if brew list oh-my-posh &>/dev/null 2>&1; then
  ok "Oh My Posh already installed"
else
  brew install jandedobbeleer/oh-my-posh/oh-my-posh
  ok "Oh My Posh installed"
fi

# ── eza + bat ─────────────────────────────────────────────────────────────────

step "Installing eza and bat"
brew install eza bat
ok "eza and bat installed"

# ── fzf ───────────────────────────────────────────────────────────────────────

step "Installing fzf"
if brew list fzf &>/dev/null 2>&1; then
  ok "fzf already installed"
else
  brew install fzf
  ok "fzf installed"
fi

# ── zoxide ────────────────────────────────────────────────────────────────────

step "Installing zoxide"
if brew list zoxide &>/dev/null 2>&1; then
  ok "zoxide already installed"
else
  brew install zoxide
  ok "zoxide installed"
fi

# ── ~/.zshrc ──────────────────────────────────────────────────────────────────

step "Configuring ~/.zshrc"

ZSHRC="$HOME/.zshrc"

# Backup existing .zshrc if it exists and has content
if [[ -s "$ZSHRC" ]]; then
  BACKUP="$ZSHRC.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$ZSHRC" "$BACKUP"
  warn "Existing .zshrc backed up to $BACKUP"
fi

# Write fresh .zshrc
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
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  ok "vim-plug installed"
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
vim +PlugInstall +qall
ok "Vim plugins installed"

# ── Done ──────────────────────────────────────────────────────────────────────

echo ""
echo "${BOLD}${GREEN}All done!${RESET}"
echo ""
echo "Next steps:"
echo "  1. Open Ghostty from your Applications folder"
echo "     (macOS will prompt you to allow it on first launch — click Open)"
echo "  2. Run: ${BOLD}source ~/.zshrc${RESET}"
echo "  3. Optional: set Ghostty as your default terminal in"
echo "     System Settings → Desktop & Dock → Default terminal app"
echo ""
echo "Theme: iTerm2 Solarized Dark  |  Font: MesloLGM Nerd Font Mono"
echo "Prompt: Oh My Posh (atomic)   |  ls: eza  |  cat: bat"
echo "Fuzzy find: fzf               |  Smart cd: zoxide (z / zi)"
echo "Vim theme: gruvbox            |  Plugins: NERDTree, airline, gitgutter"
