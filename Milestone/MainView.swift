import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var milestones: [Milestone]
    @State private var selectedTag: String = "所有标签"
    @State private var showingAddSheet = false
    
    let tags = ["所有标签", "#标签", "#标签", "#标签", "#标签", "#标签"]
    
    var filteredMilestones: [Milestone] {
        if selectedTag == "所有标签" {
            return milestones
        }
        return milestones.filter { $0.tag == selectedTag }
    }
    
    var body: some View {
        VStack {
            MainHeaderView()
        }
        Spacer()
    }
    
    private func deleteMilestones(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredMilestones[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Milestone.self, inMemory: true)
}
