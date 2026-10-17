import SwiftUI

struct CountdownEvent: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var date: Date
    var includesTime = false
    var emoji = "🎉"
    var theme = CountdownTheme.sunset

    enum Status: Equatable {
        case upcoming(days: Int)
        case today
        case past(days: Int)
    }

    /// The moment being counted down to: the exact time if one was set, otherwise the start of the day.
    var targetDate: Date {
        includesTime ? date : Calendar.current.startOfDay(for: date)
    }

    /// Whole calendar days between `now` and the event (negative once it has passed).
    func daysRemaining(from now: Date = .now, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: now)
        let end = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    func status(at now: Date = .now) -> Status {
        let days = daysRemaining(from: now)
        if days > 0 { return .upcoming(days: days) }
        if days < 0 { return .past(days: -days) }
        return .today
    }

    /// True on the day of an event with a time that hasn't arrived yet, when a ticking timer is more useful than a day count.
    func showsLiveTimer(at now: Date = .now) -> Bool {
        status(at: now) == .today && includesTime && date > now
    }

    /// The big number, e.g. "12" or "Today".
    func countText(at now: Date = .now) -> String {
        switch status(at: now) {
        case .upcoming(let days), .past(let days): days.formatted()
        case .today: "Today"
        }
    }

    /// The words under the big number, e.g. "days to go".
    func captionText(at now: Date = .now) -> String {
        switch status(at: now) {
        case .upcoming(let days): days == 1 ? "day to go" : "days to go"
        case .past(let days): days == 1 ? "day ago" : "days ago"
        case .today: showsLiveTimer(at: now) ? "at \(date.formatted(date: .omitted, time: .shortened))" : "is the day!"
        }
    }

    /// One line, e.g. "12 days to go" or "Today is the day!".
    func summaryText(at now: Date = .now) -> String {
        "\(countText(at: now)) \(captionText(at: now))"
    }

    var displayTitle: String {
        title.isEmpty ? "Untitled" : title
    }

    var formattedDate: String {
        includesTime
            ? date.formatted(date: .abbreviated, time: .shortened)
            : date.formatted(date: .abbreviated, time: .omitted)
    }

    static let sample = CountdownEvent(
        title: "Vacation",
        date: Calendar.current.date(byAdding: .day, value: 24, to: .now) ?? .now,
        emoji: "🏝️",
        theme: .ocean
    )
}

extension [CountdownEvent] {
    /// Upcoming events soonest first, followed by past events most recent first.
    func sortedByDate(now: Date = .now) -> [CountdownEvent] {
        let upcoming = filter { $0.daysRemaining(from: now) >= 0 }.sorted { $0.date < $1.date }
        let past = filter { $0.daysRemaining(from: now) < 0 }.sorted { $0.date > $1.date }
        return upcoming + past
    }
}

enum CountdownTheme: String, Codable, CaseIterable, Identifiable {
    case sunset, ocean, forest, grape, rose, midnight

    var id: String { rawValue }

    var name: String { rawValue.capitalized }

    var colors: [Color] {
        switch self {
        case .sunset: [Color(red: 1.00, green: 0.62, blue: 0.27), Color(red: 0.93, green: 0.27, blue: 0.40)]
        case .ocean: [Color(red: 0.20, green: 0.78, blue: 0.90), Color(red: 0.16, green: 0.38, blue: 0.86)]
        case .forest: [Color(red: 0.45, green: 0.85, blue: 0.47), Color(red: 0.07, green: 0.55, blue: 0.43)]
        case .grape: [Color(red: 0.74, green: 0.47, blue: 0.98), Color(red: 0.40, green: 0.23, blue: 0.80)]
        case .rose: [Color(red: 1.00, green: 0.55, blue: 0.70), Color(red: 0.86, green: 0.21, blue: 0.53)]
        case .midnight: [Color(red: 0.29, green: 0.33, blue: 0.47), Color(red: 0.09, green: 0.10, blue: 0.18)]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
