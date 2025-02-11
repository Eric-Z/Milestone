import SwiftUI
import SwiftData
import Foundation

struct MainScrollMilestoneView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var milestones: [Milestone]
    @Binding var selectedTag: String
    
    var body: some View {
        ScrollView {
            ForEach(filterAndSortMilestone, id: \.self) { milestone in
                MainMilestoneView(milestone: milestone)
            }
        }
    }
    
    var filterAndSortMilestone: [Milestone] {
        var filteredMilestones = [Milestone]()
        if (selectedTag == "所有标签") {
            filteredMilestones = milestones
        } else {
            filteredMilestones = milestones.filter { "#" + $0.tag == selectedTag }
        }
        
        // 按照日期排序
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return filteredMilestones.sorted {
            let isFirstPast = $0.date < today
            let isSecondPast = $1.date < today
            
            if !isFirstPast && !isSecondPast {
                return $0.date < $1.date
            } else if isFirstPast && isSecondPast {
                return $0.date > $1.date
            } else {
                return !isFirstPast
            }
        }
    }
}
