import SwiftUI

struct EditCountdownView: View {
    @Environment(CountdownStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var draft: CountdownEvent
    private let isNew: Bool

    init(event: CountdownEvent?) {
        let thirtyDaysOut = Calendar.current.date(byAdding: .day, value: 30, to: .now) ?? .now
        _draft = State(initialValue: event ?? CountdownEvent(title: "", date: thirtyDaysOut))
        isNew = event == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CountdownCard(event: draft)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section("Event") {
                    TextField("Title", text: $draft.title)
                    TextField("Emoji", text: $draft.emoji)
                        .onChange(of: draft.emoji) { _, newValue in
                            if newValue.count > 1 {
                                draft.emoji = String(newValue.suffix(1))
                            }
                        }
                }

                Section("Date") {
                    DatePicker(
                        "Date",
                        selection: $draft.date,
                        displayedComponents: draft.includesTime ? [.date, .hourAndMinute] : [.date]
                    )
                    Toggle("Include a time", isOn: $draft.includesTime)
                }

                Section("Color") {
                    HStack {
                        ForEach(CountdownTheme.allCases) { theme in
                            Button {
                                draft.theme = theme
                            } label: {
                                Circle()
                                    .fill(theme.gradient)
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        if theme == draft.theme {
                                            Image(systemName: "checkmark")
                                                .font(.headline)
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel(theme.name)
                            .accessibilityAddTraits(theme == draft.theme ? .isSelected : [])
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(isNew ? "New Countdown" : "Edit Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        var event = draft
        event.title = event.title.trimmingCharacters(in: .whitespaces)
        if event.emoji.isEmpty { event.emoji = "📅" }
        store.upsert(event)
        dismiss()
    }
}

#Preview {
    EditCountdownView(event: .sample)
        .environment(CountdownStore())
}
