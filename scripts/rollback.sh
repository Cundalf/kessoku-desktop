#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
files=(plasma-org.kde.plasma.desktop-appletsrc kdeglobals konsolerc kwinrc plasmashellrc)
sha256sum -c backups/pre-change/SHA256SUMS
restore() {
  local destination=$1 f
  mkdir -p "$destination"
  for f in "${files[@]}"; do cp -a "backups/pre-change/$f" "$destination/$f"; done
}
if [[ ${1:-} == --check ]]; then
  scratch=$(mktemp -d)
  trap 'rm -rf -- "$scratch"' EXIT
  restore "$scratch"
  for f in "${files[@]}"; do cmp -s "backups/pre-change/$f" "$scratch/$f" || exit 1; [[ $(stat -c %a "backups/pre-change/$f") == $(stat -c %a "$scratch/$f") ]] || exit 1; done
  echo 'Prueba aislada de contenido y permisos correcta; la sesión no fue modificada.'
  exit 0
fi
[[ $# == 0 ]] || { echo 'Uso: rollback.sh [--check]' >&2; exit 2; }
if pgrep -u "$(id -u)" -x plasmashell >/dev/null; then
  echo 'Cerrá la sesión gráfica antes de restaurar: Plasma mantiene la configuración en memoria.' >&2
  exit 1
fi
umask 077
recovery="backups/before-rollback-$(date +%Y%m%d-%H%M%S)"
mkdir "$recovery"
for f in "${files[@]}"; do if [[ -e "$HOME/.config/$f" ]]; then cp -a "$HOME/.config/$f" "$recovery/$f"; else printf '%s\n' "$f" >> "$recovery/absent"; fi; done
restore "$HOME/.config"
echo "Configuración restaurada. El estado reemplazado se guardó en $recovery. Iniciá sesión nuevamente."
