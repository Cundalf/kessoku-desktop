# Estado verificado — Kessoku Desktop

Fecha: 12 noviembre 2026. Debian 13.7; Plasma 6.3.6; KWin Wayland 6.3.6; Qt 6.8.2; KF CoreAddons 6.13.0; Konsole 25.04.2; Fastfetch 2.40.4. Monitor eDP-1 1920×1080 a 60 Hz, escala 1. Compositor OpenGL/EGL sobre Intel UHD. GPU NVIDIA adicional detectada; no se modificaron kernel ni controladores.

## Aplicado

Panel superior flotante translúcido con lanzador, paginador, bandeja y reloj. Dock centrado flotante translúcido de 64 px con Dolphin, Konsole, navegador, VS Code, Steam y Spotify; ocultación ante ventanas. Reloj protagonista con fecha y 音楽. Multimedia MPRIS con carátula, título y controles en escritorio. CPU y RAM en texto sin marcos ni listas secundarias; red retirada a pedido del usuario. Paleta Mocha rosa/violeta y wallpaper musical original. Konsole con JetBrains Mono, opacidad 0,90 y blur. Configuración Fastfetch disponible sin modificar la shell.

Se añadió Upscayl 2.15.0 a nivel de usuario (AppImage oficial verificada) y se reescaló el fondo con High Fidelity. No se instalaron paquetes de sistema. JetBrains Mono 2.304+ds-5 se extrajo de un paquete oficial Debian verificado por hash a nivel de usuario. Breeze y widgets nativos ya estaban instalados. No se añadieron repositorios, decoraciones binarias ni QML externo.

## Pruebas y evidencia

* `scripts/validate.sh`: respaldo original y hashes, paneles y opacidad, dock, widgets, colores, wallpaper, accesos y perfil Konsole.
* `tests/test_install.py`, `tests/test_apply_guard.py`, `tests/test_rollback.py`: conflictos, idempotencia, rechazo de respaldo dañado y restauración aislada.
* `tests/live_rollback.sh`: rollback real con shell detenido, arranque del panel inferior original y escritorio sin widgets añadidos; recuperación automática de la configuración final y validación posterior correcta.
* Capturas reales: `assets/previews/kessoku-desktop-final.png`, `konsole-blur-verified.png`, `dock-occlusion-verified.png`. Para las dos últimas se usó un escritorio virtual temporal; se retiró al terminar y se volvió al escritorio anterior.
* Blur de Konsole comprobado visualmente sobre wallpaper; alfa de la captura de ventana 230/255. Dock oculto ante una ventana maximizada. Scale, Sliding Popups, blur y Overview cargados. No se observó un cierre de KWin durante las pruebas; los reinicios de plasmashell fueron intencionales.
* MPRIS probado con VLC local y carátula; el usuario confirmó que el reproductor del escritorio funciona. No se afirma haber automatizado cada botón.
* Muestra de 50 s: Plasma 2,3 % de un núcleo y 500 MiB RSS; KWin 7,3 % y 300 MiB. No equivale a una prueba de juegos o garantía prolongada. Hubo errores transitorios nativos de bandeja y capturas, documentados en AUDIT.md.

## Diferencias y límites

El fondo original de 1672×941 fue reescalado por IA con Upscayl High Fidelity; se aplicó la versión 3840×2160 y se conservó otra de 2560×1440. Original y variantes preservados. No se presenta como detalle nativo de una generación 4K. Véase UPSCALING.md.

Desktop Grid no se identificó como efecto independiente compatible; se conserva Overview. Wobbly, Magic Lamp, decoraciones y estilos adicionales no se forzaron. La evaluación de terceros está en COMPONENTS.md. No se añadió clima por no aportar a la composición actual.

## Comandos

Preparar recursos: `~/Projects/kessoku-desktop/scripts/install.sh`.
Reaplicar: `~/Projects/kessoku-desktop/scripts/apply.sh` (reinicia solamente plasmashell).
Validar: `~/Projects/kessoku-desktop/scripts/validate.sh`.
Fastfetch: `fastfetch --config ~/Projects/kessoku-desktop/configs/fastfetch/config.jsonc`.
Recuperación desde TTY con sesión gráfica cerrada: `~/Projects/kessoku-desktop/scripts/rollback.sh`.

Rollback preserva el estado reemplazado y restaura cinco archivos con sus permisos. Los recursos añadidos quedan en el disco; no hay paquetes de sistema que retirar. Consulte ROLLBACK.md antes de ejecutarlo.
