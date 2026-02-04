import SwiftUI

@main
struct FolderToItunesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, idealWidth: 800, minHeight: 800, idealHeight: 800)
        }
        .windowResizability(.automatic)
    }
}
