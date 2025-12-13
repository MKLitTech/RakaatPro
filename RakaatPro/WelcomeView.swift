import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("firstName") private var storedFirstName: String = ""
    @AppStorage("profileImageData") private var profileImageData: Data?

    @State private var showSettings = false
    @State private var uiImage: UIImage? = nil
    @State private var animateToCorner = false

    @Namespace private var animationNamespace

    private var firstNameDisplay: String { storedFirstName.isEmpty ? "User" : storedFirstName }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()

                if !animateToCorner {
                    // Initial centered layout
                    VStack(spacing: 16) {
                        profileImageView
                            .matchedGeometryEffect(id: "pfp", in: animationNamespace)
                            .frame(width: 120, height: 120)

                        VStack(spacing: 6) {
                            Text("Assalamu Alaikum,")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "greeting", in: animationNamespace)

                            Text(firstNameDisplay)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "name", in: animationNamespace)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    // Final top-left layout
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 12) {
                            profileImageView
                                .matchedGeometryEffect(id: "pfp", in: animationNamespace)
                                .frame(width: 60, height: 60) // shrinks but stays tall relative to text

                            Text("Assalamu Alaikum,")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "greeting", in: animationNamespace)
                        }

                        HStack(spacing: 12) {
                            profileImageView
                                .matchedGeometryEffect(id: "pfp", in: animationNamespace)
                                .frame(width: 60, height: 60)

                            Text(firstNameDisplay)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "name", in: animationNamespace)
                        }
                    }
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                // Settings button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            HapticsManager.tap()
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
            .onAppear {
                if let data = profileImageData, let img = UIImage(data: data) {
                    uiImage = img
                }
                // Trigger the animation after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.85)) {
                        animateToCorner = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsListView()
                    .environmentObject(appState)
            }
        }
    }

    private var profileImageView: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
            }
        }
    }
}
