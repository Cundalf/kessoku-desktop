#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
fontdeb=downloads/fonts-jetbrains-mono_2.304+ds-5_all.deb
printf '%s  %s\n' a3b42e1de29a93d8e78ae14ea6898a4534af5838ce946234ec3d8c7ab8ac271d "$fontdeb" | sha256sum -c -
scratch=$(mktemp -d)
trap 'rm -rf -- "$scratch"' EXIT
dpkg-deb -x "$fontdeb" "$scratch"
sources=(configs/colors/KessokuComfort.colors configs/konsole/Kessoku.profile configs/konsole/Kessoku.colorscheme assets/wallpapers/kessoku-stage.png assets/wallpapers/kessoku-stage-4k.png assets/wallpapers/kessoku-stage-qhd.png)
destinations=("$HOME/.local/share/color-schemes/KessokuComfort.colors" "$HOME/.local/share/konsole/Kessoku.profile" "$HOME/.local/share/konsole/Kessoku.colorscheme" "$HOME/Pictures/Wallpapers/Kessoku/kessoku-stage.png" "$HOME/Pictures/Wallpapers/Kessoku/kessoku-stage-4k.png" "$HOME/Pictures/Wallpapers/Kessoku/kessoku-stage-qhd.png")
while IFS= read -r -d '' font; do
 sources+=("$font")
 destinations+=("$HOME/.local/share/fonts/Kessoku/$(basename "$font")")
done < <(find "$scratch/usr/share/fonts/truetype/jetbrains-mono" -type f -print0)
# Check every collision before creating any destination. Never follow an existing link.
for i in "${!sources[@]}"; do
 src=${sources[$i]}; dst=${destinations[$i]}
 [[ -f $src ]] || { echo "Falta el recurso $src" >&2; exit 1; }
 if [[ -L $dst ]] || { [[ -e $dst ]] && { [[ ! -f $dst ]] || ! cmp -s "$src" "$dst"; }; }; then
  echo "Conflicto: $dst; no se reemplazó ningún recurso" >&2; exit 1
 fi
done
for i in "${!sources[@]}"; do
 src=${sources[$i]}; dst=${destinations[$i]}
 if [[ ! -e $dst ]]; then
  mkdir -p "$(dirname "$dst")"
  cp -p -- "$src" "$dst"
  printf 'Creado: %s\n' "$dst"
 fi
done
mkdir -p "$HOME/Pictures/Wallpapers/HTT"
fc-cache -f "$HOME/.local/share/fonts/Kessoku"
echo 'Recursos preparados. Ejecutá scripts/apply.sh dentro de la sesión gráfica.'
