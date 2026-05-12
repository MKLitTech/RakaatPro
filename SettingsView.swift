import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject var pm: PrayerManager
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPhotoData") var userPhotoData: Data = Data()
    @AppStorage("adhanEnabled") var adhanEnabled: Bool = true
    @AppStorage("calculationMethod") var calculationMethod: Int = 2
    @AppStorage("liquidGlassEnabled") var liquidGlassEnabled: Bool = false
    @State private var showResetConfirm = false

    // iOS 26 = version 26.0+
    var supportsLiquidGlass: Bool {
        if #available(iOS 26.0, *) { return true }
        return false
    }

    let methods: [(name: String, id: Int)] = [
        ("ISNA — North America", 2),
        ("Muslim World League", 3),
        ("Egyptian Authority", 5),
        ("Umm Al-Qura — Mecca", 4),
        ("Karachi", 1),
        ("Gulf Region", 8),
        ("Kuwait", 9),
        ("Qatar", 10),
        ("Singapore", 11),
        ("Turkey", 13),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {

                    // Header
                    HStack {
                        Text("Settings")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(.white)
                        Spacer()
                        RakatLogo(color: .white.opacity(0.3))
                            .frame(width: 22, height: 27)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                    // Profile
                    settingsSection(title: "PROFILE") {
                        HStack {
                            Text("Name")
                                .settingsLabel()
                            Spacer()
                            Text(userName)
                                .font(.system(size: 16, weight: .light))
                                .foregroundColor(.white.opacity(0.35))
                        }
                    }

                    // Notifications
                    settingsSection(title: "NOTIFICATIONS") {
                        HStack {
                            Text("Adhan alerts")
                                .settingsLabel()
                            Spacer()
                            Toggle("", isOn: $adhanEnabled)
                                .labelsHidden()
                                .tint(.white.opacity(0.65))
                        }
                    }

                    // Appearance — Liquid Glass
                    settingsSection(title: "APPEARANCE") {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Liquid Glass UI")
                                        .settingsLabel()
                                    Text("iOS 26 visual style")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.white.opacity(0.25))
                                }
                                Spacer()
                                Toggle("", isOn: $liquidGlassEnabled)
                                    .labelsHidden()
                                    .tint(.white.opacity(0.65))
                                    .disabled(!supportsLiquidGlass)
                                    .opacity(supportsLiquidGlass ? 1 : 0.35)
                            }

                            if !supportsLiquidGlass {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.white.opacity(0.25))
                                    Text("Your device doesn't support this feature. iOS 26 required.")
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.white.opacity(0.25))
                                }
                                .padding(.top, 2)
                            }
                        }
                    }

                    // Calculation method
                    settingsSection(title: "CALCULATION METHOD") {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(methods.enumerated()), id: \.offset) { i, method in
                                Button {
                                    calculationMethod = method.id
                                    if let coords = pm.currentCoords {
                                        pm.fetchPrayerTimes(lat: coords.latitude, lon: coords.longitude)
                                    }
                                } label: {
                                    HStack {
                                        Text(method.name)
                                            .font(.system(size: 15, weight: .light))
                                            .foregroundColor(calculationMethod == method.id ? .white.opacity(0.9) : .white.opacity(0.38))
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        if calculationMethod == method.id {
                                            Circle().fill(Color.white.opacity(0.8)).frame(width: 6, height: 6)
                                        }
                                    }
                                    .padding(.vertical, 14)
                                }
                                if i < methods.count - 1 {
                                    Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5)
                                }
                            }
                        }
                    }

                    // About
                    settingsSection(title: "ABOUT") {
                        VStack(spacing: 0) {
                            infoRow(label: "Prayer data", value: "AlAdhan.com")
                            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5).padding(.vertical, 4)
                            infoRow(label: "Version", value: "1.0.0")
                            Rectangle().fill(Color.white.opacity(0.06)).frame(height: 0.5).padding(.vertical, 4)
                            HStack {
                                Text("GitHub")
                                    .settingsLabel()
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(.white.opacity(0.25))
                            }
                            .padding(.vertical, 6)
                        }
                    }

                    // Reset
                    Button {
                        showResetConfirm = true
                    } label: {
                        Text("Reset & sign out")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.white.opacity(0.25))
                            .padding(.top, 8)
                    }
                    .confirmationDialog("Reset Rakat Pro?", isPresented: $showResetConfirm) {
                        Button("Reset", role: .destructive) {
                            userName = ""
                            userPhotoData = Data()
                        }
                        Button("Cancel", role: .cancel) {}
                    }

                    // Made with Claude note
                    VStack(spacing: 4) {
                        Text("Made with Claude by Anthropic")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(.white.opacity(0.15))
                        Text("MKLitTech")
                            .font(.system(size: 11, weight: .light))
                            .foregroundColor(.white.opacity(0.1))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.25))
                .padding(.horizontal, 24)

            content()
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.05))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                )
                .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).settingsLabel()
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .light))
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.vertical, 6)
    }
}

extension Text {
    func settingsLabel() -> some View {
        self.font(.system(size: 16, weight: .light))
            .foregroundColor(.white.opacity(0.65))
    }
}
