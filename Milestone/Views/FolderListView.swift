import SwiftUI
import SwiftData
import Combine

struct FolderListView: View {
    
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var allFolders: [Folder] = []
    
    @State private var showEditFolder = false
    @State private var showAddFolder = false
    
    @State private var deletingFolder: Folder? = nil
    @State private var editingFolder: Folder? = nil
    @State private var selectedFolder: Folder? = nil
    
    @State var closeSwipe = PassthroughSubject<Void, Never> ()
    
    let showAddMilestonePublisher = ShowAddMilestonePublisher.shared
    
    // MARK: - 主视图
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                folderNumber
                folderList
                bottomToolbar
            }
            .navigationTitle("Milestone")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                            closeSwipe.send()
                            showEditFolder.toggle()
                        }
                    } label: {
                        if (self.showEditFolder) {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .foregroundStyle(.textHighlight1)
                                .frame(width: 56, height: 44)
                                .cornerRadius(22)
                        } else {
                            Text("编辑")
                                .fontWeight(.medium)
                                .foregroundStyle(.textHighlight1)
                                .frame(width: 56, height: 44)
                                .cornerRadius(22)
                        }
                    }
                }
            }
            .confirmationDialog(
                "文件夹将被删除，此操作不能撤销。",
                isPresented: Binding(
                    get: { deletingFolder != nil },
                    set: { deletingFolder = $0 ? deletingFolder : nil }
                ),
                titleVisibility: .visible) {
                    Button("删除文件夹", role: .destructive) {
                        for milestone in milestones {
                            if milestone.folderId == deletingFolder!.id.uuidString {
                                milestone.folderId = Constants.FOLDER_DELETED_UUID.uuidString
                                milestone.deleteDate = Date()
                            }
                        }
                        modelContext.delete(deletingFolder!)
                        try? modelContext.save()
                        
                        deletingFolder = nil
                        refresh()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                    
                    Button("取消", role: .cancel) {
                        deletingFolder = nil
                        closeSwipe.send()
                    }
                }
        }
        .tint(.textHighlight1)
        .onAppear {
            refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MilestoneDeleted"))) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refresh()
            }
        }
        .onChange(of: folders) { _, _ in
            refresh()
        }
        .onChange(of: milestones) { _, _ in
            refresh()
        }
    }
    
    // MARK: - 文件夹数量
    private var folderNumber: some View {
        HStack(spacing: 5) {
            Text("\(allFolders.count)")
                .font(.system(size: FontSizes.largeNoteNumber, weight: .semibold, design: .rounded))
                .foregroundColor(.textNote)
            
            Text("个文件夹")
                .font(.system(size: FontSizes.largeNoteText, weight: .semibold))
                .foregroundColor(.textNote)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    // MARK: - 文件夹列表
    private var folderList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                SwipeViewGroup {
                    ForEach(allFolders) { folder in
                        SwipeView {
                            FolderView(folder: folder, isEditMode: showEditFolder)
                                .onTapGesture {
                                    if !showEditFolder {
                                        selectedFolder = folder
                                    }
                                }
                        } trailingActions: { context in
                            if !folder.isSystem && !showEditFolder {
                                Group {
                                    SwipeAction(systemImage: "square.and.pencil", backgroundColor: .purple6) {
                                        editingFolder = folder
                                    }
                                    
                                    SwipeAction(systemImage: "trash", backgroundColor: .red) {
                                        deletingFolder = folder
                                    }
                                    .foregroundStyle(.white)
                                }
                                .onReceive(closeSwipe) { _ in
                                    context.state.wrappedValue = .closed
                                }
                                .foregroundStyle(.white)
                            }
                        }
                        .swipeMinimumDistance(30)
                        .swipeActionCornerRadius(21)
                        .padding(.horizontal, 14)
                    }
                }
            }
        }
        .navigationDestination(isPresented: Binding(
            get: { selectedFolder != nil },
            set: { 
                if !$0 {
                    // 当从里程碑页面返回时刷新数据
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        refresh()
                    }
                }
                selectedFolder = $0 ? selectedFolder : nil
            }
        )) {
            if let folder = selectedFolder {
                MilestoneListView(folder: folder)
            }
        }
        .sheet(item: $editingFolder, onDismiss: { closeSwipe.send() }) { folderToEdit in
            FolderEditView(folder: folderToEdit)
        }
    }
    
    // MARK: - 底栏
    private var bottomToolbar: some View {
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
                addMilestone()
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
     刷新文件夹列表
     */
    private func refresh() {
        allFolders = []
        allFolders.insert(contentsOf: folders, at: 0)
        
        // 添加全部里程碑文件夹
        let systemFolder = Folder(name: Constants.FOLDER_ALL)
        systemFolder.id = Constants.FOLDER_ALL_UUID
        systemFolder.isSystem = true
        allFolders.insert(systemFolder, at: 0)
        
        // 直接从 modelContext 查询最新的里程碑数据
        let descriptor = FetchDescriptor<Milestone>()
        let latestMilestones = (try? modelContext.fetch(descriptor)) ?? []
        
        // 添加最近删除文件夹
        if latestMilestones.first(where: { $0.deleteDate != nil }) != nil {
            let latestDeleteFolder = Folder(name: Constants.FOLDER_DELETED)
            latestDeleteFolder.id = Constants.FOLDER_DELETED_UUID
            latestDeleteFolder.isSystem = true
            allFolders.insert(latestDeleteFolder, at: allFolders.count)
        }
    }
    
    /**
     点击添加里程碑按钮
     */
    private func addMilestone() {
        let allMilestoneFolder = allFolders.first(where: { $0.id == Constants.FOLDER_ALL_UUID })
        showAddMilestonePublisher.show = true
        selectedFolder = allMilestoneFolder
    }
}

class ShowAddMilestonePublisher: ObservableObject {
    static let shared = ShowAddMilestonePublisher()
    @Published var show = false
    
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
        
        let folder1 = Folder(name: "生日")
        let folder2 = Folder(name: "旅游")
        context.insert(folder1)
        context.insert(folder2)
        
        return FolderListView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
