#!/usr/bin/env python3
"""Check that a damaged original backup stops apply before any desktop command."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

project = Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix='kessoku-apply-test-') as td:
    root = Path(td)
    sandbox = root / 'project'
    (sandbox / 'scripts').mkdir(parents=True)
    (sandbox / 'backups').mkdir()
    shutil.copy2(project / 'scripts/apply.sh', sandbox / 'scripts/apply.sh')
    shutil.copytree(project / 'backups/pre-change', sandbox / 'backups/pre-change')
    for name in ('kde-20261112-000432.tar', 'kde-20261112-000432.tar.sha256'):
        shutil.copy2(project / 'backups' / name, sandbox / 'backups' / name)
    home = root / 'home'
    for name in ('.local/share/color-schemes/KessokuComfort.colors', '.local/share/konsole/Kessoku.profile', '.local/share/konsole/Kessoku.colorscheme', 'Pictures/Wallpapers/Kessoku/kessoku-stage-4k.png'):
        p = home / name
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text('test')
    marker = root / 'command-ran'
    fakebin = root / 'bin'
    fakebin.mkdir()
    for name in ('qdbus6', 'kwriteconfig6', 'plasma-apply-colorscheme', 'plasma-apply-wallpaperimage'):
        command = fakebin / name
        command.write_text('#!/bin/sh\nprintf called >> "$KESSOKU_TEST_MARKER"\n')
        command.chmod(0o700)
    (sandbox / 'backups/pre-change/kwinrc').write_text('dañado')
    env = dict(os.environ, HOME=str(home), PATH=str(fakebin) + ':' + os.environ['PATH'], KESSOKU_TEST_MARKER=str(marker))
    result = subprocess.run([str(sandbox / 'scripts/apply.sh')], env=env, capture_output=True, text=True)
    assert result.returncode != 0, 'La aplicación aceptó una copia dañada'
    assert not marker.exists(), 'Se ejecutó un comando de escritorio pese al respaldo dañado'
    assert not list((sandbox / 'backups').glob('before-apply-*'))
print('OK: respaldo dañado detectado antes de modificar la sesión o crear una copia de reaplicación.')
