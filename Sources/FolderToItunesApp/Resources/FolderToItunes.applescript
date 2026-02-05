-- extensiones de audio permitidas
property audioExts : {"mp3", "wav", "aiff", "m4a", "aac"}
property progressDone : 0

on emitLine(msg)
    log msg
end emitLine

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
        set matches to (every user playlist of parentFolder whose name is playlistName)
        if (count of matches) > 0 then
            return item 1 of matches
        else
            return make new user playlist at parentFolder with properties {name:playlistName}
        end if
    end tell
end ensurePlaylist

on splitLine(theLine)
    set AppleScript's text item delimiters to tab
    set parts to text items of theLine
    set AppleScript's text item delimiters to ""
    return parts
end splitLine

on indexOfPath(thePath, pathList)
    repeat with i from 1 to (count of pathList)
        if item i of pathList is thePath then return i
    end repeat
    return 0
end indexOfPath

on folderPlaylistForPath(thePath, pathList, folderList)
    set idx to indexOfPath(thePath, pathList)
    if idx is 0 then return missing value
    return item idx of folderList
end folderPlaylistForPath

on playlistForPath(thePath, playlistPaths, playlistList)
    set idx to indexOfPath(thePath, playlistPaths)
    if idx is 0 then return missing value
    return item idx of playlistList
end playlistForPath

on buildFromManifest(manifestPath)
    set fileText to read file (POSIX file manifestPath) as «class utf8»
    set theLines to paragraphs of fileText

    set folderPaths to {}
    set folderPlaylists to {}
    set playlistPaths to {}
    set playlists to {}

    set totalFiles to 0
    repeat with ln in theLines
        if ln starts with "FILE" & tab then set totalFiles to totalFiles + 1
    end repeat
    emitLine("FILE_TOTAL=" & totalFiles)
    emitLine("INFO=Total de archivos detectados: " & totalFiles)

    repeat with ln in theLines
        if ln starts with "DIR" & tab then
            set parts to splitLine(ln)
            if (count of parts) ≥ 3 then
                set dirPath to item 2 of parts
                set parentPath to item 3 of parts
                set parentFolder to missing value
                if parentPath is not "" then
                    set parentFolder to folderPlaylistForPath(parentPath, folderPaths, folderPlaylists)
                end if
                set folderName to do shell script "basename " & quoted form of dirPath
                set thisFolder to ensurePlaylistFolder(folderName, parentFolder)
                set end of folderPaths to dirPath
                set end of folderPlaylists to thisFolder
            end if
        end if
    end repeat

    repeat with ln in theLines
        if ln starts with "FILE" & tab then
            set parts to splitLine(ln)
            if (count of parts) ≥ 3 then
                set filePath to item 2 of parts
                set parentPath to item 3 of parts
                set parentFolder to folderPlaylistForPath(parentPath, folderPaths, folderPlaylists)
                if parentFolder is missing value then
                    emitLine("WARN=No se encontro carpeta para: " & parentPath)
                else
                    set p to playlistForPath(parentPath, playlistPaths, playlists)
                    if p is missing value then
                        set folderName to do shell script "basename " & quoted form of parentPath
                        set p to ensurePlaylist(folderName, parentFolder)
                        set end of playlistPaths to parentPath
                        set end of playlists to p
                        emitLine("INFO=Playlist creada: " & folderName)
                    end if
                    try
                        set fileAlias to (POSIX file filePath) as alias
                        tell application "Music" to add fileAlias to p
                    on error errMsg
                        emitLine("WARN_ADD=" & filePath & " :: " & errMsg)
                    end try
                    set progressDone to progressDone + 1
                    emitLine("FILE_DONE=" & progressDone)
                end if
            end if
        end if
    end repeat
end buildFromManifest

on run argv
    if (count of argv) < 1 then
        error "Usage: osascript FolderToItunes.applescript \"/ruta/a/carpeta\""
    end if

    if (count of argv) < 2 then
        error "Usage: osascript FolderToItunes.applescript \"/ruta/a/carpeta\" \"/ruta/a/manifest\""
    end if

    set basePath to item 1 of argv
    set manifestPath to item 2 of argv

    emitLine("INFO=Inicio de importacion")
    emitLine("INFO=Ruta base: " & basePath)
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

    set progressDone to 0
    buildFromManifest(manifestPath)

    emitLine("INFO=Importacion completada correctamente.")
end run
