import SwiftUI
import SwiftData
import UIKit

struct FolderView: View {
    
    @Query(sort: \Folder.sortOrder) private var queryFolders: [Folder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var folders: [Folder] = []
    @State private var showAddFolder = false
    @State private var isEditMode = false
    @State private var draggingItem: Folder?
    
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
                
                // 文件夹
                ScrollView {
                    FolderItemView(folder: Folder(name: "全部里程碑", sortOrder: 0), system: true, isEditMode: isEditMode)
                    
                    ForEach(folders, id: \.self) { folder in
                        FolderItemView(folder: folder, system: false, isEditMode: isEditMode)
                            .onDrag {
                                self.draggingItem = folder
                                return NSItemProvider(object: folder.name as NSString)
                            }
                            .onDrop(of: [.text], delegate: FolderDropDelegate(
                                target: folder,
                                modelContext: modelContext,
                                folders: $folders,
                                draggingItem: $draggingItem
                            ))
                    }
                    
                    FolderItemView(folder: Folder(name: "最近删除", sortOrder: -1), system: true, isEditMode: isEditMode)
                }
                
                // 底部按钮
                HStack(spacing: 0) {
                    Button {
                        showAddFolder = true
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 20))
                            .foregroundStyle(.textHighlight1)
                        
                    }
                    .sheet(isPresented: $showAddFolder) {
                        FolderAddView()
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(.textHighlight1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
            }
        }
        .onAppear {
            folders = queryFolders
        }
        .onChange(of: queryFolders) {
            folders = queryFolders
        }
    }
    
    struct FolderDropDelegate: DropDelegate {
        let target: Folder
        let modelContext: ModelContext
        
        @Binding var folders: [Folder]
        @Binding var draggingItem: Folder?
        
        // 使用类来存储状态
        private let feedbackState = FeedbackState()
        
        func dropEntered(info: DropInfo) {
            guard let draggingItem,
                  draggingItem != target,
                  let fromIndex = folders.firstIndex(of: draggingItem),
                  let toIndex = folders.firstIndex(of: target) else { return }
            
            if !feedbackState.didVibrate {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.prepare()
                impactFeedback.impactOccurred()
                feedbackState.didVibrate = true
            }
            
            withAnimation {
                folders.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                
                for (i, folder) in folders.enumerated() {
                    folder.sortOrder = Int(i + 1)
                }
                
                try? modelContext.save()
            }
        }
        
        func dropExited(info: DropInfo) {
            feedbackState.didVibrate = false
        }
        
        func performDrop(info: DropInfo) -> Bool {
            draggingItem = nil
            feedbackState.didVibrate = false
            return true
        }
        
        // 使用类来存储状态，类是引用类型，可以在非mutating方法中修改
        private class FeedbackState {
            var didVibrate = false
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
