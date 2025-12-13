import SwiftUI
import PhotosUI

struct SettingsView: View {
    @AppStorage("firstName") private var storedFirstName: String = ""
    @AppStorage("lastName") private var storedLastName: String = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var showPhotoPicker = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 25) {
                // Headline changed
                Text("Change Account Info")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)

                // Profile picture with pencil overlay
                Button {
                    HapticsManager.tap()
                    showPhotoPicker = true
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        if let data = profileImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
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

                            // Pencil icon overlay (default image only)
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)
                                .background(Color.black.clipShape(Circle()))
                                .offset(x: -6, y: -6)
                        }
                    }
                }
                .padding(.bottom, 10)

                // Name fields
                VStack(spacing: 16) {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color(.darkGray))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .onChange(of: firstName) {
                            HapticsManager.typing()
                        }

                    TextField("Last Name (Optional)", text: $lastName)
                        .padding()
                        .background(Color(.darkGray))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .onChange(of: lastName) {
                            HapticsManager.typing()
                        }
                }
                .padding(.horizontal, 20)

                // Save button
                Button("Save Changes") {
                    HapticsManager.success()
                    storedFirstName = firstName
                    storedLastName = lastName
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .foregroundColor(.white)
                .padding(.top, 20)

                Spacer()

                // Disclaimer
                Text("RakaatPro Does Not Upload Any Data Or Images.\nAll data is saved on device. If App is deleted all local data will be deleted too!")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }
        }
        .onAppear {
            // Pre-fill fields with stored values
            firstName = storedFirstName
            lastName = storedLastName
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: Binding(
            get: { nil },
            set: { newItem in
                if let newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            profileImageData = data
                        }
                    }
                }
            }
        ))
    }
}
