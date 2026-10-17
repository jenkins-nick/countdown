import Observation
import WidgetKit

@Observable
final class CountdownStore {
    private(set) var events = CountdownStorage.load()

    func upsert(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        } else {
            events.append(event)
        }
        persist()
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
        persist()
    }

    private func persist() {
        CountdownStorage.save(events)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
