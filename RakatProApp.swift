import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }
}

@main
struct RakatProApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("userName") var userName: String = ""

    var body: some Scene {
        WindowGroup {
            Group {
                if userName.isEmpty {
                    OnboardingView()
                } else {
                    MainTabView()
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
