#!/usr/bin/env bash
set -euo pipefail
project=$(dirname "$(dirname "$(readlink -f "$0")")")
python3 - "$project" <<'PY'
import os,sys
from pathlib import Path
root=Path(sys.argv[1]); dest=Path(os.environ.get('XDG_DATA_HOME',str(Path.home()/'.local/share')))/'applications/org.kessoku.CharacterThemes.desktop'
text='[Desktop Entry]\nType=Application\nName=Kessoku · Temas por personaje\nComment=Variantes de K-On! y Bocchi the Rock!\nExec="'+str(root/'scripts/theme.sh')+'"\nIcon=preferences-desktop-theme-global\nTerminal=false\nCategories=Settings;DesktopSettings;\n'
if dest.is_symlink() or (dest.exists() and dest.read_text()!=text):raise SystemExit('Conflicto: '+str(dest))
dest.parent.mkdir(parents=True,exist_ok=True)
if not dest.exists():dest.write_text(text)
print(dest)
PY
kbuildsycoca6 --noincremental >/dev/null 2>&1
