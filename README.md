# FOLDER_TO_ITUNES

Convierte una jerarquia de carpetas en disco en carpetas y playlists dentro de la app Music (macOS).

**Requisitos**
- macOS con la app Music
- Permisos de automatizacion para `osascript`, `Music` y `System Events`

**Uso**
```bash
osascript test_music.applescript "/ruta/a/tu/carpeta"
```

**App visual (SwiftUI)**
```bash
swift run FolderToItunesApp
```
Luego selecciona la carpeta en la interfaz y pulsa **Crear playlists**.

**Generar app (.app)**
```bash
./scripts/make_app.sh
```
La app queda en `dist/FolderToItunesApp.app`.

**Que hace**
- Crea una carpeta raiz en Music con el nombre de la carpeta base.
- Para cada subcarpeta, crea una carpeta de playlists.
- Dentro de cada carpeta, crea una playlist con los audios de esa carpeta.
- Recorre subcarpetas de forma recursiva y mantiene la jerarquia.

**Formatos soportados**
- `mp3`, `wav`, `aiff`, `m4a`, `aac`

**Notas**
- Si una carpeta no tiene audios, solo se crea su carpeta de playlists.
- Si la playlist ya existe, se reutiliza.
