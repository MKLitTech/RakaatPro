import SwiftUI

struct RootViewSwitcher: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("firstName") private var storedFirstName: String = ""

    var body: some View {
        ZStack {
            if !appState.hasOnboarded || storedFirstName.isEmpty {
                NameInputView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                WelcomeView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        // Avoid global animation that conflicts with explicit withAnimation calls
    }
}
