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
        VStack {
            HStack {
                Button("取消") {
                    dismiss()
                }
                .foregroundStyle(.textHighlight1)
                
                Spacer()
                
                Text("新建文件夹")
                    .font(.system(size: FontSizes.bodyText, weight: .semibold))
                
                Spacer()
                
                Button("完成") {
                    if exists() {
                        showAlert = true
                    } else {
                        let folder = Folder(name: folderName)
                        modelContext.insert(folder)
                        try? modelContext.save()
                        dismiss()
                    }
                }
                .foregroundStyle(.textHighlight1)
                .disabled(folderName.isEmpty)
            }
            .padding()
            
            TextField("名称", text: $folderName)
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
        .onAppear {
            folderName = ""
            showAlert = false
            isFocused = true
        }
    }
    
    // MARK: - 方法
    /**
     检查文件夹名称是否被占用
     */
    private func exists() -> Bool {
        if folderName == Constants.FOLDER_ALL || folderName == Constants.FOLDER_DELETED {
            return true
        }
        return folders.contains { $0.name.lowercased() == folderName.lowercased() }
    }
}

#Preview {
    FolderAddView()
}
