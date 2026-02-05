# Folder to Music

**Folder to Music** es una app macOS que convierte una jerarquía de carpetas en **carpetas y playlists** dentro de la app Music. Está pensada para uso profesional: rápida, clara y con control total del proceso.

## Requisitos
- macOS con la app Music
- Permisos de automatización para `Music` y `System Events`

## Uso rápido
1. Abre la app.
2. Selecciona una carpeta base.
3. Pulsa **Crear playlists**.

## Funcionalidad comercial (qué hace)
- Crea una **carpeta raíz** en Music con el nombre de la carpeta base.
- Para cada subcarpeta, crea una **carpeta de playlists**.
- Dentro de cada carpeta, crea una **playlist** con los audios de esa carpeta.
- Recorre subcarpetas de forma **recursiva** y mantiene la jerarquía.
- Muestra **progreso por archivo**, tiempo transcurrido y estado general.

## Interfaz y botones
- **Selector de idioma**: cambia toda la interfaz entre idiomas EU/US.
- **Modo claro/oscuro**: switch nativo estilo Apple.
- **Barra de pasos**: guía el flujo en 3 pasos (selección, creación, progreso).
- **Estado**: indica si está listo, importando o finalizado.

**Secciones principales:**
- **Salida (log)**: muestra el registro en tiempo real de la ejecución.
- **Carpeta fuente**:
  - **Elegir carpeta**: selecciona la carpeta base a importar.
- **Importación**:
  - **Crear playlists**: inicia la importación.
  - **Cancelar**: detiene el proceso actual de la app.
- **Progreso**:
  - Barra de progreso por archivo.
  - Porcentaje, tiempo y volumen de Music (si está disponible).

**Acción avanzada (discreta en el footer):**
- **Matar procesos**: detiene todos los procesos `osascript` que estén ejecutando el script de importación. Es una acción de seguridad en caso de bloqueo.

## Generar app (.app)
```bash
./scripts/make_app.sh
```
La app queda en `dist/FolderToItunesApp.app`.

## Artifact DMG (CI)
El workflow de GitHub Actions genera un `.dmg` descargable cuando se abre un PR hacia `develop`.

## Formatos soportados
- `mp3`, `wav`, `aiff`, `m4a`, `aac`

## Notas
- Si una carpeta no tiene audios, solo se crea su carpeta de playlists.
- Si la playlist ya existe, se reutiliza.
