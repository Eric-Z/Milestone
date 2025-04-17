import SwiftUI
import SwiftData

struct FolderView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query private var milestones: [Milestone]
    
    var folder: Folder
    var isEditMode = false
    
    @State private var showEditFolder = false
    @State private var itemHeight: CGFloat = 50
    
    var body: some View {
        // 主内容层
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "folder")
                .font(.system(size: FontSizes.bodyText, weight: .medium))
                .imageScale(.large)
                .foregroundStyle((folder.isSystem && isEditMode) ? .textPlaceholderDisable : .textHighlight1)
                .frame(width: 24, alignment: .top)
            
            Text(folder.name)
                .font(.system(size: FontSizes.bodyText, weight: .medium))
                .foregroundStyle((folder.isSystem && isEditMode) ? .textPlaceholderDisable : .textBody)
            
            Spacer()
            
            if !isEditMode {
                Text("\(countFolderMilestone())")
                    .font(.system(size: FontSizes.bodyText, weight: .medium))
                    .foregroundStyle(.textNote)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: FontSizes.bodyText, weight: .medium))
                    .imageScale(.large)
                    .foregroundStyle(.textPlaceholderDisable)
            }
            
            if !folder.isSystem && isEditMode {
                HStack(spacing: 10) {
                    Menu {
                        Button(action: {
                            showEditFolder = true
                        }) {
                            Label("重新命名", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            modelContext.delete(folder)
                            try? modelContext.save()
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: FontSizes.bodyText, weight: .medium))
                            .imageScale(.large)
                            .foregroundStyle(.textHighlight1)
                            .frame(width: 24, alignment: .center)
                    }
                    
                    Rectangle()
                        .fill(.textNote.opacity(0.3))
                        .frame(width: 1, height: 16)
                        .padding(.horizontal, 2)
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .imageScale(.large)
                        .foregroundStyle(.textNote)
                        .frame(width: 24, alignment: .center)
                        .allowsHitTesting(false)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.areaItem)
        .cornerRadius(21)
        .padding(.horizontal, 14)
        .frame(height: 50)
    }
    
    /**
     统计文件夹下的里程碑数量
     */
    private func countFolderMilestone() -> Int {
        if (folder.id == Constants.FOLDER_ALL_UUID) {
            return milestones.count;
        }
        return milestones.filter { $0.folderId == folder.id.uuidString }.count
    }
}

#Preview {
    let folder = Folder(name: "全部里程碑", sortOrder:  1)
    FolderView(folder: folder)
}
