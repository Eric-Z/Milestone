import SwiftUI
import SwiftData
import SwipeActions

struct MilestoneListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var milestones: [Milestone]
    
    @State private var filteredMilestone: [Milestone] = []
    @State private var isAddMode = false;
    
    @Namespace private var animation
    
    @State var state: SwipeState = .untouched
    
    // 用于存储每个MilestoneView的高度信息
    @State private var milestoneSizes: [String: CGSize] = [:]
    
    var folder: Folder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(folder.name)")
                        .font(.system(size: FontSizes.largeTitleText, weight: .semibold))
                    
                    Group {
                        if filteredMilestone.isEmpty {
                            Text("暂无里程碑")
                                .font(.system(size: FontSizes.largeNoteText))
                        } else {
                            HStack(spacing: 0) {
                                Text("\(filteredMilestone.count)")
                                    .font(.system(size: FontSizes.largeNoteNumber))
                                Text("个里程碑")
                                    .font(.system(size: FontSizes.largeNoteText))
                            }
                        }
                    }
                    .foregroundStyle(.textNote)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 0)
            .padding(.bottom, 12)
            
            if filteredMilestone.isEmpty && !isAddMode {
                NoMilestoneView()
            } else {
                ScrollView {
                    ForEach(filteredMilestone) { milestone in
                        MilestoneView(folder: folder, milestone: milestone)
                            .padding(.horizontal, Distances.itemPaddingH)
                            .padding(.bottom, Distances.itemGap)
                            .allowMultitouching(false)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            // 获取并存储高度
                                            milestoneSizes[milestone.id.uuidString] = geo.size
                                        }
                                        .onChange(of: geo.size) { oldValue, newValue in
                                            milestoneSizes[milestone.id.uuidString] = newValue
                                        }
                                }
                            )
                            .addSwipeAction(state: $state) {
                                Leading {
                                    if let size = milestoneSizes[milestone.id.uuidString] {
                                        HStack(spacing: 10) {
                                            Button {
                                                milestone.pinned.toggle()
                                            } label: {
                                                Image(systemName: milestone.pinned ? "pin.slash" : "pin.fill")
                                                    .font(.system(size: 17))
                                                    .frame(width: 64)
                                                    .frame(height: size.height - 4)
                                            }
                                            .foregroundStyle(.white)
                                            .background(.textHighlight1)
                                            .cornerRadius(21)
                                        }
                                        .padding(.leading, Distances.itemPaddingH)
                                    }
                                }
                                Trailing {
                                    if let size = milestoneSizes[milestone.id.uuidString] {
                                        HStack(spacing: 10) {
                                            Button {
                                            } label: {
                                                Image(systemName: "folder.fill")
                                                    .font(.system(size: 17))
                                                    .frame(width: 64)
                                                    .frame(height: size.height - 4)
                                            }
                                            .foregroundStyle(.white)
                                            .background(.purple6)
                                            .cornerRadius(21)
                                            
                                            Button {
                                                // 添加你的操作逻辑
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.system(size: 17))
                                                    .frame(width: 64)
                                                    .frame(height: size.height - 4)
                                                    .contentShape(Rectangle())
                                            }
                                            .foregroundStyle(.white)
                                            .background(.red)
                                            .cornerRadius(21)
                                        }
                                        .padding(.trailing, Distances.itemPaddingH)
                                    }
                                }
                            }
                    }
                }
            }
            
            if isAddMode {
                MilestoneAddView(folder: folder)
                    .padding(.horizontal, Distances.listPadding)
                    .matchedGeometryEffect(id: "NewMilestone", in: animation)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(
            VStack {
                Spacer()
                
                if !isAddMode {
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.25)) {
                            isAddMode = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(Color.textHighlight1)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .matchedGeometryEffect(id: "NewMilestone", in: animation)
                            .padding(.bottom, 50)
                    }
                }
            }
                .ignoresSafeArea(.container, edges: .bottom)
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17))
                            .foregroundStyle(.textHighlight1)
                        
                        Text("文件夹")
                            .font(.system(size: 17))
                            .foregroundStyle(.textHighlight1)
                    }
                    .padding(.vertical, 11)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                }
            }
        }
        .onAppear {
            filteredMilestone = milestones.filter { milestone in
                milestone.folderId == folder.id.uuidString
            }.sorted { m1, m2 in
                // 首先按pinned状态排序
                if m1.pinned != m2.pinned {
                    return m1.pinned
                }
                
                let now = Date()
                let diff1 = m1.date.timeIntervalSince(now)
                let diff2 = m2.date.timeIntervalSince(now)
                
                // 如果两个都是未来或都是过去，按照接近当前时间的排序
                if (diff1 >= 0 && diff2 >= 0) || (diff1 < 0 && diff2 < 0) {
                    return abs(diff1) < abs(diff2)
                }
                
                // 未来时间排在过去时间前面
                return diff1 >= 0
            }
        }
    }
}

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
        
        let folder = Folder(name: "旅行", sortOrder: 1)
        
        let milestone1 = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", remark: "冲绳一下", date: formatter.date(from: "2025-04-25")!)
        milestone1.pinned = true
        
        let milestone2 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", remark: "", date: formatter.date(from: "2025-06-25")!)
        milestone2.pinned = false
        
        context.insert(folder)
        context.insert(milestone1)
        context.insert(milestone2)
        
        return MilestoneListView(folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
