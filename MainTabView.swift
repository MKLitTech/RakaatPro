import SwiftUI

struct MainTabView: View {
    @StateObject var prayerManager = PrayerManager()
    @AppStorage("liquidGlassEnabled") var liquidGlassEnabled: Bool = false

    var body: some View {
        TabView {
            PrayersView()
                .tabItem {
                    Label("Prayers", systemImage: "square.grid.2x2")
                }
            QiblaView()
                .tabItem {
                    Label("Qibla", systemImage: "circle.dotted")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "line.3.horizontal")
                }
        }
        .environmentObject(prayerManager)
        .preferredColorScheme(.dark)
        .onAppear { prayerManager.requestLocation() }
    }
}
