#!/bin/bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
for f in "$HOME/.local/share/color-schemes/KessokuComfort.colors" "$HOME/.local/share/konsole/Kessoku.profile" "$HOME/.local/share/konsole/Kessoku.colorscheme" "$HOME/Pictures/Wallpapers/Kessoku/kessoku-stage-4k.png"; do test -f "$f" || { echo "Falta $f" >&2; exit 1; }; done
# No cambiar la sesión si no existe un respaldo original íntegro.
sha256sum -c backups/pre-change/SHA256SUMS
sha256sum -c backups/kde-20261112-000432.tar.sha256
for name in plasma-org.kde.plasma.desktop-appletsrc plasmashellrc kdeglobals konsolerc kwinrc; do
  original=$(tar -xOf backups/kde-20261112-000432.tar ".config/$name" | sha256sum | cut -d ' ' -f 1)
  saved=$(sha256sum "backups/pre-change/$name" | cut -d ' ' -f 1)
  [[ $original == "$saved" ]] || { echo "Copia original inconsistente: $name" >&2; exit 1; }
done
# Guardar los archivos actuales antes de cada reaplicación, sin modificar la copia inicial.
umask 077
snapshot=$(mktemp -d "backups/before-apply-$(date +%Y%m%d-%H%M%S)-XXXXXX")
for name in plasma-org.kde.plasma.desktop-appletsrc plasmashellrc kdeglobals konsolerc kwinrc; do
  if [[ -f "$HOME/.config/$name" ]]; then
    cp -a -- "$HOME/.config/$name" "$snapshot/$name"
  else
    printf '%s\n' "$name" >> "$snapshot/absent"
  fi
done
(cd "$snapshot" && find . -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 -r sha256sum > SHA256SUMS)
printf 'Copia previa: %s\n' "$snapshot"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat configs/plasma/layout.js)"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat configs/plasma/monitors.js)"
scripts/animations.sh
plasma-apply-colorscheme KessokuComfort
kwriteconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile Kessoku.profile
plasma-apply-wallpaperimage "$HOME/Pictures/Wallpapers/Kessoku/kessoku-stage-4k.png"

# Inicializar controladores de sensores y aplicar transparencia con Plasma detenido.
scripts/reload-plasma.sh
