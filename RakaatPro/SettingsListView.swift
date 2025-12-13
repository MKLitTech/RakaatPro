import SwiftUI

struct SettingsListView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @AppStorage("firstName") private var storedFirstName: String = ""
    @AppStorage("lastName") private var storedLastName: String = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink("Change Account Info") {
                        SettingsView()
                    }
                }
                .listStyle(InsetGroupedListStyle())

                Divider()

                // Reset button at bottom (debug only)
                #if DEBUG
                Button(role: .destructive) {
                    showResetAlert = true
                } label: {
                    Text("RESET MODE (DEV ONLY)")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .foregroundColor(.red)
                .padding(.horizontal)
                .padding(.bottom, 12)
                #endif
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("ARE YOU SURE YOU WANT TO RESET THE APP?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    storedFirstName = ""
                    storedLastName = ""
                    profileImageData = nil

                    dismiss()

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        appState.requestReset()
                    }
                }
            }
        }
    }
}
