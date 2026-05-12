import SwiftUI
import Combine
import CoreMotion
import CoreLocation

struct QiblaView: View {
    @EnvironmentObject var pm: PrayerManager
    @StateObject private var motion = MotionManager()
    @AppStorage("userName") var userName: String = ""

    private var avatarImage: UIImage? {
        let data = UserDefaults.standard.data(forKey: "userPhotoData") ?? Data()
        return data.isEmpty ? nil : UIImage(data: data)
    }

    private var qiblaBearing: Double {
        guard let coords = pm.currentCoords else { return 0 }
        return pm.qiblaDirection(from: coords)
    }

    private var needleAngle: Double { qiblaBearing - motion.heading }
    private var ringAngle: Double { -motion.heading }

    private var degreesOff: Double {
        var d = needleAngle.truncatingRemainder(dividingBy: 360)
        if d > 180 { d -= 360 }
        if d < -180 { d += 360 }
        return abs(d)
    }

    private var isAligned: Bool { degreesOff < 5 }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Header
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("as-salamu alaykum")
                                .font(.system(size: 15, weight: .light))
                                .foregroundColor(.white.opacity(0.45))
                            Text(userName)
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        ZStack {
                            Circle().fill(Color.white.opacity(0.08)).frame(width: 50, height: 50)
                            Circle().stroke(Color.white.opacity(0.15), lineWidth: 0.5).frame(width: 50, height: 50)
                            if let img = avatarImage {
                                Image(uiImage: img)
                                    .resizable().scaledToFill()
                                    .frame(width: 50, height: 50).clipShape(Circle())
                            } else {
                                Text(String(userName.prefix(1)).uppercased())
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Compass card
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("QIBLA DIRECTION")
                                    .font(.system(size: 11, weight: .medium))
                                    .tracking(2.5)
                                    .foregroundColor(.white.opacity(0.35))
                                Text(String(format: "%.1f°  %@", qiblaBearing, cardinalName(qiblaBearing)))
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                            HStack(spacing: 7) {
                                Circle()
                                    .fill(isAligned ? Color.white : Color.white.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                Text(isAligned ? "Aligned" : "Searching")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundColor(isAligned ? .white.opacity(0.85) : .white.opacity(0.3))
                            }
                            .animation(.easeInOut(duration: 0.3), value: isAligned)
                        }

                        // Compass
                        ZStack {
                            // Rotating ring
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    .frame(width: 280, height: 280)

                                ForEach(0..<72) { i in
                                    let major = i % 9 == 0
                                    Rectangle()
                                        .fill(Color.white.opacity(major ? 0.4 : 0.09))
                                        .frame(width: major ? 1.5 : 0.5, height: major ? 14 : 7)
                                        .offset(y: -135)
                                        .rotationEffect(.degrees(Double(i) * 5))
                                }

                                ForEach(0..<4) { i in
                                    let labels = ["N", "E", "S", "W"]
                                    let isN = i == 0
                                    Text(labels[i])
                                        .font(.system(size: isN ? 16 : 12, weight: isN ? .semibold : .light))
                                        .foregroundColor(.white.opacity(isN ? 0.85 : 0.3))
                                        .offset(y: -112)
                                        .rotationEffect(.degrees(Double(i) * 90))
                                }

                                Circle()
                                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
                                    .frame(width: 180, height: 180)
                            }
                            .rotationEffect(.degrees(ringAngle))
                            .animation(.easeOut(duration: 0.08), value: ringAngle)

                            // Needle pointing to Qibla
                            ZStack {
                                VStack(spacing: 0) {
                                    Triangle()
                                        .fill(Color.white)
                                        .frame(width: 20, height: 26)
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 5, height: 62)
                                    Rectangle()
                                        .fill(Color.white.opacity(0.18))
                                        .frame(width: 5, height: 40)
                                    Triangle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 14, height: 18)
                                        .rotationEffect(.degrees(180))
                                }
                            }
                            .rotationEffect(.degrees(needleAngle))
                            .animation(.easeOut(duration: 0.08), value: needleAngle)

                            Circle().fill(Color.black).frame(width: 18, height: 18)
                            Circle().stroke(Color.white.opacity(0.4), lineWidth: 1).frame(width: 18, height: 18)
                            Circle().fill(Color.white).frame(width: 5, height: 5)
                        }
                        .frame(width: 280, height: 280)

                        // Degree readout
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(String(format: "%.0f", qiblaBearing))
                                .font(.system(size: 52, weight: .thin))
                                .tracking(-1.5)
                                .foregroundColor(.white)
                                .monospacedDigit()
                            Text("°")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.bottom, 5)
                        }

                        Text("Rotate your phone until the needle points to Qibla")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.3))
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.05))
                            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    )
                    .padding(.horizontal, 16)

                    // Location
                    HStack {
                        Image(systemName: "location")
                            .font(.system(size: 13, weight: .light))
                            .foregroundColor(.white.opacity(0.3))
                        Text(pm.locationName)
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.white.opacity(0.45))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.05))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { motion.start() }
        .onDisappear { motion.stop() }
    }

    private func cardinalName(_ a: Double) -> String {
        ["N","NE","E","SE","S","SW","W","NW"][Int((a + 22.5) / 45) % 8]
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

class MotionManager: ObservableObject {
    @Published var heading: Double = 0
    private let locationManager = CLLocationManager()
    private var headingDelegate: HeadingDelegate?

    func start() {
        headingDelegate = HeadingDelegate { [weak self] mag, tru in
            DispatchQueue.main.async {
                self?.heading = tru >= 0 ? tru : mag
            }
        }
        locationManager.delegate = headingDelegate
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }

    func stop() { locationManager.stopUpdatingHeading() }
}

class HeadingDelegate: NSObject, CLLocationManagerDelegate {
    let callback: (Double, Double) -> Void
    init(_ callback: @escaping (Double, Double) -> Void) { self.callback = callback }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading h: CLHeading) {
        callback(h.magneticHeading, h.trueHeading)
    }
}
