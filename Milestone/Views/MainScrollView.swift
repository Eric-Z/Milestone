import SwiftUI
import Foundation
import SwiftData

struct MainScrollView: View {
    
    @Binding var selectedTag: String
    @State private var selectedMilestone: Milestone?
    @Environment(\.modelContext) private var modelContext
    
    var milestones: [Milestone]
    
    var body: some View {
        List {
            ForEach(filterAndSortMilestone, id: \.self) { milestone in
                MainMilestoneRowView(milestone: milestone)
                    .listRowInsets(EdgeInsets(top: 0, leading: 14, bottom: 10, trailing: 14))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteMilestone(milestone)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                    .onTapGesture {
                        selectedMilestone = milestone
                    }
            }
        }
        .listStyle(.plain)
        .sheet(item: $selectedMilestone) { milestone in
            EditView(milestone: milestone)
        }
    }
    
    private func deleteMilestone(_ milestone: Milestone) {
        modelContext.delete(milestone)
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
    let milestone1 = Milestone(title: "北海道之行", tag: "#旅游", remark: "备注 1", date: Date())
    let milestone2 = Milestone(title: "冲绳之行", tag: "#旅游", remark: "备注 1", date: Date())
    
    MainScrollView(selectedTag: .constant("#所有标签"), milestones: [milestone1, milestone2])
}
