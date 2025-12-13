import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var hasOnboarded: Bool {
        didSet { UserDefaults.standard.set(hasOnboarded, forKey: "hasOnboarded") }
    }
    @Published var resetRequested: Bool = false

    init() {
        self.hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")
    }

    func requestReset() {
        resetRequested = true
    }

    func completeReset() {
        hasOnboarded = false
        resetRequested = false
    }

    func completeOnboarding() {
        hasOnboarded = true
    }
}
