import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentEditingFolder: Folder?
    
    var folders: [Folder]
    var isEditMode: Bool
    
    var body: some View {
        List(folders) { folder in
            FolderItemView(folder: folder, isEditMode: isEditMode)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        modelContext.delete(folder)
                        try? modelContext.save()
                    } label: {
                        Label("删除", systemImage: "trash")
                    }
                    
                    Button {
                        currentEditingFolder = folder
                    } label: {
                        Label("编辑", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
        }
        .listRowSpacing(10)
        .listStyle(.plain)
        .sheet(item: $currentEditingFolder) { folder in
            FolderEditView(folder: folder)
        }
    }
}
