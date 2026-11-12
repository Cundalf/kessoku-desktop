#!/usr/bin/env python3
"""Kitty oficial por usuario: descarga verificada y cero sobrescrituras distintas."""
from pathlib import Path
import hashlib
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import urllib.request

source = Path(__file__).resolve().parent
project = source.parent.parent
version = '0.50.0'
name = f'kitty-{version}-x86_64.txz'
expected = 'f04b11775574d6aabfb529b7e734cc0a7d7d12c7df9fb8ec1843e45420e514ee'
fingerprint = '3CE1780F78DD88DF45194FD706BC317B515ACE7C'
if os.uname().machine != 'x86_64':
    sys.exit('Esta distribución fijada es para Linux x86_64.')
if not shutil.which('gpgv'):
    sys.exit('Falta gpgv; no se instaló Kitty.')
cache = project / 'downloads'
cache.mkdir(exist_ok=True)
urls = {name: f'https://github.com/kovidgoyal/kitty/releases/download/v{version}/{name}',
        name+'.sig': f'https://github.com/kovidgoyal/kitty/releases/download/v{version}/{name}.sig',
        'kovid.gpg': 'https://calibre-ebook.com/signatures/kovid.gpg'}
for filename, url in urls.items():
    dst = cache / filename
    if not dst.exists():
        with tempfile.NamedTemporaryFile(dir=cache, delete=False) as out:
            tmp = Path(out.name)
            try:
                with urllib.request.urlopen(url, timeout=60) as response:
                    shutil.copyfileobj(response, out)
            except BaseException:
                tmp.unlink(missing_ok=True)
                raise
        tmp.replace(dst)
archive = cache / name
if hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
    sys.exit('SHA-256 incorrecto; no se ejecutó ni extrajo el paquete.')
verified = subprocess.run(['gpgv','--status-fd','1','--keyring',str(cache/'kovid.gpg'),str(cache/(name+'.sig')),str(archive)], capture_output=True, text=True)
if verified.returncode or not any(line.startswith('[GNUPG:] VALIDSIG '+fingerprint+' ') for line in verified.stdout.splitlines()):
    sys.exit('Firma o identidad del firmante incorrecta; no se instaló Kitty.')
print('SHA-256 y firma GPG oficiales: correctos')
home = Path.home()
app = home / '.local/kitty.app'
data = Path(os.environ.get('XDG_DATA_HOME', home/'.local/share'))
config = Path(os.environ.get('XDG_CONFIG_HOME', home/'.config'))/'kitty/kitty.conf'
with tempfile.TemporaryDirectory(prefix='kessoku-kitty-') as td:
    staged = Path(td)/'app'
    staged.mkdir()
    with tarfile.open(archive) as tar:
        tar.extractall(staged, filter='data')
    content = (staged/'share/applications/kitty.desktop').read_text()
    content = content.replace('Exec=kitty',f'Exec={app}/bin/kitty').replace('Icon=kitty',f'Icon={app}/share/icons/hicolor/256x256/apps/kitty.png')
    managed = {config: (source/'kitty.conf').read_bytes(),
               data/'applications/kitty.desktop': content.encode()}
    for item in (source/'fonts').iterdir():
        if item.is_file(): managed[data/'fonts/KessokuShell'/item.name] = item.read_bytes()
    # Detectar todos los conflictos antes de escribir destinos.
    for dst, value in managed.items():
        if dst.is_symlink() or (dst.exists() and (not dst.is_file() or dst.read_bytes()!=value)):
            sys.exit('Conflicto; no se reemplazó nada: '+str(dst))
    links = {home/'.local/bin'/n: app/'bin'/n for n in ('kitty','kitten')}
    for link, target in links.items():
        if link.is_symlink():
            if link.resolve()!=target: sys.exit('Enlace existente distinto: '+str(link))
        elif link.exists(): sys.exit('Archivo existente distinto: '+str(link))
    if app.is_symlink() or (app.exists() and not app.is_dir()): sys.exit('Destino de Kitty no válido')
    if app.exists():
        for src in staged.rglob('*'):
            dst = app/src.relative_to(staged)
            if src.is_symlink():
                if not dst.is_symlink() or os.readlink(src)!=os.readlink(dst): sys.exit('Kitty existente distinto: '+str(dst))
            elif src.is_file():
                if not dst.is_file() or hashlib.sha256(src.read_bytes()).digest()!=hashlib.sha256(dst.read_bytes()).digest(): sys.exit('Kitty existente distinto: '+str(dst))
    else:
        app.parent.mkdir(parents=True, exist_ok=True)
        shutil.copytree(staged, app, symlinks=True)
    for dst, value in managed.items():
        if not dst.exists():
            dst.parent.mkdir(parents=True,exist_ok=True)
            with dst.open('xb') as out: out.write(value)
    for link,target in links.items():
        if not link.is_symlink():
            link.parent.mkdir(parents=True,exist_ok=True)
            link.symlink_to(target)
subprocess.run([str(app/'bin/kitty'),'--version'],check=True)
if shutil.which('fc-cache'): subprocess.run(['fc-cache','-f',str(data/'fonts/KessokuShell')],check=True)
if shutil.which('kbuildsycoca6'): subprocess.run(['kbuildsycoca6','--noincremental'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=True)
print('Kitty listo. Konsole, ~/.zshrc y Starship personal no se modificaron.')
