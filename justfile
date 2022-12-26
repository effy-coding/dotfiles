os := os()
home_dir := env_var('HOME')

_config-dir: (_dir home_dir / '.config')

_dir path: (_run-if
    "[ ! -d "+ path + " ]"
    "mkdir -p " + path)

_clone repo dst: (_run-if-not-exists "git clone" repo dst)
_cp src dst: (_run-if-not-exists "cp -n" src dst)
_link src dst: (_run-if-not-exists "ln -s" justfile_directory() / src dst)

_run-if-not-exists cmd src dst: (_run-if
    "! ([ -f " + dst + " ] || [ -d " + dst + " ])"
    cmd + " " + src + " " + dst )

_install-if-not-installed cmd install_cmd: (_run-if "[ -z `command -v " + cmd +"` ]" install_cmd)

_run-if cond body:
    #!/usr/bin/env bash
    if {{cond}}; then
        echo "run: {{body}}"
        {{body}}
    fi

git: (_link 'config/gitconfig' home_dir / '.gitconfig')

starship: (_link 'config/starship.toml' home_dir / '.config/starship.toml')

vim-plug:
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

nvim: vim-plug _config-dir && (_link 'nvim' home_dir / '.config/nvim')
    nvim -c "PlugInstall" -c "UpdateRemotePlugins" -c "qa"
    nvim -c "TSInstall vim python lua rust typescript javascript" -c "qa"

asdf:
    asdf plugin-add python
    asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

[macos]
packages: packages-brew

[macos]
packages-brew:
    cd packages && brew bundle -v

[macos]
zsh: (_link 'zsh/zshrc' home_dir / '.zshrc')

[macos]
keyboard:
    defaults write .GlobalPreferences com.apple.mouse.scaling -1
    defaults write -g ApplePressAndHoldEnabled -bool false
    defaults write -g InitialKeyRepeat -int 10
    defaults write -g KeyRepeat -int 1

[macos]
font:
    #!/usr/bin/env bash
    if [ ! -f /Library/Fonts/SF-Mono-Regular.otf ]; then
        echo "Installing SFMono Fonts"
        cp /System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts/*.otf /Library/Fonts/
        echo "Installed SFMono Fonts"
    fi
