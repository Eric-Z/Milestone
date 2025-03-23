import SwiftUI
import SwiftData

struct FolderAddView: View {
    
    @Query private var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var folderName = ""
    @State private var showAlert = false
    
    /**
     检查文件夹名称是否被占用
     */
    private func exists() -> Bool {
        if folderName == "全部里程碑" || folderName == "最近删除" {
            return true
        }
        return folders.contains { $0.name.lowercased() == folderName.lowercased() }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("名称", text: $folderName)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.areaItem)
                    .cornerRadius(21)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, 4)
            .navigationBarTitle("新建文件夹", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button() {
                        dismiss()
                    } label: {
                        Text("取消")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.textHighlight1)
                    }
                    .padding(.leading, 8)
                ,
                
                trailing:
                    Button {
                        if exists() {
                            showAlert = true
                        } else {
                            let folder = Folder(name: folderName, sortOrder: folders.count + 1)
                            modelContext.insert(folder)
                            dismiss()
                        }
                    } label: {
                        Text("完成")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.textHighlight1)
                    }
                    .padding(.trailing, 8)
                    .disabled(folderName.isEmpty)
            )
            .alert("名称已被使用", isPresented: $showAlert) {
                Button("好", role: .cancel) {}
            } message: {
                Text("请选取一个不同的名称")
            }
        }
        .onAppear {
            folderName = ""
            showAlert = false
        }
    }
}

#Preview {
    FolderAddView()
}
