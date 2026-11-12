#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."
sha256sum -c backups/pre-change/SHA256SUMS
sha256sum -c backups/kde-20261112-000432.tar.sha256
for name in plasma-org.kde.plasma.desktop-appletsrc plasmashellrc kdeglobals konsolerc kwinrc; do
  original=$(tar -xOf backups/kde-20261112-000432.tar ".config/$name" | sha256sum | cut -d ' ' -f 1)
  saved=$(sha256sum "backups/pre-change/$name" | cut -d ' ' -f 1)
  [[ $original == "$saved" ]] || { echo "La copia $name no coincide con el archivo inicial" >&2; exit 1; }
done
printf '%s\n' 'Copias de recuperación: coinciden con el respaldo inicial' 
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var top=panelById(2); if(!top || top.location!=="top" || !top.floating || top.opacity!=="translucent") throw Error("Panel superior ausente o no flotante");
var required=["org.kde.plasma.kickoff","org.kde.plasma.pager","org.kde.plasma.digitalclock","org.kde.plasma.systemtray"];
required.forEach(function(id){if(!top.widgets(id).length)throw Error("Falta widget superior: "+id)});
["org.kde.plasma.mediacontroller","org.kde.plasma.systemmonitor.cpu","org.kde.plasma.systemmonitor.memory","org.kde.plasma.systemmonitor.net"].forEach(function(id){if(top.widgets(id).length)throw Error("Widget no deseado en el panel: "+id)});
var docks=panels().filter(function(p){p.currentConfigGroup=["General"];return String(p.readConfig("KessokuManaged",false))==="true"});
if(docks.length!==1 || docks[0].location!=="bottom" || !docks[0].floating || docks[0].hiding!=="dodgewindows" || docks[0].widgets("org.kde.plasma.icontasks").length!==1)throw Error("Dock Kessoku ausente o distinto de la configuración esperada");
var d=desktops()[0]; if(!d || !d.widgets("org.kde.plasma.digitalclock").length || !d.widgets("org.kde.plasma.mediacontroller").length)throw Error("Falta reloj o reproductor del escritorio");
["org.kde.plasma.systemmonitor.cpu","org.kde.plasma.systemmonitor.memory"].forEach(function(id){if(!d.widgets(id).length)throw Error("Falta monitor de escritorio: "+id)});
if(docks[0].opacity!=="translucent")throw Error("El dock no está en modo translúcido");
if(d.widgets("org.kde.plasma.systemmonitor.net").length)throw Error("Hay un monitor de red no deseado");
var tasks=docks[0].widgets("org.kde.plasma.icontasks")[0]; tasks.currentConfigGroup=["General"]; var launchers=String(tasks.readConfig("launchers"));
["org.kde.dolphin.desktop","org.kde.konsole.desktop","preferred://browser","com.microsoft.VSCode.desktop","steam.desktop","spotify.desktop"].forEach(function(id){if(launchers.indexOf(id)<0)throw Error("Falta acceso del dock: "+id)});

print("Paneles, widgets y comportamiento del dock: OK. Opacidad: "+top.opacity);'
effects=$(qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadedEffects)
for effect in blur scale slidingpopups overview magiclamp wobblywindows; do
 if ! printf '%s\n' "$effects" | grep -Fxq "$effect"; then echo "Efecto no cargado: $effect" >&2; exit 1; fi
done
printf '%s\n' 'Efectos nativos cargados: OK'
[[ $(kreadconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor) == 0.75 ]] || { echo "El factor de animación cambió" >&2; exit 1; }
current_scheme=$(kreadconfig6 --file kdeglobals --group General --key ColorScheme)
expected_wallpaper=$(python3 - "$current_scheme" <<'PYTHEME'
import json,sys
from pathlib import Path
if sys.argv[1]=='KessokuComfort':
    print(Path.home()/'Pictures/Wallpapers/Kessoku/kessoku-stage-4k.png')
else:
    items=json.load(open('themes/catalog.json'))
    selected=next((v for v in items.values() if v['scheme']==sys.argv[1]),None)
    if not selected: raise SystemExit('Esquema desconocido')
    print(Path(selected['wallpaper']).resolve())
PYTHEME
)
wallpaper_check=$(python3 - "$expected_wallpaper" <<'PYTHEME'
import json,sys
print('var expected='+json.dumps(sys.argv[1])+'; desktops().forEach(function(d){d.currentConfigGroup=["Wallpaper","org.kde.image","General"];if(decodeURIComponent(String(d.readConfig("Image"))).replace("file://","")!==expected)throw Error("Fondo inesperado")});')
PYTHEME
)
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$wallpaper_check"
printf '%s\n' 'Fondo, accesos y colores: OK'
font=$(fc-match --format '%{family}' 'JetBrains Mono')
[[ $font == *'JetBrains Mono'* ]] || { echo "Fuente no disponible: $font" >&2; exit 1; }
[[ $(kreadconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile) == Kessoku.profile ]] || { echo 'El perfil predeterminado de Konsole cambió' >&2; exit 1; }
profile="$HOME/.local/share/konsole/Kessoku.profile"
scheme="$HOME/.local/share/konsole/Kessoku.colorscheme"
[[ $(kreadconfig6 --file "$profile" --group Appearance --key ColorScheme) == Kessoku ]] || { echo 'El perfil no usa el esquema Kessoku' >&2; exit 1; }
[[ $(kreadconfig6 --file "$scheme" --group General --key Opacity) == 0.90 ]] || { echo 'La opacidad del esquema cambió' >&2; exit 1; }
[[ $(kreadconfig6 --file "$scheme" --group General --key Blur) == true ]] || { echo 'El esquema no solicita blur' >&2; exit 1; }
printf '%s\n' 'Fuente y perfil de Konsole: OK (la apariencia visual no se comprueba)' 
