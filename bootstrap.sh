#!/usr/bin/env bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

/opt/homebrew/bin/brew install just

echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
