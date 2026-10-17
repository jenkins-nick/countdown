import SwiftUI

struct CountdownDetailView: View {
    @Environment(CountdownStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let eventID: UUID

    @State private var isEditing = false
    @State private var isConfirmingDelete = false

    var body: some View {
        if let event = store.events.first(where: { $0.id == eventID }) {
            ZStack {
                event.theme.gradient.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text(event.emoji)
                        .font(.system(size: 80))
                    Text(event.displayTitle)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text(event.formattedDate)
                        .font(.title3)
                        .opacity(0.85)

                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        LiveCountdown(target: event.targetDate, now: context.date)
                    }
                    .padding(.top, 24)
                }
                .foregroundStyle(.white)
                .padding()
            }
            .toolbar {
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("Edit", systemImage: "pencil") { isEditing = true }
                    Button("Delete", systemImage: "trash", role: .destructive) { isConfirmingDelete = true }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $isEditing) {
                EditCountdownView(event: event)
            }
            .confirmationDialog("Delete \(event.displayTitle)?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    dismiss()
                    store.delete(event)
                }
            }
        } else {
            ContentUnavailableView("Countdown Not Found", systemImage: "calendar.badge.exclamationmark")
        }
    }
}

/// Days, hours, minutes and seconds between now and the target, ticking every second.
private struct LiveCountdown: View {
    let target: Date
    let now: Date

    var body: some View {
        let isFuture = target > now
        let parts = Calendar.current.dateComponents(
            [.day, .hour, .minute, .second],
            from: isFuture ? now : target,
            to: isFuture ? target : now
        )

        VStack(spacing: 8) {
            HStack(spacing: 10) {
                unit(parts.day ?? 0, "days")
                unit(parts.hour ?? 0, "hrs")
                unit(parts.minute ?? 0, "min")
                unit(parts.second ?? 0, "sec")
            }
            Text(isFuture ? "to go" : "since")
                .font(.headline)
                .textCase(.uppercase)
                .opacity(0.85)
        }
    }

    private func unit(_ value: Int, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value.formatted())
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(label)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .opacity(0.85)
        }
        .frame(minWidth: 64)
        .padding(.vertical, 12)
        .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
