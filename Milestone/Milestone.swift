import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    
    var id: UUID
    var title: String
    var tag: String
    var remark: String
    var date: Date
    
    init(id: UUID = UUID(), title: String, tag: String, remark: String, date: Date) {
        self.id = id
        self.title = title
        self.tag = tag
        self.remark = remark
        self.date = date
    }
} 
