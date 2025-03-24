import SwiftUI

struct FolderItemView: View {
    
    var folder: Folder
    var system = false
    var isEditMode = false
    
    var body: some View {
        HStack(alignment:  .center, spacing: 10) {
            Image(systemName: "folder")
                .font(.system(size: 20, weight: .medium))
                .kerning(0.18)
                .foregroundStyle((system && isEditMode) ? .textPlaceholderDisable : .textHighlight1)
                .frame(width: 24, alignment: .top)
            
            Text(folder.name)
                .font(.system(size: FontSize.bodyText   , weight: .medium))
                .kerning(0.16)
                .foregroundStyle((system && isEditMode) ? .textPlaceholderDisable : .textBody)
            
            Spacer()
            
            if !isEditMode {
                Text("12")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.textNote)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.textPlaceholderDisable)
            }
            
            if !system && isEditMode {
                HStack(spacing: 10) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17, weight: .medium))
                        .kerning(0.18)
                        .foregroundStyle(.textHighlight1)
                        .frame(width: 24, alignment: .top)
                    
                    Rectangle()
                        .fill(.textNote.opacity(0.3))
                        .frame(width: 1, height: 16)
                        .padding(.horizontal, 2)
                    
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 17, weight: .medium))
                        .kerning(0.18)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
        .background(.areaItem)
        .cornerRadius(21)
        .padding(.horizontal, 14)
    }
}

#Preview {
    var folder = Folder(name: "全部里程碑", sortOrder:  1)
    FolderItemView(folder: folder)
}
