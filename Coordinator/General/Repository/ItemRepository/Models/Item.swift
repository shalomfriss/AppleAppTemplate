import Foundation
import SwiftData

@Model
final class Item: Identifiable {
    var albumId: Int
    @Attribute(.unique) var id: Int
    var title: String
    var url: String
    var thumbnailUrl: String
    
    init(id: Int, title: String, url: String, thumbnailUrl: String, albumId: Int) {
        self.id = id
        self.title = title
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.albumId = albumId
    }
}
