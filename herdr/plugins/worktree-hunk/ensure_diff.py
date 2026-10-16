"""Ensure one Hunk tab, without taking focus or changing existing terminals."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess


def cli(*args):
    result = subprocess.run(
        [os.environ.get("HERDR_BIN_PATH", "herdr"), *args],
        check=True, capture_output=True, text=True, timeout=20,
    )
    return json.loads(result.stdout)["result"]


def main():
    if os.environ.get("HERDR_ENV") != "1":
        raise RuntimeError("This hook must be launched by Herdr")
    event = json.loads(os.environ.get("HERDR_PLUGIN_EVENT_JSON", "{}"))
    data = event.get("data", event)
    if data.get("type") not in ("worktree_created", "worktree_opened"):
        return
    workspace = data["workspace"]["workspace_id"]
    checkout = data["worktree"]["path"]
    # Event hooks may overlap. Scope the lock to the server and workspace.
    identity = os.environ.get("HERDR_SOCKET_PATH", "") + ":" + workspace
    key = hashlib.sha256(identity.encode()).hexdigest()
    state = Path(os.environ["HERDR_PLUGIN_STATE_DIR"])
    state.mkdir(parents=True, exist_ok=True)
    with (state / (key + ".lock")).open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        tabs = cli("tab", "list", "--workspace", workspace)["tabs"]
        if not any(tab["label"] == "hunk diff" for tab in tabs):
            cli("plugin", "pane", "open", "--plugin", "local.worktree-hunk",
                "--entrypoint", "diff", "--placement", "tab",
                "--workspace", workspace, "--cwd", checkout, "--no-focus")


if __name__ == "__main__":
    main()
