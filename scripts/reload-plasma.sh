#!/usr/bin/env bash
# Aplica la opacidad oficial fuera del shell; evita el setter defectuoso de Plasma 6.3.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
ids=$(qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print(panels().filter(function(p){p.currentConfigGroup=["General"];return p.id===2 || String(p.readConfig("KessokuManaged",false))==="true"}).map(function(p){return p.id}).join(" "))')
[[ $ids =~ ^[0-9]+(\ [0-9]+)*$ ]] || { echo 'No se pudieron identificar los paneles' >&2; exit 1; }
umask 077
snapshot=$(mktemp -d backups/before-plasma-reload-XXXXXX)
trap 'systemctl --user start plasma-plasmashell.service' EXIT
systemctl --user stop plasma-plasmashell.service
if pgrep -u "$(id -u)" -x plasmashell >/dev/null; then echo 'El shell sigue activo; no se editó su configuración' >&2; exit 1; fi
cp -a "$HOME/.config/plasmashellrc" "$snapshot/"
for id in $ids; do kwriteconfig6 --file plasmashellrc --group PlasmaViews --group "Panel $id" --key panelOpacity 2; done
systemctl --user start plasma-plasmashell.service
trap - EXIT
for attempt in {1..30}; do
 if qdbus6 org.kde.plasmashell /PlasmaShell org.freedesktop.DBus.Peer.Ping >/dev/null 2>&1; then exit 0; fi
 sleep 0.2
done
echo 'Plasma no respondió a tiempo; revisar systemctl --user status plasma-plasmashell.service' >&2
exit 1
