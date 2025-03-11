import SwiftUI

struct MainScrollView: View {
    
    @Binding var selectedTag: String
    @State var showEditView = false
    var milestones: [Milestone]
    
    var body: some View {
        ScrollView {
            ForEach(filterAndSortMilestone, id: \.self) { milestone in
                MainMilestoneRowView(milestone: milestone, showEditView: $showEditView)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
            }
        }
    }
    
    /**
     按标签筛选并排序
     */
    var filterAndSortMilestone: [Milestone] {
        var filteredMilestones = [Milestone]()
        if (selectedTag == "#所有标签") {
            filteredMilestones = milestones
        } else {
            filteredMilestones = milestones.filter { $0.tag == selectedTag }
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

#Preview {
    let milestone = Milestone(title: "北海道之行", tag: "#旅游", remark: "备注 1", date: Date())
    
    MainScrollView(selectedTag: .constant("#所有标签"), milestones: [milestone])
}
