# Reescalado del fondo

Upscayl 2.15.0, publicación oficial: https://github.com/upscayl/upscayl/releases/tag/v2.15.0 . AppImage guardada en downloads/; SHA-512 comparado con latest-linux.yml publicado por el proyecto:

`XT1gvx4kl2JVjwiVIRGT58PTAZwYUlD1oAT2N6vAEiERVdNrfbr/hzZ94EqaETL32T3p8U6EMpGpXGoGkoFVYg==`

Se extrajo la AppImage a tools/upscayl-2.15.0 para ejecutar su motor oficial upscayl-bin. Vulkan detectó la RTX 3050 como GPU 1. No se instalaron paquetes del sistema ni se cambiaron controladores. El acceso «Upscayl» del menú usa la AppImage con --disable-setuid-sandbox; no se desactiva el sandbox completo con --no-sandbox. La aplicación arrancó y detectó la versión/GPU; se verificó el procesamiento con el motor incluido.

Se compararon Digital Art y High Fidelity a 4×. Digital Art simplificó las texturas del amplificador; se eligió High Fidelity por conservarlas mejor. Salida del modelo: 6688×3764. Se redujo con Lanczos y ajuste central mínimo a 3840×2160 y 2560×1440. Es detalle reconstruido por IA, no una imagen generada originalmente a 4K.

Aplicado: ~/Pictures/Wallpapers/Kessoku/kessoku-stage-4k.png. Alternativa QHD: kessoku-stage-qhd.png. Original conservado: kessoku-stage.png. Variantes Digital Art en assets/wallpapers/variants/. Comparación de detalle: assets/previews/upscale-comparison.png (izquierda interpolación del original; derecha High Fidelity).

Para otra imagen:

`scripts/upscale-image.sh /ruta/entrada.png /ruta/prefijo 1`

Genera prefijo-ai4x.png, prefijo-4k.png y prefijo-qhd.png y se niega a reemplazar archivos existentes. Verifica hashes del motor y del modelo, derivados de la AppImage verificada. GPU 1 corresponde a esta sesión; consultar vulkaninfo si cambia el equipo.

Para volver al fondo original: `plasma-apply-wallpaperimage "$HOME/Pictures/Wallpapers/Kessoku/kessoku-stage.png"`. Los scripts apply/install/validate usan ahora la versión 4K. El rollback completo sigue restaurando el escritorio anterior al proyecto.

La aplicación es local. Su retirada manual consiste en quitar el acceso ~/.local/share/applications/org.upscayl.kessoku.desktop y los archivos propios de Upscayl bajo downloads/ y tools/ cuando ya no se necesiten; no se requiere eliminar paquetes ni imágenes. El script de reescalado necesita esos recursos.
