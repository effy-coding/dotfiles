"""Prepare each Melting checkout once; keep logs visible in the setup tab."""
import fcntl
import hashlib
import os
from pathlib import Path
import subprocess


def checkout_key(checkout):
    common = subprocess.check_output(
        ['git', '-C', str(checkout), 'rev-parse', '--path-format=absolute', '--git-common-dir'], text=True).strip()
    if Path(common).resolve() != (Path(os.environ.get('HERDR_MELTING_ROOT', '~/workspaces/melting')).expanduser() / '.git').resolve():
        return None
    gitdir = subprocess.check_output(
        ['git', '-C', str(checkout), 'rev-parse', '--absolute-git-dir'], text=True).strip()
    if Path(gitdir).resolve() == Path(common).resolve():
        return None
    return hashlib.sha256(gitdir.encode()).hexdigest()


def prepare():
    if os.environ.get('HERDR_ENV') != '1':
        raise RuntimeError('Run this entrypoint through Herdr')
    key = checkout_key(Path.cwd())
    if key is None:
        raise RuntimeError('Only Melting linked worktrees are supported')
    state = Path(os.environ['HERDR_PLUGIN_STATE_DIR'])
    with (state / (key + '.setup.lock')).open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        done = state / (key + '.setup.done')
        if done.exists():
            print('이미 준비된 워크트리입니다. DB를 초기화하지 않습니다.', flush=True)
            return
        env = {k: v for k, v in os.environ.items()
               if k not in ('DB_URL', 'DATABASE_URL') and not k.startswith('LOCAL_DB_')}
        for args in [('install',), ('run', 'db:local:start')]:
            print('\n$ bun ' + ' '.join(args), flush=True)
            subprocess.run(['bun', *args], env=env, stdin=subprocess.DEVNULL,
                           start_new_session=True, check=True)
        done.write_text(str(Path.cwd()) + '\n')
        print('\n워크트리 준비 완료. DB 데이터는 유지됩니다.', flush=True)


if __name__ == '__main__':
    try:
        prepare()
    except Exception as error:
        print(f'\n준비 실패: {error}\nsetup 탭을 닫고 Open worktree로 다시 열면 재시도합니다.', flush=True)
    os.execv('/bin/zsh', ['zsh', '-l'])
