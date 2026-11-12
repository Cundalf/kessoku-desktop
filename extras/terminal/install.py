#!/usr/bin/env python3
"""Instala el extra de forma aditiva; nunca reemplaza archivos distintos."""
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys

source = Path(__file__).resolve().parent
home = Path.home()
data = Path(os.environ.get('XDG_DATA_HOME', home / '.local/share'))
runtime = data / 'kessoku-terminal'
missing = [name for name in ('zsh','starship','fzf','zoxide','eza','batcat','fastfetch','konsole') if not shutil.which(name)]
if missing:
    sys.exit('Faltan herramientas: ' + ', '.join(missing) + '. Ver README.md; no se instaló nada.')
files = {}
for name in ('launch-shell','starship.toml','plugins.lock.json','alacritty.toml','kitty.conf','zsh','plugins'):
    src = source / name
    for item in ([src] if src.is_file() else src.rglob('*')):
        if item.is_symlink() and not item.resolve().is_relative_to(source):
            sys.exit('Enlace fuera del extra: ' + str(item))
        if item.is_file():
            files[runtime / item.relative_to(source)] = (item.read_bytes(), item.stat().st_mode & 0o777)
fontdir = data / 'fonts/KessokuShell'
for src in (source / 'fonts').iterdir():
    if src.is_file(): files[fontdir / src.name] = (src.read_bytes(), 0o644)
files[data / 'konsole/KessokuShell.colorscheme'] = ((source / 'KessokuShell.colorscheme').read_bytes(), 0o644)
profile = f'''[General]
Name=Kessoku Shell
Parent=FALLBACK/
Command="{runtime / 'launch-shell'}"
[Appearance]
ColorScheme=KessokuShell
Font=FiraCode Nerd Font Mono,11,-1,5,50,0,0,0,0,0
'''
files[data / 'konsole/KessokuShell.profile'] = (profile.encode(), 0o644)
entry = '''[Desktop Entry]
Type=Application
Name=Kessoku Terminal Extra
Comment=Zsh, Starship y herramientas del runbook en un perfil opcional
Exec=konsole --separate --profile KessokuShell
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
'''
files[data / 'applications/org.kessoku.TerminalExtra.desktop'] = (entry.encode(), 0o644)
for dst, (content, mode) in files.items():
    if dst.is_symlink() or (dst.exists() and (not dst.is_file() or dst.read_bytes() != content)):
        sys.exit('Conflicto, no se copió nada: ' + str(dst))
for dst, (content, mode) in files.items():
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        with dst.open('xb') as out: out.write(content)
        dst.chmod(mode)
subprocess.run(['fc-cache', '-f', str(fontdir)], check=True)
if shutil.which('kbuildsycoca6'):
    subprocess.run(['kbuildsycoca6','--noincremental'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
print('Extra instalado. Abrí «Kessoku Terminal Extra» o ejecutá extras/terminal/launch.sh konsole.')
print('No se cambiaron ~/.zshrc, ~/.config/starship.toml ni el perfil predeterminado.')
