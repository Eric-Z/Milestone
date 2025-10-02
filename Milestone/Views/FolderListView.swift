import SwiftUI
import SwiftData
import Combine

struct FolderListView: View {
    
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var allFolders: [Folder] = []
    
    @State private var showEdit = false
    @State private var showAddFolder = false
    
    @State private var deletingFolder: Folder? = nil
    @State private var editingFolder: Folder? = nil
    @State private var selectedFolder: Folder? = nil
    
    @State private var searchText = ""
    
    let showAddMilestonePublisher = ShowAddMilestonePublisher.shared
    
    // MARK: - 主视图
    var body: some View {
        NavigationStack {
            List {
                ForEach(self.allFolders) { folder in
                    FolderView(folder: folder, isEditMode: self.showEdit)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .swipeActions {
                            Button(role: .destructive) {
                            } label: {
                                Image(systemName: "trash")
                            }
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                }
            }
            .navigationTitle("Milestones")
            .toolbar {
                ToolbarItem {
                    Button {
                        self.showAddFolder.toggle()
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
            .searchable(text: $searchText, placement: .automatic, prompt: "搜索")
            .onAppear {
                refresh()
            }
            .sheet(isPresented: $showAddFolder) {
                FolderAddView()
            }
            //            .confirmationDialog(
            //                "文件夹将被删除，此操作不能撤销。",
            //                isPresented: Binding(
            //                    get: { deletingFolder != nil },
            //                    set: { deletingFolder = $0 ? deletingFolder : nil }
            //                ),
            //                titleVisibility: .visible) {
            //                    Button("删除文件夹", role: .destructive) {
            //                        for milestone in milestones {
            //                            if milestone.folderId == deletingFolder!.id.uuidString {
            //                                milestone.folderId = Constants.FOLDER_DELETED_UUID.uuidString
            //                                milestone.deleteDate = Date()
            //                            }
            //                        }
            //                        modelContext.delete(deletingFolder!)
            //                        try? modelContext.save()
            //
            //                        deletingFolder = nil
            //                        refresh()
            //                        UINotificationFeedbackGenerator().notificationOccurred(.success)
            //                    }
            //
            //                    Button("取消", role: .cancel) {
            //                        deletingFolder = nil
            //                    }
            //                }
            //        }
            //        .tint(.textHighlight1)
            //        .onAppear {
            //            refresh()
            //        }
            //        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("MilestoneDeleted"))) { _ in
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //                refresh()
            //            }
            //        }
            //        .onChange(of: folders) { _, _ in
            //            refresh()
            //        }
            //        .onChange(of: milestones) { _, _ in
            //            refresh()
            //        }
            //    }
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
        systemFolder.type = .all
        allFolders.insert(systemFolder, at: 0)
        
        let descriptor = FetchDescriptor<Milestone>()
        let latestMilestones = (try? modelContext.fetch(descriptor)) ?? []
        
        // 添加最近删除文件夹
        if latestMilestones.first(where: { $0.deleteDate != nil }) != nil {
            let latestDeleteFolder = Folder(name: Constants.FOLDER_DELETED)
            latestDeleteFolder.id = Constants.FOLDER_DELETED_UUID
            latestDeleteFolder.type = .deleted
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
        
        let folder1 = Folder(name: "旅行")
        let folder2 = Folder(name: "生日")
        let folder3 = Folder(name: "纪念日")
        let folder4 = Folder(name: "节假日")
        let folder5 = Folder(name: "演唱会")
        let folder6 = Folder(name: "测试1")
        let folder7 = Folder(name: "测试2")
        let folder8 = Folder(name: "测试3")
        let folder9 = Folder(name: "测试4")
        let folder10 = Folder(name: "测试5")
        let folder11 = Folder(name: "测试6")
        let folder12 = Folder(name: "测试7")
        let folder13 = Folder(name: "测试8")
        let folder14 = Folder(name: "测试9")
        let folder15 = Folder(name: "测试10")
        
        context.insert(folder1)
        context.insert(folder2)
        context.insert(folder3)
        context.insert(folder4)
        context.insert(folder5)
        context.insert(folder6)
        context.insert(folder7)
        context.insert(folder8)
        context.insert(folder9)
        context.insert(folder10)
        context.insert(folder11)
        context.insert(folder12)
        context.insert(folder13)
        context.insert(folder14)
        context.insert(folder15)
        
        return FolderListView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
