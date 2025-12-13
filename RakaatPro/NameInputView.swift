import SwiftUI
import PhotosUI

struct NameInputView: View {
    @EnvironmentObject private var appState: AppState

    @AppStorage("firstName") private var storedFirstName: String = ""
    @AppStorage("lastName") private var storedLastName: String = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Welcome to RakaatPro!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 40)

                // PhotosPicker button that shows current stored image if present
                PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                    if let data = profileImageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                }
                .onChange(of: photoItem) { newItem in
                    Task {
                        guard let item = newItem else { return }
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            profileImageData = data
                        }
                    }
                }

                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color(.darkGray))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    TextField("Last Name (Optional)", text: $lastName)
                        .padding()
                        .background(Color(.darkGray))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)

                Button(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Continue as Guest" : "Continue") {
                    if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        storedFirstName = "User"
                        storedLastName = ""
                    } else {
                        storedFirstName = firstName
                        storedLastName = lastName
                    }

                    // animate the root swap explicitly
                    withAnimation(.easeInOut(duration: 0.9)) {
                        appState.completeOnboarding()
                    }
                    HapticsManager.success()
                }
                .buttonStyle(.borderedProminent)
                .tint(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.75) : Color.blue)
                .foregroundColor(.white)
                .padding(.top, 20)

                Spacer()
            }
        }
    }
}
