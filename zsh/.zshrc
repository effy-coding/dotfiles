# ==============================================================================
# Zsh Configuration
# ==============================================================================

# ------------------------------------------------------------------------------
# Path
# ------------------------------------------------------------------------------
export PATH="$HOME/.bun/bin:$HOME/.local/bin:$PATH"

# ------------------------------------------------------------------------------
# Android SDK (Android Studio)
# ------------------------------------------------------------------------------
export ANDROID_HOME="$HOME/Library/Android/sdk"
if [[ -d "$ANDROID_HOME" ]]; then
    export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
fi

# ------------------------------------------------------------------------------
# Java (OpenJDK 17)
# ------------------------------------------------------------------------------
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# ------------------------------------------------------------------------------
# History Settings
# ------------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_VERIFY               # Do not execute immediately upon history expansion

# ------------------------------------------------------------------------------
# Completion Settings
# ------------------------------------------------------------------------------
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Completion menu
zstyle ':completion:*' menu select

# Colorize completions
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ------------------------------------------------------------------------------
# Plugins
# ------------------------------------------------------------------------------

# zsh-autosuggestions (Homebrew)
if [[ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# fzf-tab (must be loaded before fzf)
if [[ -d "$HOME/.local/share/fzf-tab" ]]; then
    source "$HOME/.local/share/fzf-tab/fzf-tab.plugin.zsh"
    
    # fzf-tab settings
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
fi

# fzf key bindings and completion
if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
fi

# fzf default options
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9
  --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
  --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
"

# ------------------------------------------------------------------------------
# Aliases
# ------------------------------------------------------------------------------

# eza (modern ls)
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias lt='eza --tree'

# Package managers
alias p='pnpm'
alias n='npm'
alias b='bun'

# CLI tools
alias sb='supabase'
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'
alias lg='lazygit'

# Directories
alias obs='cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/effy'

# ------------------------------------------------------------------------------
# mise (version manager)
# ------------------------------------------------------------------------------
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# ------------------------------------------------------------------------------
# Starship Prompt
# ------------------------------------------------------------------------------
eval "$(starship init zsh)"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
