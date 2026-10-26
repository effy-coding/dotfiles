#!/bin/bash
# Claude Code / Codex 기본 세팅. 지침·설정 템플릿·openv만 다룬다.
# 세션·메모리·프로젝트별 설정·인증 정보는 머신 로컬에 두고 건드리지 않는다.
set -euo pipefail

AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$AGENTS_DIR")"

link() {
    local source="$1" target="$2"
    mkdir -p "$(dirname "$target")"
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        return
    fi
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
        echo "    backed up $target"
    fi
    ln -s "$source" "$target"
    echo "    $target -> $source"
}

mkdir -p "$HOME/.claude" "$HOME/.codex" "$HOME/.local/bin"

# Claude Code CLI
if ! command -v claude >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/claude" ]]; then
    echo "==> Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

# 전역 지침: Claude와 Codex가 같은 파일을 읽는다
link "$AGENTS_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md"
link "$AGENTS_DIR/claude/statusline.py" "$HOME/.claude/statusline.py"
link "$DOTFILES_DIR/scripts/openv" "$HOME/.local/bin/openv"

# settings.json은 Claude Code가 직접 고쳐 쓰는 파일이라 symlink 대신 템플릿을 병합한다.
# 템플릿에만 있는 키를 채우고, 머신에 이미 있는 값은 유지한다.
python3 - "$AGENTS_DIR/claude/settings.json" "$HOME/.claude/settings.json" <<'PY'
import json, os, sys
tpl_path, dst_path = sys.argv[1], sys.argv[2]
tpl = json.load(open(tpl_path))
cur = json.load(open(dst_path)) if os.path.exists(dst_path) else {}

def merge(t, c):
    for k, v in t.items():
        if k not in c:
            c[k] = v
        elif isinstance(v, dict) and isinstance(c[k], dict):
            merge(v, c[k])
        elif isinstance(v, list) and isinstance(c[k], list):
            c[k] += [x for x in v if x not in c[k]]
    return c

merged = merge(tpl, cur)
for k in ("hooks", "statusLine"):
    merged[k] = json.loads(json.dumps(tpl[k]).replace("$HOME", os.path.expanduser("~")))
json.dump(merged, open(dst_path, "w"), indent=2, ensure_ascii=False)
open(dst_path, "a").write("\n")
print(f"    merged {dst_path}")
PY

# Codex 설정은 없을 때만 복사(프로젝트 trust 목록 등 로컬 상태를 덮지 않는다)
if [[ ! -f "$HOME/.codex/config.toml" ]]; then
    cp "$AGENTS_DIR/codex/config.toml" "$HOME/.codex/config.toml"
    echo "    created ~/.codex/config.toml"
fi

echo "Agent config linked."
