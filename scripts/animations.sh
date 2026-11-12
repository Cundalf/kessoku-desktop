#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
for effect in magiclamp wobblywindows scale slide; do
 [[ $(qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.isEffectSupported "$effect") == true ]] || { echo "Efecto no compatible: $effect" >&2; exit 1; }
done
umask 077
snapshot=$(mktemp -d backups/before-animations-XXXXXX)
cp -a "$HOME/.config/kwinrc" "$HOME/.config/kdeglobals" "$snapshot/"
kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor 0.75
for effect in blur scale slidingpopups slide maximize fadingpopups magiclamp wobblywindows; do
 kwriteconfig6 --file kwinrc --group Plugins --key "${effect}Enabled" true
done
# Un solo efecto por apertura/cierre y por minimización.
for effect in squash glide fade; do kwriteconfig6 --file kwinrc --group Plugins --key "${effect}Enabled" false; done
kwriteconfig6 --file kwinrc --group Effect-magiclamp --key AnimationDuration 400
kwriteconfig6 --file kwinrc --group Effect-wobblywindows --key WobblynessLevel 0
kwriteconfig6 --file kwinrc --group Effect-wobblywindows --key MoveWobble true
kwriteconfig6 --file kwinrc --group Effect-wobblywindows --key ResizeWobble false
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure
for effect in squash glide fade; do qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect "$effect"; done
for effect in scale magiclamp wobblywindows slide maximize fadingpopups slidingpopups; do
 qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect "$effect" >/dev/null
 qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.reconfigureEffect "$effect"
done
