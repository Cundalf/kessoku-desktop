#!/usr/bin/env python3
"""Copiar la colección sin sobrescribir fondos existentes distintos."""
import shutil,json
from pathlib import Path
root=Path(__file__).resolve().parent.parent
jobs=[]
for name in json.loads((root/'themes/catalog.json').read_text()):
    if name=='base':continue
    group='HTT' if name in ('yui','mio','ritsu','tsumugi') else 'Kessoku'
    for size in ('4k','qhd'):
        src=root/'themes'/name/f'wallpaper-{size}.png'
        dst=Path.home()/'Pictures/Wallpapers'/group/f'{name}-{size}.png'
        if not src.is_file():raise SystemExit(f'Falta {src}')
        if dst.is_symlink() or (dst.exists() and dst.read_bytes()!=src.read_bytes()):raise SystemExit(f'Conflicto: {dst}')
        jobs.append((src,dst))
for src,dst in jobs:
    dst.parent.mkdir(parents=True,exist_ok=True)
    if not dst.exists():shutil.copy2(src,dst)
    print(dst)
