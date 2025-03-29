import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct FolderListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var allFolders: [Folder]
    
    @State var folders: [Folder]
    var isEditMode: Bool
    
    var body: some View {
        List {
            ForEach(folders) { folder in
                FolderItemView(folder: folder, system: folder.isSystem, isEditMode: isEditMode)
            }
            .onMove { indices, newOffset in
                folders.move(fromOffsets: indices, toOffset: newOffset)
                
                // 更新排序顺序
                for i in 0..<folders.count {
                    folders[i].sortOrder = i
                }
            }
            .moveDisabled(!isEditMode)
            .listRowSeparator(.hidden)
            .listRowInsets(.init())
        }
        .listStyle(.plain)
        .listRowSpacing(10)
    }
}
