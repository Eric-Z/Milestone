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
    
    // MARK: - 主视图
    var body: some View {
        NavigationStack {
            VStack {
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
            .navigationTitle("重新命名文件夹")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                    }
                    .tint(.textHighlight1)
                    .disabled(folderName.isEmpty)
                }
            }
        }
        .accentColor(.textHighlight1)
        .alert("名称已被使用", isPresented: $showAlert) {
            Button("好", role: .cancel) {}
        } message: {
            Text("请选取一个不同的名称")
        }
        .onAppear {
            folderName = folder.name
            showAlert = false
            isFocused = true
        }
    }
    
    // MARK: - 方法
    /**
     检查文件夹名称是否被占用
     */
    private func exists() -> Bool {
        if self.folderName == Constants.FOLDER_ALL || self.folderName == Constants.FOLDER_DELETED {
            return true
        }
        return folders.contains { $0.name.lowercased() == self.folderName.lowercased() && $0.id != folder.id}
    }
    
    /**
     保存文件夹
     */
    private func save() {
        if exists() {
            self.showAlert = true
        } else {
            let folder = Folder(name: self.folderName)
            self.modelContext.insert(folder)
            try? self.modelContext.save()
            dismiss()
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
        
        let folder = Folder(name: "生日")
        context.insert(folder)
        
        return FolderEditView(folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
