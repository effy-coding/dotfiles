#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Dotfiles installation starting..."
echo "    Dotfiles directory: $DOTFILES_DIR"

# ------------------------------------------------------------------------------
# 1. Install Homebrew (if not installed)
# ------------------------------------------------------------------------------
if ! command -v brew &> /dev/null; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "==> Homebrew already installed"
fi

# ------------------------------------------------------------------------------
# 2. Install packages from Brewfile
# ------------------------------------------------------------------------------
echo "==> Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# ------------------------------------------------------------------------------
# 3. Install fzf-tab (not available via Homebrew)
# ------------------------------------------------------------------------------
FZF_TAB_DIR="$HOME/.local/share/fzf-tab"
if [[ ! -d "$FZF_TAB_DIR" ]]; then
    echo "==> Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
else
    echo "==> fzf-tab already installed"
fi

# ------------------------------------------------------------------------------
# 4. Setup LazyVim (clone starter if nvim dir is empty)
# ------------------------------------------------------------------------------
NVIM_DIR="$DOTFILES_DIR/nvim"
if [[ ! -f "$NVIM_DIR/init.lua" ]]; then
    echo "==> Setting up LazyVim starter..."
    # Backup existing nvim config if exists
    if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
        echo "    Backing up existing nvim config..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    # Clone LazyVim starter into dotfiles
    rm -rf "$NVIM_DIR"
    git clone https://github.com/LazyVim/starter "$NVIM_DIR"
    rm -rf "$NVIM_DIR/.git"
else
    echo "==> LazyVim already configured"
fi

# ------------------------------------------------------------------------------
# 5. Create symbolic links
# ------------------------------------------------------------------------------
echo "==> Creating symbolic links..."

create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Remove existing file/link
    if [[ -L "$target" ]] || [[ -f "$target" ]]; then
        rm -f "$target"
    fi
    
    ln -sf "$source" "$target"
    echo "    $target -> $source"
}

# zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# git
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# ghostty
create_symlink "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

# starship
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# tmux
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# neovim
if [[ -d "$HOME/.config/nvim" ]] && [[ ! -L "$HOME/.config/nvim" ]]; then
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
fi
rm -rf "$HOME/.config/nvim"
ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
echo "    $HOME/.config/nvim -> $DOTFILES_DIR/nvim"

# ------------------------------------------------------------------------------
# 6. Setup fzf key bindings and completion
# ------------------------------------------------------------------------------
echo "==> Setting up fzf..."
if [[ -f "$(brew --prefix)/opt/fzf/install" ]]; then
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ------------------------------------------------------------------------------
# 7. Setup mise (version manager)
# ------------------------------------------------------------------------------
echo "==> Setting up mise..."
create_symlink "$DOTFILES_DIR/mise/.mise.toml" "$HOME/.mise.toml"

# Install tools defined in mise config
if command -v mise &> /dev/null; then
    echo "==> Installing mise tools (node, bun)..."
    mise install
    mise trust "$HOME/.mise.toml"
fi

# ------------------------------------------------------------------------------
# 8. Install bun global packages
# ------------------------------------------------------------------------------
echo "==> Installing bun global packages..."
if command -v bun &> /dev/null; then
    while IFS= read -r package || [[ -n "$package" ]]; do
        # Skip comments and empty lines
        [[ "$package" =~ ^#.*$ ]] && continue
        [[ -z "$package" ]] && continue
        echo "    Installing $package..."
        bun add -g "$package" 2>/dev/null || true
    done < "$DOTFILES_DIR/bun/global-packages.txt"
fi

# ------------------------------------------------------------------------------
# 9. Setup agent-deck
# ------------------------------------------------------------------------------
echo "==> Setting up agent-deck..."
create_symlink "$DOTFILES_DIR/agent-deck/config.toml" "$HOME/.agent-deck/config.toml"

# Create workspaces directories
mkdir -p "$HOME/workspaces/experiments"

# ------------------------------------------------------------------------------
# 10. Install custom scripts
# ------------------------------------------------------------------------------
echo "==> Installing custom scripts..."
mkdir -p "$HOME/.local/bin"
create_symlink "$DOTFILES_DIR/scripts/dev" "$HOME/.local/bin/dev"

# ------------------------------------------------------------------------------
# 11. Apply macOS settings
# ------------------------------------------------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "==> Apply macOS settings? (keyboard repeat, mouse acceleration, etc.) [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        "$DOTFILES_DIR/macos.sh"
    fi
fi

# ------------------------------------------------------------------------------
# Done!
# ------------------------------------------------------------------------------
echo ""
echo "==> Installation complete!"
echo ""
echo "    Please restart your terminal or run:"
echo "      source ~/.zshrc"
echo ""
echo "    On first launch, Neovim will automatically install plugins."
echo ""
echo "    Installed development tools (via mise):"
echo "      - Node.js (LTS)"
echo "      - Bun (latest)"
echo ""
echo "    Quick commands:"
echo "      dev                    # Start dev session (opencode + lazygit)"
echo "      dev -w feature/auth    # Start in git worktree"
echo "      agent-deck             # Session manager TUI"
echo ""
