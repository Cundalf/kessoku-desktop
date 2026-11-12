#!/usr/bin/env bash
set -euo pipefail
project=$(dirname "$(dirname "$(readlink -f "$0")")")
[[ $# -ge 2 && $# -le 3 ]] || { echo 'Uso: upscale-image.sh imagen.png /ruta/prefijo [gpu-id=1]' >&2; exit 2; }
input=$(realpath "$1")
prefix=$(realpath -m "$2")
gpu=${3:-1}
[[ $gpu =~ ^[0-9]+$ ]] || { echo 'GPU inválida' >&2; exit 2; }
[[ -f $input ]] || { echo 'No existe la imagen' >&2; exit 1; }
for suffix in ai4x 4k qhd; do [[ ! -e "$prefix-$suffix.png" ]] || { echo "Ya existe $prefix-$suffix.png" >&2; exit 1; }; done
cd "$project"
sha256sum -c configs/upscayl-runtime.sha256
mkdir -p "$(dirname "$prefix")"
base=tools/upscayl-2.15.0/squashfs-root/resources
"$base/bin/upscayl-bin" -i "$input" -o "$prefix-ai4x.png" -m "$base/models" -n high-fidelity-4x -z 4 -s 4 -g "$gpu" -t 256 -f png
convert "$prefix-ai4x.png" -filter Lanczos -resize '3840x2160^' -gravity center -extent 3840x2160 +repage "$prefix-4k.png"
convert "$prefix-ai4x.png" -filter Lanczos -resize '2560x1440^' -gravity center -extent 2560x1440 +repage "$prefix-qhd.png"
identify "$prefix-4k.png" "$prefix-qhd.png"
