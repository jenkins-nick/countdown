import SwiftUI

@main
struct CountdownApp: App {
    @State private var store = CountdownStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
