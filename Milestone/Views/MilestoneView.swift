import SwiftUI
import SwiftData
import Foundation

struct MilestoneView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    let folder: Folder
    let milestone: Milestone
    
    // MARK: - 主视图
    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: milestone.date)
        let days = calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
        
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if days == 1 {
                        HStack(spacing: 0) {
                            Text("\(milestone.title)")
                            Text("就在明天！")
                                .foregroundStyle(milestone.isPinned ? .white : .textHighlight1)
                        }
                    } else if days > 0 {
                        Text("\(milestone.title)还有")
                    } else if days < 0 {
                        Text("\(milestone.title)已经")
                    } else {
                        HStack(spacing: 0) {
                            Text("\(milestone.title)")
                            Text("就是今天！")
                                .foregroundStyle(milestone.isPinned ? .white : .textHighlight1)
                        }
                    }
                }
                .font(.system(size: FontSizes.bodyText, weight: .semibold))
                .foregroundStyle(milestone.isPinned ? .white : .accent)
                
                if (folder.type == .all) {
                    HStack(spacing: 0) {
                        Image(systemName: "folder")
                            .font(.system(size: 13))
                            .foregroundStyle(.labelSecondary)
                        
                        Text(folder.name)
                            .font(.system(size: 13))
                            .foregroundStyle(.labelSecondary)
                            .padding(.leading, 2)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(.vertical, 10)
            
            Spacer()
            
            Group {
                if days > 0 {
                    Text("\(days)")
                    Text(" 天")
                } else if days < 0 {
                    Text("\(-days)")
                    Text(" 天")
                } else {
                    Text("🎉")
                }
            }
            .foregroundStyle(.textHighlight1)
            .font(.system(size: FontSizes.bodyText, weight: .semibold))
        }
    }
}

// 更新 Preview Provider 以包含 onTapToEdit
#Preview {
    do {
        let schema = Schema([
            Folder.self, Milestone.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let folder = Folder(name: "全部里程碑")
        folder.type = .all
        
        let milestone = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", date: formatter.date(from: "2025-04-25")!)
        milestone.isPinned = false
        
        context.insert(folder)
        context.insert(milestone)
        
        // 确保 Preview 调用与新的初始化器匹配
        return MilestoneView(
            folder: folder,
            milestone: milestone,
        )
        .modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
