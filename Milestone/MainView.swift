import SwiftUI
import SwiftData
import Foundation

struct MainView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Query private var milestones: [Milestone]
    @Query(sort: \Tag.content, order: .forward) private var tags: [Tag]
    
    @State private var selectedTag: String = "#所有标签"
    @State private var showingAddSheet = false
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                HStack {
                    MainHeaderView(milestones: milestones)
                    
                    Spacer()
                    
                    Button {
                        isDarkMode.toggle()
                        setAppearance()
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isDarkMode ? .yellow : .primary)
                    }
                    .padding(.bottom, 15)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                
                if (milestones.isEmpty) {
                    NoDataView()
                        .padding(.horizontal, 20)
                } else {
                    MainTagView(tags: tags, selectedTag: $selectedTag)
                    
                    MainScrollMilestoneView(milestones: milestones, selectedTag: $selectedTag)
                }
            }
            
            if !milestones.isEmpty {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 54))
                    }
                    .padding(.bottom, 40)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            setAppearance()
        }
    }
    
    private func setAppearance() {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
    }
}

#Preview {
    do {
        let schema = Schema([
            Milestone.self, Tag.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let date1 = dateFormatter.date(from: "2025/02/20")!
        let date2 = dateFormatter.date(from: "2024/11/23")!
        let date3 = dateFormatter.date(from: "2025/01/01")!
        let date4 = dateFormatter.date(from: "2023/12/03")!
        let date5 = dateFormatter.date(from: "2025/02/11")!
        
        context.insert(Milestone(title: "北海道之行", tag: "#旅游", remark: "备注 1", date: date1))
        context.insert(Milestone(title: "庄慧的生日", tag: "#生日", remark: "备注 2", date: date2))
        context.insert(Milestone(title: "新年", tag: "#假期", remark: "备注 3", date: date3))
        context.insert(Milestone(title: "和金石徐开认识", tag: "#纪念日", remark: "备注 4", date: date4))
        context.insert(Milestone(title: "今天", tag: "#纪念日", remark: "备注 5", date: date5))
        
        context.insert(Tag(content: "#旅游"))
        context.insert(Tag(content: "#生日"))
        context.insert(Tag(content: "#假期"))
        context.insert(Tag(content: "#纪念日"))
        
        return MainView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
