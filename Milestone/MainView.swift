import SwiftUI
import SwiftData

struct MainView: View {
    
    @Query private var milestones: [Milestone]
    @State private var selectedTag: String = "所有标签"
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            MainHeaderView()
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
            
            if (milestones.isEmpty) {
                NoDataView()
                    .padding(.horizontal, 20)
            } else {
                MainTagView(selectedTag: $selectedTag)
            }
        }
        Spacer()
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Milestone.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        context.insert(Milestone(title: "北海道之行", tag: "旅游", remark: "", date: Date()))
        context.insert(Milestone(title: "庄慧的生日", tag: "生日", remark: "", date: Date()))
        
        return MainView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
