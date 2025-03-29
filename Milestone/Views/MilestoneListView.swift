import SwiftUI
import SwiftData

struct MilestoneListView: View {
    
    var folder: Folder
    
    @Query var milestones: [Milestone]
    
    init(folder: Folder) {
        self._milestones = Query(filter: #Predicate<Milestone> { milestone in
            milestone.folderId == folder.id
        })
    }
    
    var body: some View {
       
    }
}
