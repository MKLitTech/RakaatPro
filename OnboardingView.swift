import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPhotoData") var userPhotoData: Data = Data()

    @State private var nameInput: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var avatarImage: UIImage?
    @State private var stars: [StarParticle] = []
    @State private var appeared = false
    @FocusState private var nameFocused: Bool

    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            // Full bleed black background
            Color.black
                .frame(width: screenW, height: screenH)
                .ignoresSafeArea()

            // Stars behind everything
            ZStack {
                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white.opacity(appeared ? star.opacity : 0))
                        .frame(width: star.size, height: star.size)
                        .position(x: star.x, y: star.y)
                        .animation(
                            .easeInOut(duration: star.duration)
                                .repeatForever(autoreverses: true)
                                .delay(star.delay),
                            value: appeared
                        )
                }
            }
            .frame(width: screenW, height: screenH)
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                // Logo — top third
                VStack(spacing: 18) {
                    RakatLogo(color: .white)
                        .frame(width: 48, height: 60)
                        .opacity(0.85)

                    Text("RAKAT PRO")
                        .font(.system(size: 13, weight: .ultraLight))
                        .tracking(10)
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
                .padding(.bottom, 50)

                // Glass card — bottom two-thirds
                VStack(spacing: 0) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.05))
                                .frame(width: 84, height: 84)
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                                .frame(width: 84, height: 84)
                            if let img = avatarImage {
                                Image(uiImage: img)
                                    .resizable().scaledToFill()
                                    .frame(width: 84, height: 84).clipShape(Circle())
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "person")
                                        .font(.system(size: 24, weight: .ultraLight))
                                        .foregroundColor(.white.opacity(0.25))
                                    Text("ADD PHOTO")
                                        .font(.system(size: 7, weight: .regular))
                                        .tracking(1.5)
                                        .foregroundColor(.white.opacity(0.18))
                                }
                            }
                        }
                    }
                    .onChange(of: selectedPhoto) { _, item in
                        Task {
                            if let data = try? await item?.loadTransferable(type: Data.self),
                               let img = UIImage(data: data) {
                                avatarImage = img
                                userPhotoData = data
                            }
                        }
                    }
                    .padding(.top, 44)

                    Text("optional")
                        .font(.system(size: 11, weight: .ultraLight))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.18))
                        .padding(.top, 8)
                        .padding(.bottom, 40)

                    // Name field
                    VStack(alignment: .leading, spacing: 12) {
                        Text("YOUR NAME")
                            .font(.system(size: 10, weight: .ultraLight))
                            .tracking(2.5)
                            .foregroundColor(.white.opacity(0.3))

                        TextField("Mohammed", text: $nameInput)
                            .font(.system(size: 28, weight: .ultraLight))
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .focused($nameFocused)
                            .onSubmit {
                                let t = nameInput.trimmingCharacters(in: .whitespaces)
                                if !t.isEmpty { userName = t }
                            }

                        Rectangle()
                            .fill(.white.opacity(0.1))
                            .frame(height: 0.5)
                    }
                    .padding(.horizontal, 36)
                    .padding(.bottom, 40)

                    // Begin button
                    Button {
                        let t = nameInput.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        nameFocused = false
                        userName = t
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(nameInput.isEmpty ? Color.white.opacity(0.05) : Color.white)
                                .frame(height: 56)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(nameInput.isEmpty ? 0.1 : 0), lineWidth: 0.5)
                                )
                            Text("Begin")
                                .font(.system(size: 18, weight: .light))
                                .foregroundColor(nameInput.isEmpty ? .white.opacity(0.2) : .black)
                        }
                    }
                    .disabled(nameInput.isEmpty)
                    .padding(.horizontal, 36)
                    .animation(.easeInOut(duration: 0.2), value: nameInput.isEmpty)

                    Text("no account · no ads · open source")
                        .font(.system(size: 12, weight: .ultraLight))
                        .foregroundColor(.white.opacity(0.15))
                        .padding(.top, 22)
                        .padding(.bottom, 50)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 36)
                            .fill(Color.white.opacity(0.04))
                        RoundedRectangle(cornerRadius: 36)
                            .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        LinearGradient(
                            colors: [Color.white.opacity(0.06), Color.clear],
                            startPoint: .top,
                            endPoint: .init(x: 0.5, y: 0.3)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 36))
                    }
                )
                .ignoresSafeArea(edges: .bottom)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onTapGesture { nameFocused = false }
        .onAppear {
            generateStars()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { appeared = true }
        }
    }

    private func generateStars() {
        stars = (0..<70).map { _ in
            StarParticle(
                x: CGFloat.random(in: 0...screenW),
                y: CGFloat.random(in: 0...screenH),
                size: CGFloat.random(in: 0.8...2.5),
                opacity: Double.random(in: 0.05...0.5),
                duration: Double.random(in: 1.5...5),
                delay: Double.random(in: 0...6)
            )
        }
    }
}

struct StarParticle: Identifiable {
    let id = UUID()
    let x, y, size: CGFloat
    let opacity, duration, delay: Double
}
