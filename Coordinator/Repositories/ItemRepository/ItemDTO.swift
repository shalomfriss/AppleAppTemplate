import Foundation

struct ItemDTO: Codable {
    let albumId, id: Int
    let title: String
    let url, thumbnailUrl: String
}
