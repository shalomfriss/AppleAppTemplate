import Foundation

struct ItemDTO: Codable {
    let id: UUID
    let title: String
    let details: String?
}
