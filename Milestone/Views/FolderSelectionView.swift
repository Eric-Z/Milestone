import SwiftUI
import SwiftData

struct FolderSelectionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Folder.name) private var folders: [Folder]
    @State private var allFolders: [Folder] = []
    
    @State private var showNewFilePopOver : Bool = false
    
    let milestones: [Milestone]
    let folder: Folder
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("取消")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.textHighlight1)
                    .onTapGesture {
                        dismiss()
                    }
                
                Spacer()
                
                Text("选择文件夹")
                    .font(.system(size: 17, weight: .semibold))
                
                Spacer()
                
                Text("取消")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.textHighlight1)
                    .opacity(0)
                    .layoutPriority(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            
            HStack {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .imageScale(.large)
                        .foregroundStyle(.textHighlight1)
                        .frame(width: 24, alignment: .top)
                    
                    Text("新建文件夹")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .foregroundStyle(.textHighlight1)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.areaItem)
                .cornerRadius(21)
                .frame(height: 50)
            }
            .padding(.horizontal, Distances.listPadding)
            .padding(.top, 16)
            .onTapGesture {
                showNewFilePopOver.toggle()
            }
            .sheet(isPresented: $showNewFilePopOver, onDismiss: refresh) {
                FolderAddView()
            }
            
            List {
                ForEach(allFolders) { folder in
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "folder")
                            .font(.system(size: FontSizes.bodyText, weight: .medium))
                            .imageScale(.large)
                            .foregroundStyle((folder.isSystem) ? .textPlaceholderDisable : .textHighlight1)
                            .frame(width: 24, alignment: .top)
                        
                        Text(folder.name)
                            .font(.system(size: FontSizes.bodyText, weight: .medium))
                            .foregroundStyle((folder.isSystem) ? .textPlaceholderDisable : .textBody)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.areaItem)
                    .cornerRadius(21)
                    .frame(height: 50)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Distances.listGap, trailing: 0))
                    .onTapGesture {
                        milestones.forEach {
                            $0.folderId = folder.id.uuidString
                            $0.deleteDate = nil
                        }
                        try? modelContext.save()
                        dismiss()
                    }
                }
                .padding(.horizontal, Distances.itemPaddingV)
            }
            .listStyle(.plain)
            .padding(.top, Distances.itemPaddingV)
        }
        .onAppear {
            refresh()
        }
    }
    
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
        
        let folder = Folder(name: "旅行")
        
        let milestone1 = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", remark: "冲绳一下", date: formatter.date(from: "2025-04-25")!)
        milestone1.isPinned = true
        
        let milestone2 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", remark: "", date: formatter.date(from: "2025-06-25")!)
        milestone2.isPinned = false
        
        context.insert(folder)
        context.insert(milestone1)
        context.insert(milestone2)
        
        return FolderSelectionView(milestones: [milestone1, milestone2], folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
