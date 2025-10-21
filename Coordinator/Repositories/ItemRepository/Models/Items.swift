//
//  Items.swift
//  Coordinator
//
//  Created by Shalom Friss on 10/16/25.
//

import Foundation
import SwiftData

@Model
final class Items: Identifiable {
    @Attribute(.unique) var id: UUID
    var items: [Item]
    
    init(id: UUID = UUID(), items: [Item] = []) {
        self.id = id
        self.items = items
    }
}
