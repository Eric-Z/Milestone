import Foundation
import SwiftData

@Model
final class Tag: Identifiable {
    var content: String
    
    init(content: String) {
        self.content = content
    }
} 
