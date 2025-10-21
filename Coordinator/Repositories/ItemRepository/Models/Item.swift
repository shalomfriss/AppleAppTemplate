import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var details: String?

    init(id: UUID = UUID(), title: String, details: String? = nil) {
        self.id = id
        self.title = title
        self.details = details
    }
}
