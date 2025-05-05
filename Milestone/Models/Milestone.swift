import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    
    var id: UUID
    var folderId: String?
    var title: String
    var remark: String
    var date: Date
    var deleteDate: Date?
    var isPinned: Bool
    var isEditing: Bool
    var isChecked: Bool
    
    init(id: UUID = UUID(), folderId: String?, title: String, remark: String, date: Date) {
        self.id = id
        self.folderId = folderId
        self.title = title
        self.remark = remark
        self.date = date
        self.isPinned = false
        self.deleteDate = nil
        self.isEditing = false
        self.isChecked = false
    }
} 
