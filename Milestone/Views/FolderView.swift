import SwiftUI
import SwiftData

struct FolderView: View {
    
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext

    @State private var showAddFolder = false
    
    var body: some View {
        ZStack {
            VStack {
                // 编辑按钮
                HStack(alignment: .center, spacing: 16) {
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("编辑")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(AppColors.text_highlight_1())
                    }
                }
                .padding(.leading, 0)
                .padding(.trailing, 16)
                .padding(.vertical, 11)
                
                // 标题
                VStack(alignment: .leading, spacing: 0) {
                    Text("Milestone")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .kerning(0.36)
                        .foregroundColor(AppColors.text_body())
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    HStack(alignment: .center, spacing: 5) {
                        let folderSize = folders.capacity + 2
                        Text("\(folderSize)")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.text_note())
                        
                        Text("个文件夹")
                            .font(.system(size: 14, weight: .semibold))
                            .kerning(0.14)
                            .foregroundColor(AppColors.text_note())
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 0)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .topLeading)

                // 文件夹
                ScrollView {
                    FolderItemView(folder: Folder(name: "全部里程碑", sortOrder: 1))
                    
                    ForEach(folders, id: \.self) { folder in
                        FolderItemView(folder: folder)
                    }
                    
                    FolderItemView(folder: Folder(name: "最近删除", sortOrder: -1))
                }
                
                // 底部按钮
                HStack {
                    Button {
                        showAddFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 17))
                            .foregroundStyle(AppColors.text_highlight_1())
                    }
                    .sheet(isPresented: $showAddFolder) {
                        FolderAddView(isPresented: $showAddFolder)
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 17))
                            .foregroundStyle(AppColors.text_highlight_1())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
            }
        }
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
