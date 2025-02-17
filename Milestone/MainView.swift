import SwiftUI
import SwiftData
import Foundation

struct MainView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: \Milestone.date, order: .forward) private var milestones: [Milestone]
    @Query(sort: \Tag.content, order: .forward) private var tags: [Tag]
    
    @State private var selectedTag: String = "#所有标签"
    @State private var showAddView = false
    
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                HStack {
                    // 主题栏
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
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
                .padding(.leading, 28)
                .padding(.vertical, 12)
                
                if (milestones.isEmpty) {
                    NoDataView()
                        .padding(.horizontal, 20)
                } else {
                    // 标签筛选栏
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                Spacer()
                                    .frame(width: 20)
                                ForEach(allTags, id: \.self) { tag in
                                    Button(action: {
                                        selectedTag = tag.content
                                    }) {
                                        Text(tag.content)
                                            .font(.system(size: 14))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .background(selectedTag == tag.content ? .accent : Color.tag)
                                            .foregroundColor(selectedTag == tag.content ? .white : .grayText)
                                            .cornerRadius(8)
                                    }
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedTag == tag.content ? .accent : .grayBorder, lineWidth: 1)
                                    )
                                    .padding(.trailing, 10)
                                }
                            }
                        }
                        
                        HStack {
                            Group {
                                if (selectedTag == "#所有标签") {
                                    Text("已显示所有里程碑。")
                                } else {
                                    Text("显示符合所选标签的里程碑：\(selectedTag)。")
                                }
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(.grayText)
                            
                            Spacer()
                        }
                        .padding(.leading, 30)
                        .padding(.top, 10)
                        .padding(.bottom, 12)
                    }
                    
                    ScrollView {
                        ForEach(filterAndSortMilestone, id: \.self) { milestone in
                            HStack(spacing: 0) {
                                let days = daysBetween(Date(), milestone.date)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(spacing: 0) {
                                        Text(milestone.title)
                                            .font(.system(size: 16))
                                        if (days == 0) {
                                            Text("就是今天！")
                                                .font(.system(size: 16))
                                                .foregroundStyle(.accent)
                                        } else if (days > 0) {
                                            Text("还有")
                                                .font(.system(size: 16))
                                        } else {
                                            Text("已经")
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    HStack(spacing: 0) {
                                        if (!milestone.tag.isEmpty) {
                                            Text(milestone.tag)
                                                .font(.system(size: 12))
                                                .foregroundStyle(.grayText)
                                        }
                                        if (!milestone.tag.isEmpty && !milestone.remark.isEmpty) {
                                            Text("|")
                                                .font(.system(size: 8))
                                                .foregroundColor(.grayBorder)
                                                .padding(.horizontal, 4)
                                        }
                                        if (!milestone.remark.isEmpty) {
                                            Text(milestone.remark)
                                                .font(.system(size: 12))
                                                .foregroundStyle(.grayText)
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(.vertical, 10)
                                .padding(.leading, 16)
                                
                                Spacer()
                                
                                if (days != 0) {
                                    Text("\(abs(days))")
                                        .font(.system(size: 18, design: .rounded))
                                        .fontWeight(.medium)
                                        .foregroundStyle(days > 0 ? .blueDays: .accent)
                                    Text("天")
                                        .font(.system(size: 18, design: .rounded))
                                        .foregroundStyle(days > 0 ? .blueDays: .accent)
                                        .padding(.trailing, 16)
                                } else {
                                    Text("🎉")
                                        .font(.system(size: 18, design: .rounded))
                                        .padding(.trailing, 16)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.tag)
                            )
                            .contextMenu {
                                Button {
                                    
                                } label: {
                                    Label("编辑", systemImage: "pencil.tip.crop.circle")
                                }
                                Button(role: .destructive) {
                                    modelContext.delete(milestone)
                                    do {
                                        try modelContext.save()
                                    } catch {
                                        print("删除失败: \(error.localizedDescription)")
                                    }
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .padding(.horizontal, 14)
                            .padding(.bottom, 10)
                        }
                    }
                }
            }
            
            if !milestones.isEmpty {
                VStack(spacing: 0) {
                    Spacer()
                    
                    Button {
                        showAddView = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 54))
                    }
                    .padding(.bottom, 40)
                }
                .sheet(isPresented: $showAddView) {
                    AddEditView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    /**
     标签处理
     */
    var allTags: [Tag] {
        if tags.isEmpty {
            return []
        }
        return [Tag(content: "#所有标签") ] + tags
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
    
    /**
     查询 2 个日期间的天数
     */
    func daysBetween(_ from: Date, _ to: Date) -> Int {
        let calendar = Calendar.current
        let startOfFrom = calendar.startOfDay(for: from)
        let startOfTo = calendar.startOfDay(for: to)
        let components = calendar.dateComponents([.day], from: startOfFrom, to: startOfTo)
        return components.day ?? 0
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
