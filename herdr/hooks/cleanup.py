"""Forget a deleted Melting worktree's setup state."""
import fcntl
import hashlib
import json
import os
from pathlib import Path


def record_path(state, checkout):
    checkout = str(Path(checkout).resolve())
    return state / (hashlib.sha256(os.fsencode(checkout)).hexdigest() + '.checkout.json')


def register(state, checkout, key):
    checkout = str(Path(checkout).resolve())
    data = {'checkout': checkout, 'key': key}
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
        print('No registered Melting checkout; skipping cleanup.')
        return
    info = json.loads(record.read_text())
    if info['checkout'] != checkout:
        raise RuntimeError('Checkout registration mismatch')
    # The native local DB of a closed checkout is dropped by the next `db:local:start`.
    # Only forget setup completion so a checkout recreated at this path is prepared again.
    with (state / (info['key'] + '.setup.lock')).open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        (state / (info['key'] + '.setup.done')).unlink(missing_ok=True)
        record.unlink(missing_ok=True)
    print('Forgot setup state for deleted checkout: ' + checkout)


if __name__ == '__main__':
    main()
