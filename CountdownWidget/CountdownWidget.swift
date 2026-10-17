import SwiftUI
import WidgetKit

struct CountdownEntry: TimelineEntry {
    let date: Date
    let event: CountdownEvent?
}

struct CountdownProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: .now, event: .sample)
    }

    func snapshot(for configuration: SelectCountdownIntent, in context: Context) async -> CountdownEntry {
        CountdownEntry(date: .now, event: resolveEvent(for: configuration) ?? .sample)
    }

    func timeline(for configuration: SelectCountdownIntent, in context: Context) async -> Timeline<CountdownEntry> {
        let event = resolveEvent(for: configuration)
        let calendar = Calendar.current
        let now = Date.now

        // The day count only changes at midnight, so schedule an entry for each of the next few.
        var dates = [now]
        var midnight = calendar.startOfDay(for: now)
        for _ in 0..<7 {
            guard let next = calendar.date(byAdding: .day, value: 1, to: midnight) else { break }
            midnight = next
            dates.append(midnight)
        }
        // Swap the live timer for "Today is the day!" the moment a timed event arrives.
        if let event, event.includesTime, event.date > now, event.date < midnight {
            dates.append(event.date)
        }

        let entries = dates.sorted().map { CountdownEntry(date: $0, event: event) }
        return Timeline(entries: entries, policy: .atEnd)
    }

    /// The countdown picked in the widget's settings, or the soonest one if none was picked.
    private func resolveEvent(for configuration: SelectCountdownIntent) -> CountdownEvent? {
        let events = CountdownStorage.load()
        if let id = configuration.countdown?.id, let match = events.first(where: { $0.id == id }) {
            return match
        }
        return events.sortedByDate().first
    }
}

struct CountdownWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: "CountdownWidget", intent: SelectCountdownIntent.self, provider: CountdownProvider()) { entry in
            CountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Countdown")
        .description("See how many days are left until your date.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

struct CountdownWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: CountdownEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if isHomeScreen {
                    (entry.event?.theme ?? .sunset).gradient
                }
            }
    }

    private var isHomeScreen: Bool {
        family == .systemSmall || family == .systemMedium
    }

    @ViewBuilder
    private var content: some View {
        if let event = entry.event {
            switch family {
            case .accessoryCircular: CircularView(event: event, now: entry.date)
            case .accessoryRectangular: RectangularView(event: event, now: entry.date)
            case .accessoryInline: Text("\(event.emoji) \(event.summaryText(at: entry.date))")
            case .systemMedium: MediumView(event: event, now: entry.date)
            default: SmallView(event: event, now: entry.date)
            }
        } else if family == .accessoryInline {
            Text("No countdowns yet")
        } else {
            VStack(spacing: 4) {
                Image(systemName: "calendar.badge.plus")
                    .font(isHomeScreen ? .title : .title3)
                Text(isHomeScreen ? "Open Countdown to add a date" : "Add a date")
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(isHomeScreen ? Color.white : Color.primary)
        }
    }
}

// MARK: - Home Screen

/// The big number, or a ticking timer on the day of a timed event.
private struct CountText: View {
    let event: CountdownEvent
    let now: Date
    let size: CGFloat

    var body: some View {
        Group {
            if event.showsLiveTimer(at: now) {
                Text(event.date, style: .timer)
            } else {
                Text(event.countText(at: now))
            }
        }
        .font(.system(size: size, weight: .bold, design: .rounded))
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.4)
    }
}

private func caption(for event: CountdownEvent, at now: Date) -> String {
    event.showsLiveTimer(at: now) ? "to go" : event.captionText(at: now)
}

private struct SmallView: View {
    let event: CountdownEvent
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(event.emoji)
                .font(.title2)
            Spacer(minLength: 0)
            CountText(event: event, now: now, size: 52)
            Text(caption(for: event, at: now))
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .opacity(0.85)
            Spacer(minLength: 0)
            Text(event.displayTitle)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Text(event.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .opacity(0.8)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct MediumView: View {
    let event: CountdownEvent
    let now: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.emoji)
                    .font(.largeTitle)
                Spacer(minLength: 0)
                Text(event.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                Text(event.formattedDate)
                    .font(.caption)
                    .opacity(0.85)
            }
            Spacer(minLength: 12)
            VStack(alignment: .trailing, spacing: 0) {
                CountText(event: event, now: now, size: 64)
                Text(caption(for: event, at: now))
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .opacity(0.85)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

// MARK: - Lock Screen

private struct CircularView: View {
    let event: CountdownEvent
    let now: Date

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: -2) {
                switch event.status(at: now) {
                case .upcoming(let days):
                    number(days)
                    label(days == 1 ? "day" : "days")
                case .past(let days):
                    number(days)
                    label("ago")
                case .today:
                    Text(event.emoji)
                        .font(.title3)
                    label("today")
                }
            }
            .padding(4)
        }
        .widgetAccentable()
    }

    private func number(_ value: Int) -> some View {
        Text(value.formatted())
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .textCase(.uppercase)
    }
}

private struct RectangularView: View {
    let event: CountdownEvent
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(event.emoji) \(event.displayTitle)")
                .font(.headline)
                .lineLimit(1)
                .widgetAccentable()
            if event.showsLiveTimer(at: now) {
                Text(event.date, style: .timer)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
            } else {
                Text(event.summaryText(at: now))
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            Text(event.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
}

#Preview("Medium", as: .systemMedium) {
    CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
}

#Preview("Circular", as: .accessoryCircular) {
    CountdownWidget()
} timeline: {
    CountdownEntry(date: .now, event: .sample)
}
