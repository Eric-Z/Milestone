import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    
    var id: UUID
    var folderId: String?
    var title: String
    var remark: String
    var date: Date
    var pinned: Bool
    var deleteDate: Date?
    var deleted: Bool
    var isAddOrEdit: Bool
    
    init(id: UUID = UUID(), folderId: String?, title: String, remark: String, date: Date) {
        self.id = id
        self.folderId = folderId
        self.title = title
        self.remark = remark
        self.date = date
        self.pinned = false
        self.deleteDate = nil
        self.deleted = false
        self.isAddOrEdit = false
    }
} 
