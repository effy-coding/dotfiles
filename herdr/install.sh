#!/bin/bash
set -euo pipefail

HERDR_DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERDR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/herdr"

for tool in herdr python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "Missing $tool. Run the dotfiles install.sh first." >&2
        exit 1
    fi
done

link_config() {
    local source="$1" target="$2"
    mkdir -p "$(dirname "$target")"
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        local backup
        backup="$(mktemp -d "$(dirname "$target")/.herdr-backup.XXXXXX")"
        mv "$target" "$backup/$(basename "$target")"
        echo "Backed up $target to $backup"
    fi
    ln -s "$source" "$target"
}

link_config "$HERDR_DOTFILES_DIR/config.toml" "$HERDR_CONFIG_DIR/config.toml"
link_config "$HERDR_DOTFILES_DIR/plugins/worktree-hunk" "$HERDR_CONFIG_DIR/local-plugins/worktree-hunk"

# An optional local override stays outside the dotfiles repository.
HERDR_PLUGIN_DIR="$HERDR_CONFIG_DIR/local-plugins/worktree-hunk"
if [[ -f "$HERDR_CONFIG_DIR/private-plugins/worktree-hunk/herdr-plugin.toml" ]]; then
    HERDR_PLUGIN_DIR="$HERDR_CONFIG_DIR/private-plugins/worktree-hunk"
fi
herdr plugin link "$HERDR_PLUGIN_DIR"
echo "Herdr config and worktree workflow linked."
