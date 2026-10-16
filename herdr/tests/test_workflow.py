import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'plugins/worktree-hunk'))
import ensure_diff


class DiffTabTests(unittest.TestCase):
    def test_worktree_events_create_diff_without_taking_focus(self):
        for kind in ['worktree_created', 'worktree_opened']:
            with self.subTest(kind=kind), tempfile.TemporaryDirectory() as directory:
                env = {'HERDR_ENV': '1', 'HERDR_PLUGIN_STATE_DIR': directory,
                       'HERDR_PLUGIN_EVENT_JSON': json.dumps({'data': {
                           'type': kind, 'workspace': {'workspace_id': 'test'},
                           'worktree': {'path': '/checkout with spaces'}}})}
                with patch.dict(os.environ, env):
                    with patch.object(ensure_diff, 'cli', side_effect=[{'tabs': [{'label': '1'}]}, {}]) as cli:
                        ensure_diff.main()
                        self.assertEqual(cli.call_count, 2)
                        self.assertIn('--no-focus', cli.call_args.args)
                        self.assertIn('/checkout with spaces', cli.call_args.args)
                    with patch.object(ensure_diff, 'cli', return_value={'tabs': [{'label': 'hunk diff'}]}) as cli:
                        ensure_diff.main()
                        self.assertEqual(cli.call_count, 1)

    def test_unrelated_event_does_not_change_tabs(self):
        with patch.dict(os.environ, {'HERDR_ENV': '1', 'HERDR_PLUGIN_EVENT_JSON': '{"type":"workspace_closed"}'}):
            with patch.object(ensure_diff, 'cli') as cli:
                ensure_diff.main()
                cli.assert_not_called()


if __name__ == '__main__':
    unittest.main()
