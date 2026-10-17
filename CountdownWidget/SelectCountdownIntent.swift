import AppIntents
import WidgetKit

/// Lets each widget be configured (long-press → Edit Widget) to show a particular countdown.
struct SelectCountdownIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Choose Countdown" }
    static var description: IntentDescription { "Pick which countdown this widget shows." }

    @Parameter(title: "Countdown")
    var countdown: CountdownEntity?
}

struct CountdownEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Countdown" }
    static let defaultQuery = CountdownEntityQuery()

    let id: UUID
    let title: String
    let emoji: String

    init(event: CountdownEvent) {
        id = event.id
        title = event.displayTitle
        emoji = event.emoji
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(emoji) \(title)")
    }
}

struct CountdownEntityQuery: EntityQuery {
    func entities(for identifiers: [CountdownEntity.ID]) async throws -> [CountdownEntity] {
        CountdownStorage.load()
            .filter { identifiers.contains($0.id) }
            .map { CountdownEntity(event: $0) }
    }

    func suggestedEntities() async throws -> [CountdownEntity] {
        CountdownStorage.load()
            .sortedByDate()
            .map { CountdownEntity(event: $0) }
    }

    func defaultResult() async -> CountdownEntity? {
        try? await suggestedEntities().first
    }
}
