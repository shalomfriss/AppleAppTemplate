import Foundation

// Optional fields some ItemDTO variants may provide.
private protocol ItemDTOWithOptionalFields {
    var thumbnailUrl: String? { get }
    var albumId: Int? { get }
}

protocol ItemRepositoryProtocol {
    /// Returns the source-of-truth list of items.
    /// This will consult the local store first and fall back to network if needed.
    func getItems(_ forceNetworkFetch: Bool?) async throws -> [Item]
}

final class ItemRepository: ItemRepositoryProtocol {
    public let local: SwiftDataLocalStoreProtocol
    private let network: NetworkClient
    private let itemsURL: String

    init(local: SwiftDataLocalStoreProtocol, network: NetworkClient, itemsURL: String) {
        self.local = local
        self.network = network
        self.itemsURL = itemsURL
    }

    func getItems(_ forceNetworkFetch: Bool? = false) async throws -> [Item] {
        if let forceNetworkFetch, !forceNetworkFetch {
            // 1. Try local cache
            do {
                print(">>>> Fetch local")
                let localItems = try await local.fetchItems()
                if !localItems.isEmpty {
                    return localItems
                }
            } catch {
                // swallow local read errors and try network as fallback
            }
        }
        
        print(">>>> Fetch network")
        // 2. Fetch from network
        let dtos: [ItemDTO]
        do {
            dtos = try await network.fetchItems(from: itemsURL)
//            dtos = try await network.fetch([ItemDTO].self, from: itemsURL)
        } catch {
            throw error
        }

        // 3. Convert DTOs -> Items and persist locally
        let items = dtos.map { dto in
            Item(
                id: dto.id,
                title: dto.title,
                url: dto.url,
                thumbnailUrl: dto.thumbnailUrl,
                albumId: dto.albumId
            )
        }
        try await local.saveItems(items)

        return items
    }
}
