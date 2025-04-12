import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var allFolders: [Folder] = []
    @State private var isEditMode = false
    @State private var currentEditingFolder: Folder?
    
    @State private var showAddFolder = false
    @State private var showEditFolder = false
    @State private var selectedFolder: Folder? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 编辑按钮
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
                
                // 标题
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
                                        currentEditingFolder = folder
                                        showEditFolder = true
                                    } label: {
                                        Label("编辑", systemImage: "square.and.pencil")
                                    }
                                    .tint(.purple6)
                                }
                            }
                            .sheet(isPresented: $showEditFolder) {
                                if let folderToEdit = currentEditingFolder {
                                    FolderEditView(folder: folderToEdit)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Distances.listGap, trailing: 0))
                    }
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
                
                // 底部按钮
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
        }
        .tint(.textHighlight1)
        .onAppear {
            refreshFolders()
        }
        .onChange(of: folders) { oldValue, newValue in
            refreshFolders()
        }
    }
    
    /**
     刷新文件夹列表
     */
    private func refreshFolders() {
        allFolders = []
        allFolders.insert(contentsOf: folders, at: 0)
        
        let systemFolder = Folder(name: Constants.FOLDER_ALL, sortOrder: 0);
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
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    do {
        let schema = Schema([
            Folder.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let folder1 = Folder(name: "生日", sortOrder: 1)
        let folder2 = Folder(name: "旅游", sortOrder: 2)
        context.insert(folder1)
        context.insert(folder2)
        
        return FolderListView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
