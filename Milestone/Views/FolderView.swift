import SwiftUI
import SwiftData

struct FolderView: View {
    
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    
    var folder: Folder
    var isEditMode = false
    
    @State private var showEditFolder = false
    @State private var folderToDelete: Folder? = nil
    
    // MARK: - 主视图
    var body: some View {
        HStack(spacing: 0) {
            let icon = folder.type == .deleted ? "trash" : "folder"
            
            Image(systemName: icon)
                .fontWeight(.medium)
                .imageScale(.large)
                .foregroundStyle(.textHighlight1)
                .padding(.trailing, 12)
            
            Text("\(folder.name)")
            
            Spacer()
            
            if !self.isEditMode {
                Text("\(countFolderMilestone())")
                    .fontWeight(.medium)
                    .foregroundStyle(.labelSecondary)
                    .padding(.trailing, 16)
                
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
                    .imageScale(.small)
                    .foregroundStyle(.labelTertiary)
            }
            
            if folder.type == .normal && isEditMode {
                HStack(spacing: 10) {
                    Menu {
                        Button(action: {
                            self.showEditFolder = true
                        }) {
                            Label("重新命名", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            self.folderToDelete = folder
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .fontWeight(.medium)
                            .imageScale(.large)
                            .foregroundStyle(.textHighlight1)
                            .frame(width: 24, alignment: .center)
                    }
                }
                .transition(AnyTransition.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .trailing)
                        .combined(with: AnyTransition.opacity)
                ))
            }
        }
        .sheet(isPresented: $showEditFolder) {
            FolderEditView(folder: folder)
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
    
    // MARK: -方法
    /**
     统计文件夹下的里程碑数量
     */
    private func countFolderMilestone() -> Int {
        if (folder.id == Constants.FOLDER_ALL_UUID) {
            return self.milestones.filter { $0.deleteDate == nil }.count
        }
        if (folder.id == Constants.FOLDER_DELETED_UUID) {
            return self.milestones.filter { $0.deleteDate != nil }.count
        }
        if (folder.id == Constants.FOLDER_PINNED_UUID) {
            return self.milestones.filter { $0.isPinned }.count
        }
        return self.milestones.filter { $0.folderId == folder.id.uuidString }.count
    }
    
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
        }
    }
}

#Preview {
    let folder = Folder(name: "全部里程碑")
    FolderView(folder: folder)
}
