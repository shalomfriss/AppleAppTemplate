//
//  CoordinatorApp.swift
//  Coordinator
//
//  Created by Shalom Friss on 3/1/25.
//

import SwiftUI
import SwiftData

@main
struct CoordinatorApp: App {
    let container: ModelContainer = {
        do {
            return try ModelContainer(for: Items.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            RepositoryDemoView(modelContainer: container)
                .modelContainer(container)
                .onAppear {
//                    let vm = ... configure with SwiftDataLocalStore(container: container)
                    
                }
        }
    }
}

enum Constants: String {
    case itemsURL = "https://jsonplaceholder.typicode.com/photos"
}
