//
//  DemoViewModel.swift
//  Coordinator
//
//  Created by Friss, Shay (206845153) on 10/23/25.
//

import Foundation
import SwiftData

@MainActor
final class RepositoryDemoViewModel: ObservableObject {
    @Published private(set) var items: [Item] = []

    private var repository: ItemRepository?

    init() {
        // Placeholder repository until configured via `configure(container:itemsURL:)`
    }

    func configure(container: ModelContainer, itemsURL: String) {
        let local = SwiftDataLocalStore(container: container)
        self.repository = ItemRepository(local: local, network: NetworkClient(), itemsURL: itemsURL)
    }
    
    func load() async {
        guard let repository else { return }
        do {
            items = try await repository.getItems(nil)
        } catch {
            print("Failed to load items: \(error)")
        }
    }

    @MainActor
    func addItem(id: String, title: String, url: String, thumbnailUrl: String, albumId: Int) {
        guard let repository = repository else { return }
        let newItem = Item(id: -1, title: title, url: url, thumbnailUrl: thumbnailUrl, albumId: albumId)
        Task {
            do {
                if let local = (repository as? ItemRepository)?.local as? SwiftDataLocalStore {
                    try await local.saveItems([newItem])
                    await load()
                }
            } catch {
                print("Failed to add item: \(error)")
            }
        }
    }
}
