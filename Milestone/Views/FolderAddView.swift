import SwiftUI
import SwiftData

struct FolderAddView: View {
    
    @Query private var folders: [Folder]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
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
                    .cornerRadius(22)
                    .padding(.horizontal)
                    .focused($isFocused)
                    .font(.system(size: FontSizes.bodyText))
                
                Spacer()
            }
            .navigationTitle("新建文件夹")
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
                        self.save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                    }
                    .tint(.textHighlight1)
                    .disabled(self.folderName.isEmpty)
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
            self.showAlert = false
            self.isFocused = true
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
        return folders.contains { $0.name.lowercased() == self.folderName.lowercased() }
    }
    
    private func save() {
        if exists() {
            self.showAlert = true
        } else {
            let folder = Folder(name: self.folderName)
            modelContext.insert(folder)
            try? modelContext.save()
            dismiss()
        }
    }
}

#Preview {
    FolderAddView()
}
