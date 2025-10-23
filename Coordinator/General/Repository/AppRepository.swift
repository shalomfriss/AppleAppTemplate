//
//  AppRepository.swift
//  Coordinator
//
//  Created by Shalom Friss on 10/21/25.
//

import Foundation

protocol AppRepositoryProtocol {
    func getItems(_ forceNetworkFetch: Bool?) async throws -> [Item]
}

/// The concrete implementation of the AppRepository.
/// It is initialized with all the necessary sub-repositories.
final class AppRepository: AppRepositoryProtocol {

    private let itemRepository: ItemRepository

    // Initialize with its dependencies (the sub-repositories)
    init(itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    // MARK: - AppRepository Protocol Conformance

    /// Delegates the item fetching logic to the dedicated ItemRepository.
    func getItems(_ forceNetworkFetch: Bool? = nil) async throws -> [Item] {
        return try await itemRepository.getItems(forceNetworkFetch)
    }
}
