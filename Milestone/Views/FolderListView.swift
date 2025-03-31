import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Query(sort: \Folder.sortOrder) private var allFolders: [Folder]
    @State private var currentEditingFolder: Folder?
    @State private var showAddFolder = false
    @State private var isEditMode = false
    
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
                            .font(.system(size: 17, weight: .medium))
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
                            .font(.system(size: FontSize.largeNoteNumber, weight: .semibold, design: .rounded))
                            .foregroundColor(.textNote)
                        
                        Text("个文件夹")
                            .font(.system(size: FontSize.largeNoteText, weight: .semibold))
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
                        ZStack {
                            NavigationLink(destination: MilestoneListView(folder: folder)) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            FolderItemView(folder: folder, isEditMode: isEditMode)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                    }
                    .onMove { indices, newOffset in
                        var folders = allFolders
                        folders.move(fromOffsets: indices, toOffset: newOffset)
                        
                        // 更新排序顺序
                        for i in 0..<folders.count {
                            folders[i].sortOrder = i
                        }
                    }
                    .moveDisabled(!isEditMode)
                }
                .listStyle(.plain)
                .listRowSpacing(10)
                .animation(.easeInOut, value: allFolders.count)
                
                // 底部按钮
                HStack(spacing: 0) {
                    Button {
                        showAddFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: FontSize.bodyText))
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
                            .font(.system(size: FontSize.bodyText))
                            .imageScale(.large)
                            .foregroundStyle(.textHighlight1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
            }
        }
        .tint(.textHighlight1)
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
