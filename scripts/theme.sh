#!/usr/bin/env bash
set -euo pipefail
project=$(dirname "$(dirname "$(readlink -f "$0")")")
cd "$project"
if [[ ${1:-} == --list ]]; then
  python3 -c 'import json; d=json.load(open("themes/catalog.json")); [print(k+" — "+v["name"]) for k,v in d.items()]'
  exit
fi
if [[ $# == 0 ]]; then
  mapfile -t options < <(python3 -c 'import json; d=json.load(open("themes/catalog.json")); [print(k+"\n"+v["name"]) for k,v in d.items()]')
  choice=$(kdialog --title 'Kessoku · Elegir tema' --menu 'Personaje y ambiente' "${options[@]}") || exit 0
else
  choice=$1
fi
[[ $choice =~ ^[a-z]+$ && -d themes/$choice ]] || { echo 'Tema desconocido' >&2; exit 1; }
mapfile -t meta < <(python3 -c 'import json,sys; x=json.load(open("themes/catalog.json"))[sys.argv[1]]; print(x["scheme"]); print(x["wallpaper"])' "$choice")
scheme=${meta[0]}; wallpaper="$project/${meta[1]}"
[[ -f $wallpaper && -f themes/$choice/$scheme.colors ]] || { echo 'Faltan recursos del tema' >&2; exit 1; }
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print(desktops().length)' >/dev/null
umask 077
mkdir -p "$project/backups"
snapshot=$(mktemp -d "$project/backups/before-theme-$(date +%Y%m%d-%H%M%S)-XXXXXX")
cp -a "$HOME/.config/kdeglobals" "$snapshot/kdeglobals"
kreadconfig6 --file kdeglobals --group General --key ColorScheme > "$snapshot/scheme"
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'print(JSON.stringify(desktops().map(function(d){d.currentConfigGroup=["Wallpaper","org.kde.image","General"];return {id:d.id,plugin:d.wallpaperPlugin,image:String(d.readConfig("Image",""))}})))' > "$snapshot/wallpapers.json"
python3 -c 'import json,sys; assert isinstance(json.load(open(sys.argv[1])),list)' "$snapshot/wallpapers.json"
(cd "$snapshot" && sha256sum kdeglobals scheme wallpapers.json > SHA256SUMS)
target="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes/$scheme.colors"
mkdir -p "$(dirname "$target")"
if [[ -e $target ]]; then cmp -s "themes/$choice/$scheme.colors" "$target" || { echo "Conflicto: $target" >&2; exit 1; }; else cp -p "themes/$choice/$scheme.colors" "$target"; fi
plasma-apply-colorscheme "$scheme"
plasma-apply-wallpaperimage "$wallpaper"
[[ $(kreadconfig6 --file kdeglobals --group General --key ColorScheme) == "$scheme" ]]
printf 'Tema aplicado: %s\nRecuperación: scripts/theme-restore.sh %q\n' "$choice" "$snapshot"
