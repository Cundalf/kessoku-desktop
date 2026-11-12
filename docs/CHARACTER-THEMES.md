# HTT + Kessoku Band — variantes de personaje

Nueve paletas sobre Kessoku Comfort, con selección oscura y texto claro. Conservan paneles, widgets, tipografías, efectos y factor de animación 0,75. No sobrescriben la configuración personal de Kitty, Starship ni Zsh.

| Tema | Ambiente | Acento |
|---|---|---|
| Yui Hirasawa | Ensayo cálido, guitarra sunburst | Coral |
| Mio Akiyama | Estudio nocturno, bajo | Azul |
| Ritsu Tainaka | Batería y focos cálidos | Ámbar |
| Tsumugi Kotobuki | Teclados y luz crepuscular | Lavanda |
| Hitori Gotoh · Bocchi | Guitarra negra y luces rosas | Rosa |
| Nijika Ijichi | Batería y focos suaves | Amarillo |
| Ryo Yamada | Bajo y ensayo nocturno | Azul frío |
| Ikuyo Kita | Guitarra azul y escenario | Coral rojo |
| Kikuri Hiroi | Club de rock, bajo | Ciruela |

Desde la raíz del proyecto:

```bash
scripts/theme.sh           # Selector gráfico nativo
scripts/theme.sh --list
scripts/theme.sh mio       # yui, mio, ritsu, tsumugi, bocchi, nijika, ryo, kita, kikuri
```

Cada cambio guarda `kdeglobals`, el esquema anterior y los fondos por escritorio en `backups/before-theme-*`, con SHA256. Se restauran mediante APIs de Plasma sin sobrescribir archivos activos:

```bash
scripts/theme-restore.sh backups/before-theme-FECHA-IDENTIFICADOR
```

`kdeglobals` queda como copia adicional para recuperación manual con la sesión cerrada. La restauración rápida recupera esquema y fondo, no otros ajustes hechos después. Los esquemas instalados quedan disponibles; no se elimina ningún recurso personal.

El comando `scripts/apply.sh` reaplica el diseño base Kessoku Comfort y su fondo original 4K. Para una variante, ejecutar luego `scripts/theme.sh PERSONAJE`.

Los fondos son ilustraciones nuevas generadas con la herramienta integrada imagegen; no son imágenes oficiales ni capturas del anime. Originales y versiones de escritorio quedan en `themes/PERSONAJE/`. El tamaño 4K es un reescalado con el modelo High Fidelity de Upscayl ya verificado en este proyecto, no generación nativa 4K. Las especificaciones resumidas de los primeros fondos están en `themes/prompts.json`; los prompts completos de Kessoku Band están en `themes/bocchi-prompts.json`.

Para modificar acentos: editar `themes/build.py`, ejecutar `python3 themes/build.py`. El instalador rechaza un esquema ya instalado con distinto contenido: conservar una copia del recurso anterior antes de sustituirlo deliberadamente.

Para agregar el selector al menú de aplicaciones (instalación idempotente, sin cambiar valores predeterminados):

```bash
scripts/install-theme-launcher.sh
```

La entrada se llama **Kessoku · Temas por personaje**. Se puede quitar eliminando únicamente `~/.local/share/applications/org.kessoku.CharacterThemes.desktop`.

El selector incluye **Kessoku original** (`scripts/theme.sh base`) para volver al fondo de escenario sin personaje sin reaplicar toda la distribución.

Limitación de ilustración: son interpretaciones generadas; por ejemplo, el bajo de Mio aparece orientado para diestros aunque se solicitó zurdo. No se presenta como arte oficial ni reproducción exacta.

La colección también se instaló en `~/Pictures/Wallpapers/HTT/` (las cuatro de K-On!) y `~/Pictures/Wallpapers/Kessoku/` (Bocchi, Nijika, Ryo, Kita y Kikuri). Para reproducir esas copias:

```bash
scripts/install-character-wallpapers.py
```

Verificación realizada: las cinco variantes se aplicaron por API en Plasma y pasaron `scripts/validate.sh`; se probó además restaurar Yui a Comfort con su fondo anterior. Selector de menú validado y sus instaladores ejecutados dos veces. Estado de esa primera entrega: Kikuri. Integridad de recursos: `sha256sum -c themes/SHA256SUMS` desde la raíz del proyecto.


## Ampliación: Bocchi the Rock!

Bocchi, Nijika, Ryo y Kita están instaladas y cada una pasó la validación en la sesión real. Se probó restaurar el tema previo (Yui y su fondo) desde el respaldo anterior a la prueba. Las variantes anteriores conservaron sus hashes. Los instaladores del selector y de wallpapers pasaron dos ejecuciones consecutivas.

Estado al finalizar esta ampliación: **Bocchi**. Sus recursos están en `themes/bocchi/`, `themes/nijika/`, `themes/ryo/` y `themes/kita/`; copias 4K/QHD en `~/Pictures/Wallpapers/Kessoku/`. Fueron generados con imagegen integrada y reescalados mediante el modelo High Fidelity ya verificado. No se instalaron paquetes nuevos.

```bash
scripts/theme.sh bocchi
scripts/theme.sh nijika
scripts/theme.sh ryo
scripts/theme.sh kita
```
