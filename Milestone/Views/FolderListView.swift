import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var folders: [Folder]
    var isEditMode: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(folders, id: \.self) { folder in
                    FolderItemView(folder: folder, isEditMode: isEditMode)
                }
            }
        }
    }
}
