import SwiftUI

struct FolderItemView: View {
    
    var folder: Folder
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "folder")
                .font(.system(size: 18, weight: .medium))
                .kerning(0.18)
                .foregroundStyle(AppColors.text_highlight_1())
                .frame(width: 24, alignment: .top)
            
            Text(folder.name)
                .font(.system(size: 16, weight: .medium))
                .kerning(0.16)
                .foregroundStyle(AppColors.text_body())
            
            Spacer()
            
            Text("12")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.text_note())
            
            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AppColors.text_placeholder_disable())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.area_item())
        .cornerRadius(21)
        .padding(.horizontal, 14)
    }
}

#Preview {
    var folder = Folder(name: "全部里程碑", sortOrder:  1)
    FolderItemView(folder: folder)
}
