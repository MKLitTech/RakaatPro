import SwiftUI

struct PrayersView: View {
    @EnvironmentObject var pm: PrayerManager
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPhotoData") var userPhotoData: Data = Data()
    @AppStorage("adhanEnabled") var adhanEnabled: Bool = true

    private var avatarImage: UIImage? {
        userPhotoData.isEmpty ? nil : UIImage(data: userPhotoData)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if pm.isLoading && pm.prayers.isEmpty {
                VStack(spacing: 16) {
                    ProgressView().tint(.white.opacity(0.4))
                    Text("Fetching prayer times...")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.35))
                }
            } else if let err = pm.errorMessage, pm.prayers.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 38, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                    Text(err)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.white.opacity(0.4))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

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

                        NextPrayerWidget(
                            prayer: pm.nextPrayer ?? PrayerTime(name: "—", time: Date()),
                            timeUntil: pm.timeUntilNext,
                            adhanEnabled: $adhanEnabled
                        )

                        PrayerListWidget(prayers: pm.prayers)

                        HStack {
                            Image(systemName: "location")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.white.opacity(0.25))
                            Text(pm.locationName)
                                .font(.system(size: 13, weight: .light))
                                .foregroundColor(.white.opacity(0.25))
                            Spacer()
                            Text("AlAdhan · ISNA")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.white.opacity(0.15))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Next Prayer Widget

struct NextPrayerWidget: View {
    let prayer: PrayerTime
    let timeUntil: String
    @Binding var adhanEnabled: Bool

    private let timeFmt: DateFormatter = { let f = DateFormatter(); f.dateFormat = "h:mm"; return f }()
    private let ampmFmt: DateFormatter = { let f = DateFormatter(); f.dateFormat = "a"; return f }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("NEXT PRAYER")
                .font(.system(size: 11, weight: .medium))
                .tracking(2.5)
                .foregroundColor(.white.opacity(0.35))
                .padding(.bottom, 14)

            Text(prayer.name)
                .font(.system(size: 22, weight: .light))
                .foregroundColor(.white.opacity(0.65))
                .padding(.bottom, 4)

            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(timeFmt.string(from: prayer.time))
                    .font(.system(size: 72, weight: .thin))
                    .tracking(-2)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(ampmFmt.string(from: prayer.time).lowercased())
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 12)
            }

            Text(timeUntil)
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.white.opacity(0.4))
                .padding(.bottom, 22)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                    Rectangle().fill(Color.white.opacity(0.4))
                        .frame(width: max(0, geo.size.width * progressFraction), height: 1)
                }
            }
            .frame(height: 1)
            .padding(.bottom, 22)

            HStack {
                Text("Adhan")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white.opacity(0.45))
                Spacer()
                Toggle("", isOn: $adhanEnabled)
                    .labelsHidden()
                    .tint(.white.opacity(0.7))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
        )
        .padding(.horizontal, 16)
    }

    private var progressFraction: CGFloat {
        let now = Date()
        let s = Double(Calendar.current.component(.hour, from: now)) * 3600
               + Double(Calendar.current.component(.minute, from: now)) * 60
        return CGFloat(min(s / 86400.0, 1.0))
    }
}

// MARK: - Prayer List Widget

struct PrayerListWidget: View {
    let prayers: [PrayerTime]
    private let fmt: DateFormatter = { let f = DateFormatter(); f.dateFormat = "h:mm a"; return f }()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(prayers.enumerated()), id: \.element.id) { i, prayer in
                HStack {
                    Text(prayer.name)
                        .font(.system(size: 18, weight: prayer.isNext ? .semibold : .light))
                        .foregroundColor(
                            prayer.isNext ? .black :
                            prayer.isPast ? .white.opacity(0.28) : .white.opacity(0.75)
                        )
                    Spacer()
                    if prayer.isPast && !prayer.isNext {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.22))
                            .padding(.trailing, 8)
                    }
                    Text(fmt.string(from: prayer.time))
                        .font(.system(size: 17, weight: .light))
                        .monospacedDigit()
                        .foregroundColor(
                            prayer.isNext ? .black.opacity(0.55) :
                            prayer.isPast ? .white.opacity(0.2) : .white.opacity(0.45)
                        )
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 20)
                .background(prayer.isNext ? Color.white : Color.clear)

                if i < prayers.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(prayer.isNext ? 0 : 0.06))
                        .frame(height: 0.5)
                        .padding(.horizontal, prayer.isNext ? 0 : 22)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 16)
    }
}
