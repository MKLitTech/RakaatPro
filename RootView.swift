import SwiftUI

struct RootView: View {
    @AppStorage("userName") var userName: String = ""

    var body: some View {
        if userName.isEmpty {
            OnboardingView()
        } else {
            MainTabView()
        }
    }
}
