import SwiftUI

struct FolderItemView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var folder: Folder
    var system = false
    var isEditMode = false
    @State private var showEditFolder = false
    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false
    
    // 删除按钮宽度
    private let deleteButtonWidth: CGFloat = 80
    // 期望的间距
    private let spacing: CGFloat = 10
    // 最大偏移量
    private let maxOffset: CGFloat = 90 // 80 + 10
    
    // 计算删除按钮的大小，基于滑动距离
    private var deleteButtonScale: CGFloat {
        let currentRatio = min(abs(offset) / maxOffset, 1.0)
        // 从0.5开始变为1.0，使按钮有一个明显的放大效果
        return 0.5 + (0.5 * currentRatio)
    }
    
    // 计算删除按钮位置的偏移量
    private var deleteButtonOffset: CGFloat {
        // 随着滑动增加，按钮应该向左移动以保持间距
        return min(10, 10 * (1 - abs(offset) / maxOffset))
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // 删除按钮背景层 
            Button {
                withAnimation(.spring()) {
                    if !system {
                        modelContext.delete(folder)
                    }
                }
            } label: {
                VStack {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.white)
                }
                .frame(width: deleteButtonWidth, height: 50)
                .background(Color.red)
                .cornerRadius(21)
            }
            .scaleEffect(deleteButtonScale)
            .opacity(offset < 0 ? 1 : 0) // 只在滑动时显示
            .offset(x: -14 - deleteButtonOffset) // 调整位置，考虑外部padding
            
            // 主内容层
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "folder")
                    .font(.system(size: FontSize.bodyText, weight: .medium))
                    .imageScale(.large)
                    .kerning(0.18)
                    .foregroundStyle((system && isEditMode) ? .textPlaceholderDisable : .textHighlight1)
                    .frame(width: 24, alignment: .top)
                
                Text(folder.name)
                    .font(.system(size: FontSize.bodyText, weight: .medium))
                    .kerning(0.16)
                    .foregroundStyle((system && isEditMode) ? .textPlaceholderDisable : .textBody)
                
                Spacer()
                
                if !isEditMode {
                    Text("12")
                        .font(.system(size: FontSize.bodyText, weight: .medium))
                        .foregroundStyle(.textNote)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: FontSize.bodyText, weight: .medium))
                        .imageScale(.large)
                        .foregroundStyle(.textPlaceholderDisable)
                }
                
                if !system && isEditMode {
                    HStack(spacing: 10) {
                        Menu {
                            Button(action: {
                                showEditFolder = true
                            }) {
                                Label("重新命名", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                modelContext.delete(folder)
                            }) {
                                Label("删除", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: FontSize.bodyText, weight: .medium))
                                .imageScale(.large)
                                .foregroundStyle(.textHighlight1)
                                .frame(width: 24, alignment: .top)
                        }
                        
                        Rectangle()
                            .fill(.textNote.opacity(0.3))
                            .frame(width: 1, height: 16)
                            .padding(.horizontal, 2)
                        
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: FontSize.bodyText, weight: .medium))
                            .imageScale(.large)
                            .foregroundStyle(.textNote)
                            .frame(width: 24, alignment: .top)
                    }
                    .transition(AnyTransition.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                            .combined(with: AnyTransition.opacity)
                    ))
                }
            }
            .sheet(isPresented: $showEditFolder) {
                FolderEditView(folder: folder)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .leading)
            .background(.areaItem)
            .cornerRadius(21)
            .padding(.horizontal, 14)
            .offset(x: offset)
            .gesture(
                !system && !isEditMode ?
                DragGesture()
                    .onChanged { gesture in
                        let dragAmount = gesture.translation.width
                        // 只允许向左滑动
                        if dragAmount < 0 {
                            offset = max(dragAmount, -maxOffset)
                        } else if offset != 0 {
                            // 允许用户滑回原位
                            offset = min(0, dragAmount)
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring()) {
                            if offset < -40 {
                                // 显示删除按钮
                                offset = -maxOffset
                                showDeleteButton = true
                            } else {
                                // 恢复原位
                                offset = 0
                                showDeleteButton = false
                            }
                        }
                    } : nil
            )
        }
    }
}

#Preview {
    let folder = Folder(name: "全部里程碑", sortOrder:  1)
    FolderItemView(folder: folder)
}
