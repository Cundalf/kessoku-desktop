# Recuperación desde TTY

1. Cerrá completamente la sesión gráfica y entrá en una TTY con Ctrl+Alt+F3; iniciá sesión con tu usuario.
2. Ejecutá `~/Projects/kessoku-desktop/scripts/rollback.sh` y volvé a iniciar sesión gráfica.
3. Antes de restaurar, el script verifica SHA-256 y copia el estado que va a reemplazar a `backups/before-rollback-FECHA/`. Restaura únicamente `plasma-org.kde.plasma.desktop-appletsrc`, `kdeglobals`, `konsolerc`, `kwinrc` y `plasmashellrc`, con permisos preservados. Eso revierte paneles, widgets, wallpaper, colores, perfil predeterminado y ajustes de KWin; reemplaza cambios posteriores en esos archivos.

Se puede ensayar la copia en un directorio temporal con `scripts/rollback.sh --check`: compara contenido y permisos sin cerrar la sesión ni escribir en ~/.config. Esta prueba pasó. También se ejecutó el rollback real con plasmashell detenido: se arrancó Plasma y se comprobó el panel inferior original y la ausencia de widgets añadidos; después se recuperó la configuración final guardada y su validación pasó. No se cerraron las aplicaciones ni la sesión Wayland. El script se niega a restaurar con plasmashell activo. Los recursos agregados a ~/.local/share y ~/Pictures permanecen; no se instaló ningún paquete del sistema, por lo que no hay paquetes que eliminar. Verificá su uso posterior antes de retirar recursos manualmente.

La prueba automatizada más completa es `python3 tests/test_rollback.py`: usa un HOME temporal y simula tanto la presencia como la ausencia de Plasma; no cierra tu sesión ni demuestra el reinicio gráfico real.

Cada ejecución de `apply.sh` crea además una copia separada en `backups/before-apply-FECHA-*`, con hashes y la lista de archivos ausentes. Es una copia de los archivos presentes en disco; como Plasma sigue activo, podría no incluir cambios todavía no sincronizados que mantenga en memoria. El rollback estándar siempre usa `pre-change`, no estas copias. Para recuperar manualmente una copia posterior, cerrá la sesión gráfica, verificá `sha256sum -c SHA256SUMS` dentro de la carpeta elegida y copiá únicamente los archivos que quieras restaurar a `~/.config/`, preservando atributos. Comprobá la lista `absent` si existe antes de hacerlo.

El ensayo real reproducible está en `tests/live_rollback.sh`. Detiene y reinicia el shell varias veces y cambia temporalmente la disposición; no es una prueba para ejecutar rutinariamente. Guarda el estado actual y lo restaura al salir. La recuperación desde una TTY usa el mismo rollback; el cambio de TTY en sí no fue automatizado.
