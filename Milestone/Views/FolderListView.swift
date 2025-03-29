import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var folders: [Folder]
    var isEditMode: Bool
    
    var body: some View {
        List {
            ForEach(folders, id: \.self) { folder in
                FolderItemView(folder: folder, isEditMode: isEditMode)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .listRowSpacing(10)
        .listStyle(.plain)
    }
}
