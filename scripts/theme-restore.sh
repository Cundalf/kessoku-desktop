#!/usr/bin/env bash
set -euo pipefail
[[ $# == 1 ]] || { echo 'Uso: theme-restore.sh carpeta-del-respaldo' >&2; exit 2; }
snapshot=$(realpath "$1")
(cd "$snapshot" && sha256sum -c SHA256SUMS)
# Restaurar con APIs vivas; no sobrescribir kdeglobals mientras KDE lo utiliza.
scheme=$(cat "$snapshot/scheme")
script=$(python3 - "$snapshot/wallpapers.json" <<'PY'
import json,sys
items=json.load(open(sys.argv[1]))
print('var saved='+json.dumps(items)+'; saved.forEach(function(s){var d=desktopById(s.id);if(!d)throw Error("Escritorio ausente: "+s.id); d.wallpaperPlugin=s.plugin;d.currentConfigGroup=["Wallpaper",s.plugin,"General"];d.writeConfig("Image",s.image)});')
PY
)
plasma-apply-colorscheme "$scheme"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script"
echo 'Colores y fondos anteriores restaurados.'
