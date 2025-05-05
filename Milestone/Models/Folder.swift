import Foundation
import SwiftData

@Model
final class Folder: Identifiable {
    
    var id: UUID
    var name: String
    var isSystem: Bool = false
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
