import SwiftUI
import AppKit

@main
struct FolderToItunesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 520, minHeight: 360)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @State private var selectedURL: URL?
    @State private var isRunning = false
    @State private var logText = "Selecciona una carpeta para comenzar."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Folder to Music")
                .font(.system(size: 24, weight: .bold))

            Text("Convierte la jerarquia de carpetas en carpetas y playlists dentro de Music.")
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button("Elegir carpeta") {
                    pickFolder()
                }

                if let selectedURL {
                    Text(selectedURL.path)
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                } else {
                    Text("Ninguna carpeta seleccionada")
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button(isRunning ? "Ejecutando..." : "Crear playlists") {
                    runScript()
                }
                .disabled(isRunning || selectedURL == nil)

                if isRunning {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }

            Text("Salida")
                .font(.system(size: 13, weight: .semibold))

            ScrollView {
                Text(logText)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(nsColor: .textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                    )
            }
        }
        .padding(20)
    }

    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Seleccionar"

        if panel.runModal() == .OK {
            selectedURL = panel.url
            logText = "Carpeta seleccionada: \(selectedURL?.path ?? "")"
        }
    }

    private func runScript() {
        guard let selectedURL else {
            logText = "Selecciona una carpeta primero."
            return
        }

        guard let scriptURL = Bundle.module.url(forResource: "FolderToItunes", withExtension: "applescript") else {
            logText = "No se encontro el script AppleScript en los recursos."
            return
        }

        isRunning = true
        logText = "Ejecutando AppleScript..."

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = [scriptURL.path, selectedURL.path]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        task.terminationHandler = { _ in
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8) ?? ""

            DispatchQueue.main.async {
                isRunning = false
                if !error.isEmpty {
                    logText = "Error:\n\(error)"
                } else if !output.isEmpty {
                    logText = output
                } else {
                    logText = "Listo. Revisa Music para ver las playlists."
                }
            }
        }

        do {
            try task.run()
        } catch {
            isRunning = false
            logText = "No se pudo ejecutar osascript: \(error.localizedDescription)"
        }
    }
}
