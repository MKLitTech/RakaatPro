import SwiftUI

@main
struct RakaatProApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootViewSwitcher()
                .environmentObject(appState)
        }
    }
}
