import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    
    var id: UUID
    var folderId: String
    var type: MilestonType = MilestonType.singleDay
    var allDay: Bool = true
    var title: String
    var date: Date
    var date2: Date
    var deleteDate: Date?
    var isPinned: Bool
    var isEditing: Bool
    var isChecked: Bool
    
    init(id: UUID = UUID(), folderId: String, title: String, date: Date) {
        self.id = id
        self.folderId = folderId
        self.title = title
        self.date = date
        self.date2 = date
        self.deleteDate = nil
        self.isPinned = false
        self.isEditing = false
        self.isChecked = false
    }
} 
