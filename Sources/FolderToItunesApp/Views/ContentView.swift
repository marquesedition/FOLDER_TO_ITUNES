import SwiftUI
import AppKit

// Main screen that orchestrates user flow, script execution, and UI state.
struct ContentView: View {
    // MARK: - UI State
    @State private var selectedURL: URL?
    @State private var isRunning = false
    @State private var logText: String
    @State private var progressCurrent = 0
    @State private var progressTotal = 0
    @State private var volumeValue: Int?
    @State private var volumeStatus: String?
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @State private var runningTask: Process?
    @State private var prefersDark = true
    @State private var selectedLanguage = "Español"

    private let buildStamp = "Build 2026-02-04 23:49"
    private let appVersion = "v1.0.0"

    private var strings: AppStrings { AppStrings(language: selectedLanguage) }

    init() {
        _logText = State(initialValue: AppStrings.defaultLogText)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                Color(nsColor: .windowBackgroundColor)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        headerRow

                        Text(strings.text("subtitle"))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        StepBar(
                            current: currentStep(),
                            step1: strings.text("step1"),
                            step2: strings.text("step2"),
                            step3: strings.text("step3")
                        )

                        Text(statusText())
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)

                        VStack(spacing: 12) {
                            outputCard
                            sourceCard
                            importCard
                            progressCard
                        }

