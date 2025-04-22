import SwiftUI
import SwiftData

struct FolderListView: View {
    // MARK: - 属性
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var allFolders: [Folder] = []
    @State private var isEditMode = false
    @State private var editingFolder: Folder? = nil
    @State private var showAddFolder = false
    @State private var selectedFolder: Folder? = nil
    
    // 用于将信息传递给MilestoneListView的单例
    let autoShowAddPublisher = AutoShowAddPublisher.shared
    
    // MARK: - 视图构建
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                editButtonView
                titleView
                folderListView
                bottomToolbarView
            }
        }
        .tint(.textHighlight1)
        .onAppear {
            refreshFolders()
        }
        .onChange(of: folders) { _, _ in
            refreshFolders()
        }
    }
    
    // MARK: - 子视图
    private var editButtonView: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                    isEditMode.toggle()
                }
            } label: {
                Text(isEditMode ? "完成" : "编辑")
                    .font(.system(size: FontSizes.bodyText, weight: .medium))
                    .foregroundColor(.textHighlight1)
            }
        }
        .padding(.trailing, 16)
        .padding(.vertical, 11)
    }
    
    private var titleView: some View {
        VStack(spacing: 0) {
            Text("Milestone")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.textBody)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            HStack(alignment: .center, spacing: 5) {
                let folderSize = allFolders.count
                Text("\(folderSize)")
                    .font(.system(size: FontSizes.largeNoteNumber, weight: .semibold, design: .rounded))
                    .foregroundColor(.textNote)
                
                Text("个文件夹")
                    .font(.system(size: FontSizes.largeNoteText, weight: .semibold))
                    .foregroundColor(.textNote)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 0)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private var folderListView: some View {
        List {
            ForEach(allFolders) { folder in
                FolderView(folder: folder, isEditMode: isEditMode)
                    .padding(0)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isEditMode {
                            selectedFolder = folder
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if !folder.isSystem {
                            Button(role: .destructive) {
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.success)
                                deleteFolder(folder)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                            .tint(.red)
                            
                            Button {
                                editingFolder = folder
                            } label: {
                                Label("编辑", systemImage: "square.and.pencil")
                            }
                            .tint(.purple6)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Distances.listGap, trailing: 0))
            }
            .onMove(perform: moveItem)
        }
        .listStyle(.plain)
        .navigationDestination(isPresented: Binding(
            get: { selectedFolder != nil },
            set: { if !$0 { selectedFolder = nil }}
        )) {
            if let folder = selectedFolder {
                MilestoneListView(folder: folder)
            }
        }
        .sheet(item: $editingFolder) { folderToEdit in
            FolderEditView(folder: folderToEdit)
        }
    }
    
    private var bottomToolbarView: some View {
        HStack(spacing: 0) {
            Button {
                showAddFolder = true
            } label: {
                Image(systemName: "folder.badge.plus")
                    .font(.system(size: FontSizes.bodyText))
                    .imageScale(.large)
                    .foregroundStyle(.textHighlight1)
            }
            .sheet(isPresented: $showAddFolder) {
                FolderAddView()
            }
            
            Spacer()
            
            Button {
                addMilestoneButtonTapped()
            } label: {
                Image(systemName: "plus.circle")
                    .font(.system(size: FontSizes.bodyText))
                    .imageScale(.large)
                    .foregroundStyle(.textHighlight1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
    
    // MARK: - 方法
    /**
     移动文件夹项
     */
    func moveItem(from source: IndexSet, to destination: Int) {
        // 阻止移动系统文件夹（索引0）
        if source.contains(0) {
            return
        }
        
        // 如果目标位置是第一个系统文件夹，则移动到第二个位置
        var adjustedDestination = destination
        if destination == 0 {
            adjustedDestination = 1
        }
        
        // 更新内存中的数组
        allFolders.move(fromOffsets: source, toOffset: adjustedDestination)
        
        // 更新文件夹排序号
        updateFolderSortOrder()
    }
    
    /**
     更新文件夹排序号
     */
    private func updateFolderSortOrder() {
        for i in 1..<allFolders.count {
            if !allFolders[i].isSystem {
                allFolders[i].sortOrder = i
            }
        }
        
        // 保存到SwiftData
        saveContext()
    }
    
    /**
     刷新文件夹列表
     */
    private func refreshFolders() {
        allFolders = []
        allFolders.insert(contentsOf: folders, at: 0)
        
        // 添加全部里程碑文件夹
        let systemFolder = Folder(name: Constants.FOLDER_ALL, sortOrder: 0)
        systemFolder.id = Constants.FOLDER_ALL_UUID
        systemFolder.isSystem = true
        allFolders.insert(systemFolder, at: 0)
    }
    
    /**
     删除文件夹
     */
    private func deleteFolder(_ folder: Folder) {
        if allFolders.firstIndex(where: { $0.id == folder.id }) != nil {
            if !folder.isSystem {
                modelContext.delete(folder)
                saveContext()
            }
        }
    }
    
    /**
     保存上下文
     */
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("保存失败: \(error.localizedDescription)")
        }
    }
    
    /**
     点击添加里程碑按钮
     */
    private func addMilestoneButtonTapped() {
        // 查找全部里程碑文件夹
        if let allMilestoneFolder = allFolders.first(where: { $0.id == Constants.FOLDER_ALL_UUID }) {
            // 设置信号，告知MilestoneListView应该自动打开添加视图
            autoShowAddPublisher.shouldAutoShow = true
            
            // 选择全部文件夹，触发导航
            selectedFolder = allMilestoneFolder
        }
    }
}

// 用于在视图之间传递自动显示添加视图的信号
class AutoShowAddPublisher: ObservableObject {
    static let shared = AutoShowAddPublisher()
    @Published var shouldAutoShow = false
    
    private init() {}
}

#Preview {
    do {
        let schema = Schema([
            Folder.self, Milestone.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let folder1 = Folder(name: "生日", sortOrder: 1)
        let folder2 = Folder(name: "旅游", sortOrder: 2)
        context.insert(folder1)
        context.insert(folder2)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let milestone1 = Milestone(folderId: folder2.id.uuidString, title: "冲绳之旅", remark: "冲绳一下", date: formatter.date(from: "2025-04-25")!)
        milestone1.pinned = true
        context.insert(milestone1)
        
        let milestone2 = Milestone(folderId: folder2.id.uuidString, title: "大阪之旅", remark: "", date: formatter.date(from: "2025-06-25")!)
        milestone2.pinned = false
        context.insert(milestone2)
        
        return FolderListView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
