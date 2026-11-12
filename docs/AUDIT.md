# Auditoría inicial — Kessoku Desktop

Debian 13.7 (trixie); Plasma workspace 6.3.6-2; KWin Wayland 6.3.6-1; KDE Frameworks CoreAddons 6.13.0; Qt 6.8.2; Konsole 25.04.2; fastfetch 2.40.4. Shell de cuenta: zsh. GPU detectadas: Intel Alder Lake-S y NVIDIA RTX 3050 Laptop; módulos i915, xe y nvidia cargados, sin determinar qué GPU utiliza la sesión. La configuración guardada menciona eDP-1 y HDMI-A-1, ambos 1920×1080 a escala 1; no demuestra qué monitores están activos.

El entorno expone variables de Wayland pero rechaza la conexión al socket; tampoco se observan procesos Plasma. No se puede validar la sesión activa ni aplicar cambios con seguridad. El sandbox solo permite escritura en este proyecto y /tmp, no en ~/.config, ~/.local, ~/Pictures ni ~/Projects. No se instalaron paquetes ni se modificó la configuración del escritorio.

La copia en backups contiene siete archivos existentes de configuración y se verificó su checksum y listado. Es una copia preliminar, no un backup completo ni un procedimiento de rollback probado. Antes de aplicar cambios se debe inventariar también perfiles de Konsole, temas, widgets, archivos ausentes y metadatos, y verificar recuperación desde una sesión con acceso apropiado.

Referencias preliminares: https://github.com/catppuccin/kde (su instalador modifica kwinrc y debe inspeccionarse); https://github.com/luisbocanegra/plasma-panel-colorizer (la función de desenfoque personalizado requiere un plugin C++; no se evaluó su compatibilidad completa ni se instaló). No se ha completado la investigación exigida de versiones, mantenimiento, dependencias y riesgos.

## Actualización con acceso a la sesión

La sesión Wayland responde y están visibles plasmashell y kwin_wayland. `kscreen-doctor` confirma un monitor eDP-1 activo de 1920×1080, escala 1, 60 Hz; el HDMI guardado no figura activo. La cuenta usa zsh. Hay VLC 3.0.24, Spotify, Steam, Firefox ESR y VS Code. No hay sudo sin contraseña.

En la sesión actual, KWin informa que blur, scale, slidingpopups y overview están cargados; Desktop Grid no se identifica como efecto soportado. La comprobación puntual de procesos durante la personalización mostró alrededor de 508 MiB RSS para plasmashell y 324 MiB para KWin, sin línea de base comparable en las mismas condiciones; no demuestra consumo sostenible bajo carga. En el journal se observaron mensajes intermitentes de baloo NotSupported, un binding loop del widget nativo de notificaciones y un TypeError transitorio de systemtray; no se ha establecido causalidad con la personalización ni se observó un cierre de plasmashell.

Una prueba VLC silenciosa expuso metadata MPRIS y carátula, mostró esos datos en el widget de escritorio y respondió a pausa por D-Bus. No se verificó el clic en los controles del widget. La instalación se ejecutó dos veces con HOME temporal y se comparó el wallpaper; reaplicar en sesión mantuvo dos paneles y un reloj y reproductor de escritorio. El backup y la restauración aislada pasaron comparación de contenido y permisos. No se probó cerrar la sesión y restaurar desde TTY.

### Verificación complementaria

Una muestra de 10 intervalos de 2 s durante la sesión activa arrojó: plasmashell CPU media 2,6 % de un núcleo, pico 3,0 %, RSS media 531 MiB; kwin_wayland CPU media 5,2 %, pico 7,5 %, RSS media 276 MiB. Los valores son puntuales, dependen de ventanas y carga, y no equivalen a una evaluación de juegos o estabilidad prolongada. Se observó un TypeError transitorio de la bandeja nativa; la sesión continuó. Un error de D-Bus con texto KESSOKU_VALIDATION_PROBE fue provocado intencionalmente para comprobar que los errores de scripting devuelven código de salida no cero.

Se detectó que `plasmashellrc` también cambió durante la configuración y faltaba en el primer script de rollback. Se recuperó la copia de la copia inicial con checksum verificado y se incluyó en la restauración. `tests/test_rollback.py` ejecuta el script completo sobre un HOME temporal con detección de Plasma simulada, compara los cinco archivos y verifica que se guarde el estado anterior. No simula KWin ni una sesión gráfica real. `tests/test_install.py` prueba idempotencia y que un conflicto conocido se rechace antes de escribir.

### Verificación posterior de recuperación y Konsole

Los SHA-256 de los cinco archivos de `backups/pre-change` coinciden con los mismos archivos extraídos del tar inicial verificado. El validador de la sesión comprueba también el esquema Kessoku, la ruta del fondo y los seis accesos configurados del dock. Konsole arrancó y terminó con código 0 usando el perfil Kessoku en un HOME y bus D-Bus temporales con `QT_QPA_PLATFORM=offscreen`; el backend sin pantalla emitió advertencias de soporte de ventanas. Esta prueba comprueba carga básica, no la representación visual, el blur ni la fuente dentro de una ventana real.

### Konsole en la sesión gráfica

Se abrió una ventana temporal real con `konsole --profile Kessoku` y texto de prueba. Spectacle capturó la ventana activa y permitió comprobar el fondo oscuro, el color de texto y la integración visual de la decoración; la captura sin contenido personal está en `assets/previews/konsole-profile.png`. Como la captura aísla la ventana, no permite confirmar visualmente el blur del fondo. La ventana de prueba terminó automáticamente.

### Segunda muestra de recursos

Durante 50 segundos en la sesión activa, con intervalos de 5 s: KWin promedió 7,3 % de un núcleo (pico 14,2 %) y 300 MiB RSS; plasmashell promedió 2,3 % (pico 2,6 %) y 500 MiB RSS. Los procesos mantuvieron sus PID durante la muestra. No es una prueba de juegos ni de estabilidad prolongada. El journal incluye un error transitorio al capturar una ventana y errores anteriores de la bandeja nativa; no se ha demostrado relación causal con el tema.
