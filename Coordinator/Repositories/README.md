# Repository & SwiftData wiring

This directory contains:

- `Item.swift` - SwiftData model (@Model) for items.
- `ItemDTO.swift` - Network DTO for decoding JSON payloads.
- `NetworkClient.swift` - Simple URLSession-based client.
- `LocalStore.swift` - Protocol and `SwiftDataLocalStore` implementing local persistence with SwiftData.
- `ItemRepository.swift` - `DefaultItemRepository` which checks local cache first and falls back to network; saves network results to local store.
- `RepositoryDemoView.swift` - Small demo view showing how to use the repository.

Wiring SwiftData ModelContainer in your App:

In `CoordinatorApp.swift` create a `ModelContainer` with the `Item` model and pass it to parts of the app that need local persistence.

Example (modify `CoordinatorApp`'s `body`):

```swift
import SwiftUI
import SwiftData

@main
struct CoordinatorApp: App {
    // Create a ModelContainer with your models
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: [Item.self])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container) // provide container to the view hierarchy
                // You can also configure the demo view's view model to use the container:
                .onAppear {
                    // Example: configure the demo view model
                    // let vm = ... configure with SwiftDataLocalStore(container: container)
                }
        }
    }
}
```

Replace the `itemsURL` with your real API endpoint when creating `DefaultItemRepository`.

Notes:
- The repository uses the local store first and fetches from network only when the local store is empty (you can extend this logic with timestamps or freshness checks).
- Error handling is intentionally minimal in the demo. In production, handle errors and edge-cases (connectivity, partial saves, conflicts) explicitly.
