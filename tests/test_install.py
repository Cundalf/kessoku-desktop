#!/usr/bin/env python3
"""Check installation conflicts and idempotence in a disposable home."""
import os
from pathlib import Path
import subprocess
import tempfile

project = Path(__file__).resolve().parent.parent
script = project / 'scripts/install.sh'
with tempfile.TemporaryDirectory(prefix='kessoku-install-test-') as td:
    home = Path(td)
    env = dict(os.environ, HOME=str(home))
    profile = home / '.local/share/konsole/Kessoku.profile'
    profile.parent.mkdir(parents=True)
    profile.write_text('contenido personal de prueba\n')
    fail = subprocess.run([str(script)], cwd=project, env=env, capture_output=True, text=True)
    assert fail.returncode != 0
    assert profile.read_text() == 'contenido personal de prueba\n'
    assert not (home / '.local/share/color-schemes/KessokuMocha.colors').exists()
    profile.unlink()
    for _ in range(2):
        subprocess.run([str(script)], cwd=project, env=env, capture_output=True, text=True, check=True)
    assert profile.read_bytes() == (project / 'configs/konsole/Kessoku.profile').read_bytes()
    assert (home / 'Pictures/Wallpapers/Kessoku/kessoku-stage.png').read_bytes() == (project / 'assets/wallpapers/kessoku-stage.png').read_bytes()
print('OK: conflicto detectado antes de escribir; dos instalaciones idénticas en HOME aislado.')

# El instalador también prepara ambas resoluciones derivadas junto al original.
