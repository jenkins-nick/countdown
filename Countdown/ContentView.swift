import SwiftUI

struct ContentView: View {
    @Environment(CountdownStore.self) private var store
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            Group {
                if store.events.isEmpty {
                    ContentUnavailableView {
                        Label("No Countdowns", systemImage: "calendar.badge.clock")
                    } description: {
                        Text("Add a date you're looking forward to.")
                    } actions: {
                        Button("Add Countdown") { isAdding = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(store.events.sortedByDate()) { event in
                                NavigationLink(value: event.id) {
                                    CountdownCard(event: event)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        store.delete(event)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Countdowns")
            .navigationDestination(for: UUID.self) { id in
                CountdownDetailView(eventID: id)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add", systemImage: "plus") { isAdding = true }
                }
            }
            .sheet(isPresented: $isAdding) {
                EditCountdownView(event: nil)
            }
        }
    }
}

struct CountdownCard: View {
    let event: CountdownEvent

    var body: some View {
        TimelineView(.everyMinute) { context in
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.emoji)
                        .font(.largeTitle)
                    Text(event.displayTitle)
                        .font(.headline)
                        .lineLimit(2)
                    Text(event.formattedDate)
                        .font(.subheadline)
                        .opacity(0.85)
                }
                Spacer(minLength: 12)
                VStack(alignment: .trailing, spacing: 0) {
                    Text(event.countText(at: context.date))
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(event.captionText(at: context.date))
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .opacity(0.85)
                }
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(event.theme.gradient, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

#Preview {
    ContentView()
        .environment(CountdownStore())
}
