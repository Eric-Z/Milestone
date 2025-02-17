import Foundation
import SwiftData

@Model
final class Tag: Identifiable {
    var id: UUID
    var content: String
    
    init(id: UUID = UUID(), content: String) {
        self.id = id
        self.content = content
    }
} 
