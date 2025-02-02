import SwiftUI
import SwiftData

struct MainHeaderView: View {
    
    @Query private var milestones: [Milestone]
    
    var body: some View {
        VStack {
            HStack {
                Text("MileStone")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            if (!milestones.isEmpty) {
                HStack {
                    Text("\(milestones.count) 个里程碑")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.grayText)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Milestone.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        context.insert(Milestone(title: "北海道之行", tag: "旅游", remark: "", date: Date()))
        context.insert(Milestone(title: "庄慧的生日", tag: "生日", remark: "", date: Date()))
        
        return MainHeaderView()
            .modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
