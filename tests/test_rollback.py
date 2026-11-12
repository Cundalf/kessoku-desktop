#!/usr/bin/env python3
"""Run the real rollback script against a throwaway HOME and copied backups."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile

project = Path(__file__).resolve().parent.parent
files = ('plasma-org.kde.plasma.desktop-appletsrc', 'kdeglobals', 'konsolerc', 'kwinrc', 'plasmashellrc')
with tempfile.TemporaryDirectory(prefix='kessoku-rollback-test-') as td:
    root = Path(td)
    sandbox = root / 'project'
    (sandbox / 'scripts').mkdir(parents=True)
    (sandbox / 'backups').mkdir()
    shutil.copy2(project / 'scripts/rollback.sh', sandbox / 'scripts/rollback.sh')
    shutil.copytree(project / 'backups/pre-change', sandbox / 'backups/pre-change')
    test_home = root / 'home'
    config = test_home / '.config'
    config.mkdir(parents=True)
    for name in files:
        (config / name).write_text('CONFIGURACION POSTERIOR DE PRUEBA\n')
    fakebin = root / 'bin'
    fakebin.mkdir()
    fakepgrep = fakebin / 'pgrep'
    env = dict(os.environ, HOME=str(test_home), PATH=str(fakebin) + ':' + os.environ['PATH'])
    fakepgrep.write_text('#!/bin/sh\nexit 0\n')
    fakepgrep.chmod(0o700)
    script = sandbox / 'scripts/rollback.sh'
    refused = subprocess.run([str(script)], env=env, capture_output=True, text=True)
    assert refused.returncode != 0, 'No rechazó Plasma activo simulado'
    assert all((config / name).read_text() == 'CONFIGURACION POSTERIOR DE PRUEBA\n' for name in files)
    fakepgrep.write_text('#!/bin/sh\nexit 1\n')
    completed = subprocess.run([str(script)], env=env, capture_output=True, text=True, check=True)
    snapshots = list((sandbox / 'backups').glob('before-rollback-*'))
    assert len(snapshots) == 1
    for name in files:
        assert (config / name).read_bytes() == (sandbox / 'backups/pre-change' / name).read_bytes(), name
        assert (config / name).stat().st_mode & 0o777 == (sandbox / 'backups/pre-change' / name).stat().st_mode & 0o777, name
        assert (snapshots[0] / name).read_text() == 'CONFIGURACION POSTERIOR DE PRUEBA\n', name
print('OK: bloqueo con Plasma activo simulado; respaldo previo y restauración en HOME aislado; contenido y permisos verificados.')
