import Foundation
import Combine
import CoreLocation

struct PrayerTime: Identifiable {
    let id = UUID()
    let name: String
    let time: Date
    var isPast: Bool { time < Date() }
    var isNext: Bool = false
}

// MARK: - AlAdhan API Response Models

private struct AlAdhanResponse: Codable {
    let code: Int
    let data: AlAdhanData
}

private struct AlAdhanData: Codable {
    let timings: AlAdhanTimings
}

private struct AlAdhanTimings: Codable {
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

// MARK: - Prayer Manager

class PrayerManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var prayers: [PrayerTime] = []
    @Published var nextPrayer: PrayerTime?
    @Published var timeUntilNext: String = "—"
    @Published var locationName: String = "Locating..."
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var coords: CLLocationCoordinate2D?
    private var lastFetchedDate: String = ""

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.errorMessage = "Location access denied. Please enable in Settings."
                self.isLoading = false
            }
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        coords = loc.coordinate
        reverseGeocode(loc)
        fetchPrayerTimes(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Could not get location."
            self.isLoading = false
        }
    }

    // MARK: - Reverse Geocode

    private func reverseGeocode(_ location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            DispatchQueue.main.async {
                if let city = placemarks?.first?.locality {
                    self?.locationName = city
                }
            }
        }
    }

    // MARK: - AlAdhan API Fetch
    // Uses the same calculation backend as Muslim Pro (ISNA method = method 2 for North America)
    // Method 2 = Islamic Society of North America — best for US/Canada
    // Method 3 = Muslim World League — best for Europe/Far East
    // Change `method=2` below to switch

    func fetchPrayerTimes(lat: Double, lon: Double) {
        let today = todayString()
        guard today != lastFetchedDate else { return } // don't re-fetch same day

        let method = 2 // ISNA — matches Muslim Pro default for North America
        let urlString = "https://api.aladhan.com/v1/timings/\(today)?latitude=\(lat)&longitude=\(lon)&method=\(method)"

        guard let url = URL(string: urlString) else { return }

        isLoading = true

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received."
                    self.isLoading = false
                }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(AlAdhanResponse.self, from: data)
                let timings = decoded.data.timings
                let parsed = self.parsePrayerTimes(timings: timings)

                DispatchQueue.main.async {
                    self.prayers = parsed
                    self.lastFetchedDate = today
                    self.isLoading = false
                    self.errorMessage = nil
                    self.updateNextPrayer()
                    self.startTimer()
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to parse prayer times."
                    self.isLoading = false
                }
            }
        }.resume()
    }

    // MARK: - Parse API times into Date objects

    private func parsePrayerTimes(timings: AlAdhanTimings) -> [PrayerTime] {
        let pairs: [(String, String)] = [
            ("Fajr",    timings.Fajr),
            ("Dhuhr",   timings.Dhuhr),
            ("Asr",     timings.Asr),
            ("Maghrib", timings.Maghrib),
            ("Isha",    timings.Isha)
        ]

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current

        let calendar = Calendar.current
        let todayComps = calendar.dateComponents([.year, .month, .day], from: Date())

        return pairs.compactMap { name, timeStr in
            // API returns "HH:mm (TZ)" sometimes — strip any trailing info
            let cleanTime = timeStr.components(separatedBy: " ").first ?? timeStr

            guard let parsedTime = formatter.date(from: cleanTime) else { return nil }

            // Combine today's date with the parsed time
            let timeComps = calendar.dateComponents([.hour, .minute], from: parsedTime)
            var comps = todayComps
            comps.hour = timeComps.hour
            comps.minute = timeComps.minute
            comps.second = 0

            guard let finalDate = calendar.date(from: comps) else { return nil }
            return PrayerTime(name: name, time: finalDate)
        }
    }

    // MARK: - Timer & Next Prayer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateNextPrayer()

            // Re-fetch if day changed
            if self.todayString() != self.lastFetchedDate, let coords = self.coords {
                self.fetchPrayerTimes(lat: coords.latitude, lon: coords.longitude)
            }
        }
    }

    private func updateNextPrayer() {
        let now = Date()
        var updated = prayers.map { p -> PrayerTime in
            var copy = p; copy.isNext = false; return copy
        }

        if let idx = updated.firstIndex(where: { $0.time > now }) {
            updated[idx].isNext = true
            nextPrayer = updated[idx]
            let diff = updated[idx].time.timeIntervalSince(now)
            let h = Int(diff) / 3600
            let m = (Int(diff) % 3600) / 60
            timeUntilNext = h > 0 ? "in \(h)h \(m)m" : "in \(m)m"
        } else {
            // All prayers passed — show Fajr as next (tomorrow)
            nextPrayer = updated.first
            timeUntilNext = "tomorrow"
        }

        prayers = updated
    }

    private func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "dd-MM-yyyy"
        return f.string(from: Date())
    }

    // MARK: - Qibla

    func qiblaDirection(from coord: CLLocationCoordinate2D) -> Double {
        let meccaLat = 21.3891 * .pi / 180
        let meccaLon = 39.8579 * .pi / 180
        let lat = coord.latitude * .pi / 180
        let lon = coord.longitude * .pi / 180
        let dLon = meccaLon - lon
        let y = sin(dLon) * cos(meccaLat)
        let x = cos(lat) * sin(meccaLat) - sin(lat) * cos(meccaLat) * cos(dLon)
        var angle = atan2(y, x) * 180 / .pi
        if angle < 0 { angle += 360 }
        return angle
    }

    var currentCoords: CLLocationCoordinate2D? { coords }
}
