"""Delete only a registered Melting worktree's dedicated local DB."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def record_path(state, checkout):
    checkout = str(Path(checkout).resolve())
    return state / (hashlib.sha256(os.fsencode(checkout)).hexdigest() + '.checkout.json')


def register(state, checkout, key):
    checkout = str(Path(checkout).resolve())
    # Matches common-migration.sh's basename sanitizing and shasum derivation.
    base = re.sub(rb'[^a-zA-Z0-9_.-]', b'-', os.fsencode(Path(checkout).name)).strip(b'-').decode()
    name = 'melting-local-db-' + (base or 'wt') + '-' + hashlib.sha1(os.fsencode(checkout)).hexdigest()[:8]
    data = {'checkout': checkout, 'key': key, 'container': name}
    destination = record_path(state, checkout)
    temporary = destination.with_suffix('.tmp')
    temporary.write_text(json.dumps(data))
    temporary.replace(destination)


def main():
    if os.environ.get('HERDR_ENV') != '1':
        raise RuntimeError('This hook must be launched by Herdr')
    event = json.loads(os.environ.get('HERDR_PLUGIN_EVENT_JSON', '{}'))
    data = event.get('data', event)
    if data.get('type') != 'worktree_removed':
        return
    checkout = str(Path(data['worktree']['path']).resolve())
    state = Path(os.environ['HERDR_PLUGIN_STATE_DIR'])
    record = record_path(state, checkout)
    if not record.exists():
        print('No registered Melting DB for deleted checkout; skipping cleanup.')
        return
    info = json.loads(record.read_text())
    if info['checkout'] != checkout:
        raise RuntimeError('Checkout registration mismatch')
    if sys.argv[1:] != ['--worker']:
        # Redirect every inherited stream so Herdr can finish the event immediately.
        log_path = state / (record.stem + '.cleanup.log')
        with log_path.open('a') as log:
            worker = subprocess.Popen(
                [sys.executable, '-u', str(Path(__file__).resolve()), '--worker'],
                stdin=subprocess.DEVNULL, stdout=log, stderr=subprocess.STDOUT,
                start_new_session=True, close_fds=True, cwd=state,
            )
        print(f'DB cleanup running in background: pid={worker.pid} log={log_path}')
        return
    print('Starting checkout DB cleanup: ' + checkout, flush=True)
    with (state / (info['key'] + '.setup.lock')).open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if not record.exists():
            return
        if json.loads(record.read_text()) != info:
            raise RuntimeError('Checkout registration changed; leaving DB untouched')
        # Exact name lookup: never use prefix matching or container-wide pruning.
        names = subprocess.check_output(['docker', 'container', 'ls', '-a', '--format', '{{.Names}}'], text=True, timeout=30).splitlines()
        if info['container'] in names:
            subprocess.run(['docker', 'container', 'rm', '-f', info['container']], check=True, timeout=60)
        (state / (info['key'] + '.setup.done')).unlink(missing_ok=True)
        record.unlink()
        print('Deleted checkout DB cleanup complete: ' + info['container'])


if __name__ == '__main__':
    main()
