# Folder to Music

**Folder to Music** es una app macOS que convierte una jerarquía de carpetas en **carpetas y playlists** dentro de la app Music. Está pensada para uso profesional: rápida, clara y con control total del proceso.

## Requisitos
- macOS con la app Music
- Permisos de automatización para `Music` y `System Events`

## Uso rápido
1. Abre la app.
2. Selecciona una carpeta base.
3. Pulsa **Crear playlists**.

## Acción en Rekordbox 6/7 (después de crear playlists)
1. Abre Rekordbox.
2. Asegúrate de tener visible la librería de Music/iTunes en el panel izquierdo (si no aparece, actívala en Preferencias/Settings).
3. Busca la **carpeta raíz** que creó la app dentro de la librería de Music/iTunes y expándela para ver sus playlists.
4. Selecciona las playlists y arrástralas a **Colección** para importarlas.
5. Ejecuta el análisis de pistas (BPM/Key) si Rekordbox no lo hizo automáticamente.

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
- **Vista previa**: muestra la jerarquía de carpetas antes de crear playlists y exige confirmación.

**Secciones principales:**
- **Salida (log)**: muestra el registro en tiempo real de la ejecución.
- **Carpeta fuente**:
  - **Elegir carpeta**: selecciona la carpeta base a importar.
  - **Quitar carpeta**: limpia la selección y reinicia la vista previa.
- **Vista previa**:
  - **Generar/Actualizar**: crea un árbol de lo que se importará.
  - **Confirmar**: habilita el botón de creación.
- **Importación**:
  - **Crear playlists**: inicia la importación.
  - **Cancelar**: detiene el proceso actual de la app.
- **Progreso**:
  - Barra de progreso por archivo.
  - Porcentaje, tiempo y volumen de Music (si está disponible).

## Interfaz detallada (elemento por elemento)
- **Título de la app**: identifica la herramienta en pantalla.
- **Selector de idioma**: alterna todos los textos de la interfaz entre idiomas EU/US.
- **Modo claro/oscuro**: cambia la apariencia general sin afectar el funcionamiento.
- **Indicador de ejecución (chip "Running")**: aparece cuando el proceso está activo.
- **Barra de pasos (1-3)**:
  - **Paso 1**: seleccionar carpeta.
  - **Paso 2**: revisar vista previa.
  - **Paso 3**: creación y progreso.
- **Estado**: texto corto que resume en qué fase está la app.
- **Tarjeta Salida (log)**:
  - **Área de texto**: muestra mensajes del script en tiempo real.
  - **Borrar**: limpia el log.
  - **Copiar**: copia el log al portapapeles.
- **Tarjeta Carpeta fuente**:
  - **Elegir carpeta**: abre el selector de carpeta base.
  - **Ruta seleccionada**: muestra la ruta actual.
  - **Quitar carpeta**: reinicia la selección y la vista previa.
- **Tarjeta Vista previa**:
  - **Generar/Actualizar**: construye el árbol de carpetas.
  - **Árbol de vista previa**: muestra exactamente lo que se importará.
  - **Confirmar**: habilita la creación cuando el usuario valida la vista previa.
- **Tarjeta Importación**:
  - **Crear playlists**: ejecuta el script de importación.
  - **Cancelar**: detiene la ejecución en curso.
  - **Spinner**: indica actividad mientras corre el script.
- **Tarjeta Progreso**:
  - **Barra/porcentaje**: progreso por archivo.
  - **Tiempo**: tiempo transcurrido y total cuando finaliza.
  - **Volumen de Music**: muestra volumen si está disponible.
- **Footer**:
  - **Versión y build**: ayuda a identificar el build exacto.
  - **Matar procesos**: corta cualquier `osascript` activo si algo se bloquea.

**Acción avanzada (discreta en el footer):**
- **Matar procesos**: detiene todos los procesos `osascript` que estén ejecutando el script de importación. Es una acción de seguridad en caso de bloqueo.

## Nueva interfaz de Rekordbox (referencia)
- **Parte superior**: dos decks con controles de sincronía, transporte y estado de carga.
- **Zona central**: pads de performance y botones de stems (**Vocal**, **Inst**, **Drums**) para silenciar/aislar partes.
- **Parte inferior**: navegador con columnas (título, artista, BPM, etc.) y búsqueda.
- **Panel izquierdo**: fuentes y filtros (Colección, Género, Artista, Álbum).

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
