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
    public let local: LocalStore
    private let network: NetworkClient
    private let itemsURL: String

    init(local: LocalStore, network: NetworkClient, itemsURL: String) {
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

extension ItemRepository {
    /// Convenience factory to create a repository while respecting the NetworkClient's actor isolation.
    /// Usage: `let repo = await DefaultItemRepository.make(local: local, itemsURL: url)`
    static func make(local: LocalStore, itemsURL: String) async -> ItemRepository {
        // Construct the NetworkClient on its required actor if it declares one.
        // If NetworkClient is annotated with a global actor (e.g., @NetworkActor), this `await` ensures
        // we hop to that actor before initialization. If not, the await is a harmless suspension point.
        let client = await ItemRepository.makeNetworkClient()
        return ItemRepository(local: local, network: client, itemsURL: itemsURL)
    }

    /// Helper that initializes NetworkClient on its actor if needed.
    @inline(__always)
    private static func makeNetworkClient() async -> NetworkClient {
        // If NetworkClient has a global actor annotation, this function should also be annotated with it
        // to satisfy the compiler. We conditionally provide an overload when available.
        await _makeNetworkClientOnActor()
    }
}

#if canImport(Foundation)
// If your ItemDTO type already has these properties, you can conform it to this protocol in its own file.
// This empty extension is intentionally left without conformance to avoid accidental coupling.
#endif

// MARK: - Actor-aware NetworkClient factory

#if canImport(Foundation)
// Provide two overloads so one will be chosen depending on whether NetworkClient's init is actor-isolated.
// If there is a specific global actor like @NetworkActor, annotate this helper accordingly.
@available(*, deprecated, message: "Do not call directly; use DefaultItemRepository.make(local:itemsURL:)")
private func _makeNetworkClientOnActor() async -> NetworkClient {
    // Fallback path when no specific actor is required; initialization is safe.
    return NetworkClient()
}
#endif

