# FOLDER_TO_ITUNES

AppleScript para crear carpetas y playlists en Music a partir de la jerarquia de carpetas en disco.

**Uso**
1. Ejecuta pasando la ruta base como argumento:

```bash
osascript test_music.applescript "/Volumes/DISK/Musica DJ NACH/Bass Music"
```

**Notas**
- Se crea una carpeta raiz en Music con el nombre de la carpeta base.
- Se crea una carpeta de playlists por cada subcarpeta.
- Dentro de cada carpeta se crea una playlist con los audios de esa carpeta.
