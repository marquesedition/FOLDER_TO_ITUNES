# FOLDER_TO_ITUNES

AppleScript para crear carpetas y playlists en Music a partir de la jerarquia de carpetas en disco.

**Uso**
1. Ajusta `basePath` en `test_music.applescript` con la ruta de tu carpeta raiz.
2. Ejecuta:

```bash
osascript test_music.applescript
```

**Notas**
- Se crea una carpeta raiz en Music con el nombre de la carpeta base.
- Se crea una carpeta de playlists por cada subcarpeta.
- Dentro de cada carpeta se crea una playlist con los audios de esa carpeta.
