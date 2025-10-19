import SwiftUI
import SwiftData
import Combine

struct FolderListView: View {
    
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var allFolders: [Folder] = []
    
    @State private var showEdit = false
    @State private var showAdd = false
    
    @State private var editingFolder: Folder? = nil
    @State private var selectedFolder: Folder? = nil
    @State private var folderToDelete: Folder? = nil
    @State private var searchText = ""
    
    let showAddMilestonePublisher = ShowAddMilestonePublisher.shared
    
    // MARK: - 主视图
    var body: some View {
        NavigationStack {
            List {
                ForEach(self.allFolders) { folder in
                    FolderView(folder: folder, isEditMode: self.showEdit)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .onTapGesture {
                            if !showEdit {
                                selectedFolder = folder
                            }
                        }
                        .swipeActions(allowsFullSwipe: false) {
                            if (folder.type == .normal) {
                                Button(role: .destructive) {
                                    self.folderToDelete = folder
                                } label: {
                                    Image(systemName: "trash")
                                }
                                
                                Button {
                                    self.editingFolder = folder
                                } label: {
                                    Image(systemName: "square.and.pencil")
                                }
                                .tint(.purple6)
                            }
                        }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { self.selectedFolder != nil },
                set: {
                    if !$0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            refresh()
                        }
                    }
                    self.selectedFolder = $0 ? self.selectedFolder : nil
                }
            )) {
                if let folder = self.selectedFolder {
                    MilestoneListView(folder: folder)
                }
            }
            .navigationTitle("Milestones")
            .toolbar {
                ToolbarItem {
                    Button {
                        self.showAdd.toggle()
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .fontWeight(.medium)
                    }
                }
                
                ToolbarSpacer(.fixed)
                
                ToolbarItem {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                            self.showEdit.toggle()
                        }
                    } label: {
                        if (self.showEdit) {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                            
                        } else {
                            Text("Edit")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .toolbar {
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
                ToolbarSpacer(.flexible, placement: .bottomBar)
                
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        self.addMilestone()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, placement: .automatic, prompt: "搜索")
            .searchToolbarBehavior(.minimize)
            .onAppear {
                refresh()
            }
            .sheet(isPresented: $showAdd, onDismiss: {
                refresh()
            }) {
                FolderAddView()
            }
            .sheet(item: $editingFolder, onDismiss: {
                
                refresh()
            }) { folderToEdit in
                FolderEditView(folder: folderToEdit)
            }
            .alert(
                "删除文件夹",
                isPresented: Binding(
                    get: { folderToDelete != nil },
                    set: { if !$0 { folderToDelete = nil } }
                ),
                presenting: folderToDelete
            ) { folder in
                Button("删除", role: .destructive) {
                    delete(folder: folder)
                }
                Button("取消", role: .cancel) {
                    folderToDelete = nil
                }
            } message: { folder in
                Text("这个文件夹将被删除。此操作不能撤销。")
            }
        }
    }
    
    // MARK: - 方法
    /**
     删除文件夹
     */
    private func delete(folder: Folder) {
        if (folder.type != .normal) {
            return
        }
        
        for milestone in self.milestones {
            if milestone.folderId == folder.id.uuidString {
                milestone.folderId = Constants.FOLDER_DELETED_UUID.uuidString
                milestone.deleteDate = Date()
            }
        }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            modelContext.delete(folder)
            try? modelContext.save()
            self.folderToDelete = nil
            self.refresh()
        }
    }
    
    /**
     刷新文件夹列表
     */
    private func refresh() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            self.allFolders = []
            self.allFolders.insert(contentsOf: folders, at: 0)
            
            // 添加全部里程碑文件夹
            let allFolder = Folder(name: Constants.FOLDER_ALL)
            allFolder.id = Constants.FOLDER_ALL_UUID
            allFolder.type = .all
            self.allFolders.insert(allFolder, at: 0)
            
            // 添加置顶文件夹
            if self.milestones.first(where: { $0.isPinned }) != nil {
                let pinnedFolder = Folder(name: Constants.FOLDER_PINNED)
                pinnedFolder.id = Constants.FOLDER_PINNED_UUID
                pinnedFolder.type = .pinned
                self.allFolders.insert(pinnedFolder, at: 1)
            }
            
            // 添加最近删除文件夹
            if self.milestones.first(where: { $0.deleteDate != nil }) != nil {
                let deletedFolder = Folder(name: Constants.FOLDER_DELETED)
                deletedFolder.id = Constants.FOLDER_DELETED_UUID
                deletedFolder.type = .deleted
                self.allFolders.insert(deletedFolder, at: allFolders.count)
            }
        }
    }
    
    /**
     点击添加里程碑按钮
     */
    private func addMilestone() {
        let allMilestoneFolder = self.allFolders.first(where: { $0.id == Constants.FOLDER_ALL_UUID })
        self.showAddMilestonePublisher.show = true
        self.selectedFolder = allMilestoneFolder
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
        
        let folder1 = Folder(name: "旅行")
        let folder2 = Folder(name: "生日")
        let folder3 = Folder(name: "纪念日")
        let folder4 = Folder(name: "节假日")
        let folder5 = Folder(name: "演唱会")
        
        context.insert(folder1)
        context.insert(folder2)
        context.insert(folder3)
        context.insert(folder4)
        context.insert(folder5)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let milestone = Milestone(folderId: folder1.id.uuidString, title: "冲绳之旅", date: formatter.date(from: "2025-04-25")!)
        milestone.isPinned = true
        
        context.insert(milestone)
        
        return FolderListView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