                        footerRow
                    }
                    .padding(20)
                    .frame(maxWidth: min(680, max(320, geo.size.width - 40)))
                    .frame(maxWidth: .infinity, alignment: .top)
                }

                Image("watermark", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .opacity(0.08)
                    .padding(16)
                    .allowsHitTesting(false)
            }
            .preferredColorScheme(prefersDark ? .dark : .light)
        }
    }

    // MARK: - Header / Footer

    private var headerRow: some View {
        HStack {
            Picker(strings.text("language"), selection: $selectedLanguage) {
                ForEach(AppStrings.availableLanguages, id: \.self) { lang in
                    Text(lang).tag(lang)
                }
            }
            .pickerStyle(.menu)
            .controlSize(.small)

            Text(strings.text("title"))
                .font(.system(size: 22, weight: .semibold))

            Spacer()

            if isRunning {
                Text(strings.text("running"))
                    .font(.system(size: 11, weight: .semibold))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.primary.opacity(0.08))
                    .clipShape(Capsule())
            }

            Toggle(prefersDark ? strings.text("dark_mode") : strings.text("light_mode"), isOn: $prefersDark)
                .toggleStyle(.switch)
        }
    }

    private var footerRow: some View {
        HStack {
            Text(strings.text("footer"))
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Text("· \(appVersion) · \(buildStamp)")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
            Button(strings.text("kill_processes")) {
                killAllScriptProcesses()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .opacity(0.6)
            Spacer()
        }
    }

    // MARK: - Cards

    private var outputCard: some View {
        CardView(icon: "terminal.fill", accent: .orange, title: strings.text("output_title"), subtitle: strings.text("output_subtitle")) {
            ScrollView {
                Text(logText)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .frame(minHeight: 130)
        }
    }

    private var sourceCard: some View {
        CardView(icon: "folder.fill", accent: .blue, title: strings.text("source_title"), subtitle: selectedURL?.path ?? strings.text("source_subtitle")) {
            Button(strings.text("choose_folder")) {
                pickFolder()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private var importCard: some View {
        CardView(icon: "play.fill", accent: .green, title: strings.text("import_title"), subtitle: isRunning ? strings.text("import_subtitle_running") : strings.text("import_subtitle_idle")) {
            HStack(spacing: 10) {
                Button(isRunning ? strings.text("running_button") : strings.text("create_playlists")) {
                    runScript()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isRunning || selectedURL == nil)

                Button(strings.text("cancel")) {
                    cancelScript()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(!isRunning)

                if isRunning {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
    }

    private var progressCard: some View {
        CardView(icon: "chart.bar.fill", accent: .purple, title: strings.text("progress_title"), subtitle: progressTotal > 0 ? strings.text("progress_subtitle_busy") : strings.text("progress_subtitle_idle")) {
            VStack(alignment: .leading, spacing: 6) {
                if progressTotal > 0 {
                    ProgressView(value: Double(progressCurrent), total: Double(progressTotal))
                    Text(String(format: strings.text("progress_line"), progressCurrent, progressTotal, percentText(), elapsedText()))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else if isRunning {
                    Text(strings.text("progress_preparing"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else {
                    Text(strings.text("progress_ready"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                if let volumeValue {
                    Text(String(format: strings.text("volume"), volumeValue))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                } else if isRunning, let volumeStatus {
                    Text(volumeStatus)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - File Picking

    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = strings.text("panel_select")

        if panel.runModal() == .OK {
            selectedURL = panel.url
            logText = String(format: strings.text("log_folder_selected"), selectedURL?.path ?? "")
        }
    }

    // MARK: - Script Execution

    private func runScript() {
        guard let selectedURL else {
            logText = strings.text("log_select_first")
            return
        }

        guard let scriptURL = Bundle.module.url(forResource: "FolderToItunes", withExtension: "applescript") else {
            logText = strings.text("log_missing_script")
            return
        }

        isRunning = true
        progressCurrent = 0
        progressTotal = 0
        volumeValue = nil
        volumeStatus = strings.text("volume_determining")
        elapsedSeconds = 0
        startTimer()
        logText = strings.text("log_running")

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = [scriptURL.path, selectedURL.path]
        runningTask = task

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe

        var outputBuffer = Data()
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty { return }
            outputBuffer.append(data)
            consumeLines(from: &outputBuffer, isError: false)
        }

        var errorBuffer = Data()
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if data.isEmpty { return }
            errorBuffer.append(data)
            consumeLines(from: &errorBuffer, isError: true)
        }

        task.terminationHandler = { _ in
            DispatchQueue.main.async {
                outputPipe.fileHandleForReading.readabilityHandler = nil
                errorPipe.fileHandleForReading.readabilityHandler = nil
                stopTimer()
                isRunning = false
                runningTask = nil
                if logText.hasPrefix("Error:") {
                    return
                }
                if logText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    logText = strings.text("log_done")
                }
            }
        }

        do {
            try task.run()
        } catch {
            isRunning = false
            stopTimer()
            runningTask = nil
            logText = String(format: strings.text("log_osascript_failed"), error.localizedDescription)
        }
    }

    private func cancelScript() {
        guard isRunning else { return }
        runningTask?.terminate()
        runningTask = nil
        isRunning = false
        stopTimer()
        logText = strings.text("log_canceled") + "\n" + logText
    }

    private func killAllScriptProcesses() {
        let killer = Process()
        killer.executableURL = URL(fileURLWithPath: "/usr/bin/pkill")
        killer.arguments = ["-f", "osascript.*FolderToItunes.applescript"]

        do {
            try killer.run()
            logText = strings.text("log_processes_killed") + "\n" + logText
        } catch {
            logText = String(format: strings.text("log_kill_failed"), error.localizedDescription) + "\n" + logText
        }
    }

    // MARK: - Output Parsing

    private func consumeLines(from buffer: inout Data, isError: Bool) {
        let newline = Data([0x0A])
        while let range = buffer.range(of: newline) {
            let lineData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
            buffer.removeSubrange(buffer.startIndex..<range.upperBound)
            let line = String(data: lineData, encoding: .utf8) ?? ""
            DispatchQueue.main.async {
                handleLine(line, isError: isError)
            }
        }
    }

    private func handleLine(_ line: String, isError: Bool) {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return }

        if trimmed.hasPrefix("FILE_TOTAL=") {
            let value = trimmed.replacingOccurrences(of: "FILE_TOTAL=", with: "")
            if let total = Int(value) {
                progressTotal = total
                progressCurrent = 0
            }
        } else if trimmed.hasPrefix("FILE_DONE=") {
            let value = trimmed.replacingOccurrences(of: "FILE_DONE=", with: "")
            if let done = Int(value) {
                progressCurrent = done
            }
        } else if trimmed.hasPrefix("VOLUME_CURRENT=") {
            let value = trimmed.replacingOccurrences(of: "VOLUME_CURRENT=", with: "")
            if let volume = Int(value) {
                volumeValue = volume
                volumeStatus = nil
            }
        } else if trimmed.hasPrefix("WARN=") {
            volumeStatus = strings.text("volume_unavailable")
        }

        let prefix = isError ? "Error: " : ""
        logText = "\(prefix)\(trimmed)\n" + logText
    }

    // MARK: - Timing & Status

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func currentStep() -> Int {
        if isRunning { return 3 }
        if progressTotal > 0, progressCurrent >= progressTotal { return 3 }
        if selectedURL != nil { return 2 }
        return 1
    }

    private func statusText() -> String {
        if isRunning { return strings.text("status_importing") }
        if progressTotal > 0, progressCurrent >= progressTotal { return strings.text("status_done") }
        return strings.text("status_ready")
    }

    private func percentText() -> String {
        guard progressTotal > 0 else { return "0%" }
        let pct = Int((Double(progressCurrent) / Double(progressTotal)) * 100.0)
        return "\(pct)%"
    }

    private func elapsedText() -> String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: strings.text("elapsed"), minutes, seconds)
    }
}
