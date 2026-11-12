#!/usr/bin/env bash
# Ensayo explícito de recuperación: cambia temporalmente los paneles y restaura el estado guardado.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
umask 077
snapshot=$(mktemp -d backups/live-rollback-final-XXXXXX)
files=(plasma-org.kde.plasma.desktop-appletsrc plasmashellrc kdeglobals konsolerc kwinrc)
# Detener primero permite capturar el estado sincronizado por Plasma al salir.
trap 'systemctl --user start plasma-plasmashell.service' EXIT
systemctl --user stop plasma-plasmashell.service
if pgrep -u "$(id -u)" -x plasmashell >/dev/null; then echo 'Plasma no se detuvo' >&2; exit 1; fi
for f in "${files[@]}"; do cp -a "$HOME/.config/$f" "$snapshot/$f"; done
(cd "$snapshot" && sha256sum "${files[@]}" > SHA256SUMS)
restore_final() {
 local code=$?
 trap - EXIT
 systemctl --user stop plasma-plasmashell.service || true
 for f in "${files[@]}"; do cp -a "$snapshot/$f" "$HOME/.config/$f"; done
 qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure || true
 systemctl --user start plasma-plasmashell.service
 echo "Estado final recuperado desde $snapshot"
 exit "$code"
}
trap restore_final EXIT
scripts/rollback.sh
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure
systemctl --user start plasma-plasmashell.service
sleep 3
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var p=panelById(2); if(!p || p.location!=="bottom")throw Error("No se restauró el panel inferior original");
if(!p.widgets("org.kde.plasma.icontasks").length)throw Error("No se restauró el gestor de tareas original");
if(panels().length!==1)throw Error("Persisten paneles adicionales");
if(desktops()[0].widgets().length!==0)throw Error("Persisten widgets añadidos");
print("Rollback real: panel inferior original y escritorio sin widgets añadidos verificados");'
