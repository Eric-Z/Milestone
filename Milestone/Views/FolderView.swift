import SwiftUI
import SwiftData
import UIKit

struct FolderView: View {
    
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentEditingFolder: Folder?
    @State private var showAddFolder = false
    @State private var isEditMode = false
    
    var body: some View {
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
                    let folderSize = folders.count
                    Text("\(folderSize)")
                        .font(.system(size: FontSize.largeNoteNumber, weight: .semibold, design: .rounded))
                        .foregroundColor(.textNote)
                    
                    Text("个文件夹")
                        .font(.system(size: FontSize.largeNoteText, weight: .semibold))
                        .kerning(0.14)
                        .foregroundColor(.textNote)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 0)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            // 文件夹列表
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
            
            // 底部按钮
            HStack(spacing: 0) {
                Button {
                    showAddFolder = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: FontSize.bodyText))
                        .imageScale(.large)
                        .foregroundStyle(.textHighlight1)
                }
                .sheet(isPresented: $showAddFolder) {
                    FolderAddView()
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: FontSize.bodyText))
                        .imageScale(.large)
                        .foregroundStyle(.textHighlight1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
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
