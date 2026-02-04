-- extensiones de audio permitidas
property audioExts : {"mp3", "wav", "aiff", "m4a", "aac"}
property progressDone : 0

on emitLine(msg)
    do shell script "printf " & quoted form of (msg & "\n")
end emitLine

on countAudioFiles(fsFolder)
    tell application "System Events"
        set audioFiles to files of fsFolder whose name extension is in audioExts
        set childFolders to folders of fsFolder
    end tell

    set total to (count of audioFiles)
    repeat with cf in childFolders
        set total to total + (countAudioFiles(cf))
    end repeat
    return total
end countAudioFiles

-- devuelve el ultimo componente del path como nombre de carpeta
on folderNameFromAlias(a)
    tell application "System Events" to set n to name of a
    return n
end folderNameFromAlias

-- obtiene o crea una carpeta de playlists dentro de parentFolder
on ensurePlaylistFolder(folderName, parentFolder)
    tell application "Music"
        if parentFolder is missing value then
            set matches to (every folder playlist whose name is folderName)
            if (count of matches) > 0 then
                return item 1 of matches
            else
                return make new folder playlist with properties {name:folderName}
            end if
        else
            set matches to (every folder playlist of parentFolder whose name is folderName)
            if (count of matches) > 0 then
                return item 1 of matches
            else
                return make new folder playlist at parentFolder with properties {name:folderName}
            end if
        end if
    end tell
end ensurePlaylistFolder

-- obtiene o crea una playlist dentro de parentFolder
on ensurePlaylist(playlistName, parentFolder)
    tell application "Music"
        set matches to (every playlist of parentFolder whose name is playlistName)
        if (count of matches) > 0 then
            return item 1 of matches
        else
            return make new playlist at parentFolder with properties {name:playlistName}
        end if
    end tell
end ensurePlaylist

-- procesa una carpeta del disco y refleja jerarquia
on processFolder(fsFolder, parentPlaylistFolder)
    tell application "System Events"
        set folderName to name of fsFolder
        set audioFiles to files of fsFolder whose name extension is in audioExts
        set childFolders to folders of fsFolder
    end tell

    -- crear carpeta de playlists para esta carpeta del disco
    set thisPlaylistFolder to ensurePlaylistFolder(folderName, parentPlaylistFolder)

    -- crear playlist para los archivos de audio directamente en esta carpeta
    if (count of audioFiles) > 0 then
        set p to ensurePlaylist(folderName, thisPlaylistFolder)
        repeat with af in audioFiles
            try
                tell application "Music" to add (POSIX path of (af as alias)) to p
            end try
            set progressDone to progressDone + 1
            emitLine("FILE_DONE=" & progressDone)
        end repeat
    end if

    -- recursivo para subcarpetas
    repeat with cf in childFolders
        processFolder(cf, thisPlaylistFolder)
    end repeat
end processFolder

on run argv
    if (count of argv) < 1 then
        error "Usage: osascript FolderToItunes.applescript \"/ruta/a/carpeta\""
    end if

    set basePath to POSIX file (item 1 of argv) as alias

    emitLine("INFO=Determinando volumen de Music...")
    try
        tell application "Music" to set currentVolume to sound volume
        emitLine("VOLUME_CURRENT=" & currentVolume)
    on error errMsg
        emitLine("WARN=No se pudo leer volumen: " & errMsg)
    end try

    tell application "Music"
        activate
    end tell

    -- carpeta raiz en Music con el nombre de la carpeta base
    set rootName to folderNameFromAlias(basePath)
    set rootPlaylistFolder to ensurePlaylistFolder(rootName, missing value)

    -- procesar subcarpetas directas de la carpeta base
    tell application "System Events"
        set topFolders to folders of basePath
    end tell

    set progressDone to 0
    set totalFiles to 0
    repeat with f in topFolders
        set totalFiles to totalFiles + (countAudioFiles(f))
    end repeat
    emitLine("FILE_TOTAL=" & totalFiles)

    repeat with f in topFolders
        processFolder(f, rootPlaylistFolder)
    end repeat

    emitLine("INFO=Importacion completada correctamente.")
end run
