import SwiftUI

struct FolderItemView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var folder: Folder
    var system = false
    var isEditMode = false
    
    @State private var showEditFolder = false
    @State private var itemHeight: CGFloat = 50
    
    var body: some View {
        // 主内容层
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "folder")
                .font(.system(size: FontSize.bodyText, weight: .medium))
                .imageScale(.large)
                .kerning(0.18)
                .foregroundStyle((system && isEditMode) ? .textPlaceholderDisable : .textHighlight1)
                .frame(width: 24, alignment: .top)
            
            Text(folder.name)
                .font(.system(size: FontSize.bodyText, weight: .medium))
                .kerning(0.16)
                .foregroundStyle((system && isEditMode) ? .textPlaceholderDisable : .textBody)
            
            Spacer()
            
            if !isEditMode {
                Text("12")
                    .font(.system(size: FontSize.bodyText, weight: .medium))
                    .foregroundStyle(.textNote)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: FontSize.bodyText, weight: .medium))
                    .imageScale(.large)
                    .foregroundStyle(.textPlaceholderDisable)
            }
            
            if !system && isEditMode {
                HStack(spacing: 10) {
                    Menu {
                        Button(action: {
                            showEditFolder = true
                        }) {
                            Label("重新命名", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            modelContext.delete(folder)
                        }) {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: FontSize.bodyText, weight: .medium))
                            .imageScale(.large)
                            .foregroundStyle(.textHighlight1)
                            .frame(width: 24, alignment: .top)
                    }
                    
                    Rectangle()
                        .fill(.textNote.opacity(0.3))
                        .frame(width: 1, height: 16)
                        .padding(.horizontal, 2)
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: FontSize.bodyText, weight: .medium))
                        .imageScale(.large)
                        .foregroundStyle(.textNote)
                        .frame(width: 24, alignment: .top)
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
}

#Preview {
    let folder = Folder(name: "全部里程碑", sortOrder:  1)
    FolderItemView(folder: folder)
}
