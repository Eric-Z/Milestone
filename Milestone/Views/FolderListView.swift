import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Query(sort: \Folder.sortOrder) private var allFolders: [Folder]
    
    var isEditMode: Bool
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allFolders) { folder in
                    FolderItemView(folder: folder, system: folder.isSystem, isEditMode: isEditMode)
                }
                .onMove { indices, newOffset in
                    var folders = allFolders
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
            .animation(.easeInOut, value: allFolders.count)
        }
    }
}
