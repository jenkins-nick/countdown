import Foundation

/// Reads and writes countdowns in the App Group container so the app and the widget see the same data.
enum CountdownStorage {
    /// Comes from the `AppGroupID` Info.plist key, which is built from the BASE_BUNDLE_ID build setting.
    static let appGroupID = Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? "group.com.jenkinsnick.Countdown"

    private static let key = "countdowns"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    static func load() -> [CountdownEvent] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([CountdownEvent].self, from: data)) ?? []
    }

    static func save(_ events: [CountdownEvent]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        defaults.set(data, forKey: key)
    }
}
