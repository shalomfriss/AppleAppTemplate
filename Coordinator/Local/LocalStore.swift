import Foundation
import SwiftData


protocol LocalStore {
    @MainActor func fetchItems() async throws -> [Item]
    @MainActor func saveItems(_ items: [Item]) async throws
}

final class SwiftDataLocalStore: LocalStore {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func fetchItems() async throws -> [Item] {
        let context = container.mainContext
        let request = FetchDescriptor<Item>()
        return try context.fetch(request)
    }

    @MainActor
    func saveItems(_ items: [Item]) async throws {
        let context = container.mainContext
        
        for item in items {
            // If an item with the same id exists, update it; otherwise insert
            let itemId = item.id
            let request = FetchDescriptor<Item>(predicate: #Predicate<Item> { existingItem in
                existingItem.id == itemId
            })
            let existing = try context.fetch(request)
            if let found = existing.first {
                found.title = item.title
                found.details = item.details
            } else {
                _ = Item(id: item.id, title: item.title, details: item.details)
            }
        }
        try context.save()
    }
}

