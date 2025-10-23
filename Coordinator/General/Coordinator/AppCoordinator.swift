//
//  AppCoordinator.swift
//  Coordinator
//
//  Created by Shalom Friss on 3/1/25.
//

import SwiftUI

/// Coordinates navigation for the app using a simple stack of routes.
final class AppCoordinator: ObservableObject {
    /// The single route currently presented on top of the main view.
    /// When `presented` is `nil` the app shows the main content (home).
    @Published var presented: Route? = nil

    /// Represents a navigable destination in the app.
    enum Route: Hashable {
        case detail(message: String)
    }

    /// Present a detail view on top of the main view.
    func showDetail(message: String) {
        presented = .detail(message: message)
    }

    /// Dismiss the currently presented view (if any).
    func pop() {
        presented = nil
    }

    /// Return to the main content (same as `pop()` for this simple coordinator).
    func popToRoot() {
        presented = nil
    }
}
