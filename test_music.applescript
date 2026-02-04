-- SOLO carpeta de prueba
set basePath to POSIX file "/Volumes/DISK/Musica DJ NACH/" as alias

-- extensiones de audio permitidas
property audioExts : {"mp3", "wav", "aiff", "m4a", "aac"}

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
        set audioFiles to files of fsFolder whose (name extension is "mp3" or name extension is "wav" or name extension is "aiff" or name extension is "m4a" or name extension is "aac")
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
        end repeat
    end if

    -- recursivo para subcarpetas
    repeat with cf in childFolders
        processFolder(cf, thisPlaylistFolder)
    end repeat
end processFolder

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

repeat with f in topFolders
    processFolder(f, rootPlaylistFolder)
end repeat
