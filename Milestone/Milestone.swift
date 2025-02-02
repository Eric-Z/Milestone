import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    var title: String
    var tag: String
    var remark: String
    var date: Date
    
    init(title: String, tag: String, remark: String, date: Date) {
        self.title = title
        self.tag = tag
        self.remark = remark
        self.date = date
    }
} 
