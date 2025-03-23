import Foundation
import SwiftData

@Model
final class Folder: Identifiable {
    
    var id: UUID
    var name: String
    var sortOrder: Int
    var isSystem: Bool = false
    
    init(id: UUID = UUID(), name: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
    }
}
