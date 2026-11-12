# Terminal extra — Konsole y Kitty

Se conserva Konsole y se añadió Kitty 0.50.0 a nivel de usuario. Kitty usa la shell predeterminada de la cuenta (Zsh) y, por tanto, el ~/.zshrc y ~/.config/starship.toml actuales. No se modificaron esos archivos ni el terminal predeterminado. Apariencia en kitty.conf: FiraCode Nerd Font Mono, paleta Mocha, opacidad 0,95 y padding.

Instalación de Kitty: paquete oficial https://github.com/kovidgoyal/kitty/releases/tag/v0.50.0 . Archivo downloads/kitty-0.50.0-x86_64.txz, SHA-256 `f04b11775574d6aabfb529b7e734cc0a7d7d12c7df9fb8ec1843e45420e514ee`. Firma RSA verificada con la clave oficial `3CE1780F78DD88DF45194FD706BC317B515ACE7C`, descargada de https://calibre-ebook.com/signatures/kovid.gpg . Sin scripts remotos ni sudo.

Archivos: ~/.local/kitty.app, enlaces ~/.local/bin/kitty y kitten, ~/.config/kitty/kitty.conf y lanzador ~/.local/share/applications/kitty.desktop. Abrir desde el menú «kitty» o con `kitty`. Para SSH usar `kitten ssh usuario@servidor`: prepara terminfo en el servidor. Este comando puede instalar datos en el HOME remoto; no se conectó automáticamente a ningún servidor. Documentación: https://sw.kovidgoyal.net/kitty/kittens/ssh/ .

El runbook HTML original describe Zsh, Starship, fzf-tab, autosuggestions, completions, syntax highlighting, eza, bat y zoxide. El prompt real actual usa Catppuccin Mocha, distinto del Tokyo Night indicado en el HTML. Se guardó esa configuración en starship.toml y plugins.lock.json; los plugins están incluidos en commits concretos, con sus licencias. La fuente regular y su licencia están en fonts/.

El instalador opcional `python3 extras/terminal/install.py` prepara una shell aislada y un perfil adicional de Konsole («Kessoku Terminal Extra»); ya fue probado dos veces y no reemplaza ~/.zshrc ni Starship personal. No incluye tus inicializadores particulares de fnm/Bun ni credenciales. launch.sh permite abrir esa shell opcional con Konsole o Kitty. Para el uso normal de Kitty, ejecutá simplemente `kitty`, que sí usa tu shell habitual.

No se instaló Alacritty ni Ghostty. alacritty.toml es solo una plantilla preparada antes de decidir usar Kitty.

## Reproducir desde el proyecto

Kitty y su apariencia, conservando tu shell existente:

```bash
python3 extras/terminal/install-kitty.py
```

El instalador descarga solo si falta el archivo, comprueba SHA-256 y firma GPG con la identidad fijada, extrae a un directorio temporal y comprueba conflictos antes de escribir. Instala fuente, configuración, binarios, enlaces y entrada de menú por usuario. Dos ejecuciones consecutivas se probaron sobre la instalación actual; ambas pasaron. Si encuentra una configuración diferente, se detiene y no la reemplaza. Requiere Python 3.12+ (Debian 13 tiene 3.13) y gpgv. La descarga es Linux x86_64.

Para reproducir además el prompt y los plugins del runbook en una shell opcional aislada:

```bash
python3 extras/terminal/install.py
extras/terminal/launch.sh kitty
```

Ese segundo paso requiere las herramientas declaradas por install.py: zsh, starship, fzf, zoxide, eza, batcat, fastfetch y Konsole. Las versiones detectadas al crear el extra fueron Zsh 5.9, Starship 1.26.0, fzf 0.60.3, zoxide 0.9.7, eza 0.21.0, bat 0.25.0 y fastfetch 2.40.4. Las herramientas Debian se obtienen de APT; Starship se obtiene de su publicación oficial (https://github.com/starship/starship/releases/tag/v1.26.0), sin ejecutar scripts descargados directamente. Los plugins ya están incluidos, no se clonan ramas cambiantes. Su procedencia y commits figuran en plugins.lock.json. El historial del extra se guarda aparte en ~/.local/state/kessoku-terminal; los inicializadores personales de fnm/Bun no se copian automáticamente.

`kitty` a secas usa tu shell normal; `launch.sh kitty` usa la copia opcional. Konsole sigue disponible en ambos casos. No se cambian asociaciones predeterminadas ni se hacen conexiones SSH automáticamente.
