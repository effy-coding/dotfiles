export PATH="$HOME/.local/bin:$PATH"

# herdr 탭(zsh -lc)·SSH 명령처럼 .zshrc를 읽지 않는 로그인 셸에서도 mise 도구(bun·node)를 찾게 한다.
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh --shims)"
fi

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
