import SwiftUI
import SwiftData

struct FolderView: View {
    
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddFolder = false
    @State private var isEditMode = false
    @State private var isDragging = false
    @State private var currentDragFolder: Folder?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // 编辑按钮
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                            isEditMode.toggle()
                        }
                    } label: {
                        Text(isEditMode ? "完成" : "编辑")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.textHighlight1)
                    }
                }
                .padding(.trailing, 16)
                .padding(.vertical, 11)
                
                // 标题
                VStack(spacing: 0) {
                    Text("Milestone")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .kerning(0.36)
                        .foregroundColor(.textBody)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    HStack(alignment: .center, spacing: 5) {
                        let folderSize = folders.capacity + 2
                        Text("\(folderSize)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.textNote)
                        
                        Text("个文件夹")
                            .font(.system(size: 14, weight: .semibold))
                            .kerning(0.14)
                            .foregroundColor(.textNote)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 0)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // 文件夹
                ScrollView {
                    FolderItemView(folder: Folder(name: "全部里程碑", sortOrder: 0), system: true, isEditMode: isEditMode)
                    
                    ForEach(folders, id: \.self) { folder in
                        FolderItemView(folder: folder, system: false, isEditMode: isEditMode)
                    }
                    
                    FolderItemView(folder: Folder(name: "最近删除", sortOrder: -1), system: true, isEditMode: isEditMode)
                }
                
                // 底部按钮
                HStack(spacing: 0) {
                    Button {
                        showAddFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 17))
                            .foregroundStyle(.textHighlight1)
                            
                    }
                    .sheet(isPresented: $showAddFolder) {
                        FolderAddView()
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 17))
                            .foregroundStyle(.textHighlight1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: Folder
    let folders: [Folder]
    @Binding var currentDrag: Folder?
    @Binding var isDragging: Bool
    let modelContext: ModelContext
    
    func dropEntered(info: DropInfo) {
        guard let currentDrag = currentDrag,
              currentDrag.id != item.id,
              !item.isSystem && !currentDrag.isSystem else { return }
        
        // 获取文件夹的排序顺序
        let fromIndex = folders.firstIndex { $0.id == currentDrag.id } ?? 0
        let toIndex = folders.firstIndex { $0.id == item.id } ?? 0
        
        // 更新排序顺序
        if fromIndex != toIndex {
            // 更新数据库中的排序顺序
            withAnimation {
                let sourceOrder = currentDrag.sortOrder
                
                // 向上移动
                if sourceOrder > item.sortOrder {
                    for folder in folders where folder.sortOrder >= item.sortOrder && folder.sortOrder < sourceOrder {
                        folder.sortOrder += 1
                    }
                    currentDrag.sortOrder = item.sortOrder
                }
                // 向下移动
                else if sourceOrder < item.sortOrder {
                    for folder in folders where folder.sortOrder <= item.sortOrder && folder.sortOrder > sourceOrder {
                        folder.sortOrder -= 1
                    }
                    currentDrag.sortOrder = item.sortOrder
                }
            }
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        isDragging = false
        currentDrag = nil
        try? modelContext.save()
        return true
    }
}

#Preview {
    do {
        let schema = Schema([
            Folder.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let folder1 = Folder(name: "生日", sortOrder: 1)
        let folder2 = Folder(name: "旅游", sortOrder: 2)
        context.insert(folder1)
        context.insert(folder2)
        
        return FolderView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
