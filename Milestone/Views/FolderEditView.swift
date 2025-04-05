import SwiftUI
import SwiftData

struct FolderEditView: View {
    
    @Query private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var folder: Folder
    @State private var folderName = ""
    @State private var showAlert = false
    @FocusState private var isFocused: Bool
    
    /**
     检查文件夹名称是否被占用
     */
    private func exists() -> Bool {
        if folderName == Constants.FOLDER_ALL || folderName == Constants.FOLDER_DELETED {
            return true
        }
        return folders.contains { $0.name.lowercased() == folderName.lowercased() && $0.id != folder.id}
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundStyle(.textHighlight1)
                    
                    Spacer()
                    
                    Text("重新命名文件夹")
                        .font(.system(size: FontSizes.bodyText, weight: .semibold))
                    
                    Spacer()
                    
                    Button("完成") {
                        if exists() {
                            showAlert = true
                        } else {
                            folder.name = folderName
                            try? modelContext.save()
                            dismiss()
                        }
                    }
                    .foregroundStyle(.textHighlight1)
                    .disabled(folderName.isEmpty)
                }
                .padding()
                
                SelectableTextField(text: $folderName, isFirstResponder: Binding.constant(true), placeholder: "名称")
                    .frame(height: 24)
                    .padding(.vertical, 12)
                    .padding(.horizontal, Distances.itemPaddingH)
                    .background(.areaItem)
                    .cornerRadius(21)
                    .padding(.horizontal)
                    .focused($isFocused)
                    .font(.system(size: FontSizes.bodyText))
                    
                Spacer()
            }
            .alert("名称已被使用", isPresented: $showAlert) {
                Button("好", role: .cancel) {}
            } message: {
                Text("请选取一个不同的名称")
            }
        }
        .onAppear {
            folderName = folder.name
            showAlert = false
            isFocused = true
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
        
        return FolderEditView(folder: folder1).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
