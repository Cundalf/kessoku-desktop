# Registro de cambios

2026-11-12: copia inicial de configuración y hashes. Panel 2 movido arriba; nuevo dock nativo identificado por KessokuManaged. Widgets CPU, memoria, red y multimedia, reloj y multimedia en escritorio. Fondo original y esquema de colores instalados por usuario; perfil Konsole y JetBrains Mono extraída de paquete Debian autenticado por su SHA-256 en metadatos APT. Cambios en `plasma-org.kde.plasma.desktop-appletsrc`, `kdeglobals`, `konsolerc`, `kwinrc`; respaldos previos verificados en `backups/pre-change`. KWin: blur, scale y slidingpopups. No se instalaron paquetes de sistema, ni repositorios.

El gestor de tareas original del panel superior se eliminó después de respaldarlo y se añadió uno nuevo en el dock. Los archivos añadidos bajo ~/.local/share y ~/Pictures no se borran en el rollback para no destruir usos posteriores. Los parámetros editables están en configs/ y scripts/. El backup previo a restaurar se crea al ejecutar el rollback.

Verificación posterior: se incorporó `plasmashellrc` al rollback desde la copia inicial; se eliminó la asignación de opacidad del scripting por la discrepancia entre setOpacity y setOpacityMode de Plasma 6.3.6. El instalador inspecciona todos los destinos antes de escribir, y el reaplicador solo retira el gestor original con ID 5. Se agregaron pruebas aisladas de instalación y rollback.

Cada reaplicación conserva ahora una instantánea con hashes de los cinco archivos en disco y registra los ausentes. Plasma puede tener cambios aún no sincronizados en memoria, por lo que esta instantánea no reemplaza un respaldo con la sesión cerrada. La primera instantánea creada se verificó con sha256sum.

Se verificó la correspondencia byte a byte de los cinco respaldos con el tar inicial. El validador ahora comprueba el fondo, los colores y los accesos del dock. Konsole inició con el perfil Kessoku en un HOME aislado usando el backend offscreen; su apariencia en una ventana real sigue pendiente de validar.

La reaplicación verifica primero tanto los hashes de la copia original como la coincidencia de cada archivo con el tar inicial; se niega a modificar la sesión si una copia está dañada. `tests/test_apply_guard.py` confirma este rechazo en un proyecto y HOME aislados con comandos de escritorio simulados.

A pedido del usuario, se quitaron las instancias de multimedia, CPU, memoria y red del panel superior; el reproductor se conservó y se añadieron los tres monitores al escritorio. La reaplicación y la validación reflejan esta preferencia.

Se corrigieron los monitores vacíos: los widgets creados mediante scripting cargaban con faceController nulo; reiniciar el servicio de plasmashell los inicializó. Se recrearon con separación y tamaño de escritorio y se verificaron visualmente CPU, memoria y tráfico de red.

Se retiró red a pedido del usuario y se sustituyeron los gráficos de CPU/RAM por indicadores de texto sin fondo ni datos secundarios. Se verificó visualmente la composición compacta.

Cierre de verificaciones: paneles en modo translúcido aplicado con el shell detenido; rollback real y recuperación final comprobados; capturas limpias y prueba de blur/dock guardadas. Se eliminó el escritorio QA temporal. El intento de generar fondo nativo 4K volvió a producir 1672×941 y se documentó esa limitación sin reemplazar el fondo aprobado.

Se añadió Upscayl 2.15.0 como AppImage de usuario verificada por SHA-512 oficial. Se compararon Digital Art y High Fidelity; se aplicó High Fidelity 4K y se guardó QHD. Original y variantes conservados; scripts de instalación, aplicación y validación actualizados.

Se aplicó Kessoku Comfort: selección oscura de bajo protagonismo con texto claro, filas alternas casi neutras y sin sombreado de columna ordenada. Se conserva Kessoku Mocha anterior y se respalda kdeglobals antes del cambio. Comprobado visualmente con una carpeta temporal de Dolphin.

Se corrigió el factor global de animación (0,088 → 1,0) y se habilitaron Magic Lamp de 400 ms y Wobbly suave al mover ventanas; se desactivó Squash para evitar competir con Magic Lamp. Minimización real comprobada con una ventana temporal: magiclamp apareció como efecto activo. Configuración reproducible en scripts/animations.sh y respaldo fechado previo.

A pedido del usuario se ralentizaron las animaciones: factor global 1,75 y duración base de Magic Lamp 450 ms.

Velocidad ajustada al punto intermedio solicitado: factor global 1,35 y base de Magic Lamp 400 ms.

Se dejó el factor global en 1,0 a pedido del usuario y se solicitó recarga de KWin y los efectos activos.

Factor global ajustado a 0,75 a pedido del usuario; KWin y efectos recargados.

Se añadió Kitty 0.50.0 desde el paquete binario oficial de usuario, con SHA-256 y firma GPG verificados. Lanzador de menú y enlaces kitty/kitten instalados. Configuración de apariencia basada en el escritorio y shell Zsh habitual; Konsole y los dotfiles personales siguen intactos. No se instalaron Alacritty ni Ghostty. Detalles en extras/terminal/README.md.

Se añadió extras/terminal/install-kitty.py: instalación oficial fijada en 0.50.0 con verificación SHA-256 y GPG, comprobación previa de conflictos y repetición idempotente. Se probaron dos ejecuciones y se confirmó que .zshrc y Starship personal no cambiaron. El extra de shell incluye prompt actual, cuatro plugins fijados por commit, fuente con licencia y perfil opcional.

### Variantes HTT + Kikuri
- Cinco ilustraciones nuevas (Yui, Mio, Ritsu, Tsumugi, Kikuri), originales y reescalados High Fidelity 4K/QHD.
- Paletas derivadas de Comfort con contraste de selección 8,61–9,07:1.
- Selector nativo de personaje y acceso en menú; cambios con respaldo verificable y restauración por API.
- Validación adaptada a variantes; paneles, widgets y animaciones se conservan.

### Kessoku Band completa
- Añadidas Bocchi/Hitori, Nijika, Ryo y Kita con ilustraciones nuevas generadas mediante imagegen integrada.
- Prompts completos archivados en themes/bocchi-prompts.json; originales y reescalados en sus carpetas de themes/.
- Catálogo ampliado a nueve personajes y tema base, manteniendo las variantes anteriores.
- Instalador de wallpapers basado en el catálogo: K-On! en HTT y Bocchi the Rock! en Kessoku.
- Paletas nuevas mantienen selección oscura y contraste de texto 8,63–9,13:1.
- Verificadas las cuatro variantes con validate.sh en Plasma; recuperación al tema previo probada y estado final Bocchi. Instalación de wallpapers y selector idempotente comprobada.

### Publicación en GitHub
- README rediseñado con portada, galería WebP de los nueve personajes, terminal y guías de uso.
- Excluidos respaldos, descargas, binarios e intermedios de IA; se conservan originales y fondos finales.
- El selector crea su carpeta privada de respaldos en una copia nueva del proyecto.
- Documentado el alcance de los scripts locales que necesitan respaldos no publicados.
