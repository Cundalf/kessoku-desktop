#!/usr/bin/env bash
set -euo pipefail
root=${XDG_DATA_HOME:-$HOME/.local/share}/kessoku-terminal
[[ -x "$root/launch-shell" ]] || { echo 'Primero ejecutá python3 extras/terminal/install.py' >&2; exit 1; }
case ${1:-konsole} in
 konsole) exec konsole --separate --profile KessokuShell ;;
 kitty) exec kitty --config "$root/kitty.conf" "$root/launch-shell" ;;
 alacritty) exec alacritty --config-file "$root/alacritty.toml" -e "$root/launch-shell" ;;
 shell) exec "$root/launch-shell" ;;
 *) echo 'Uso: launch.sh [konsole|kitty|alacritty|shell]' >&2; exit 2 ;;
esac
