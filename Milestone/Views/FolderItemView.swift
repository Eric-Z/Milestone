import SwiftUI

struct FolderItemView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var folder: Folder
    var system = false
    var isEditMode = false
    @State private var showEditFolder = false
    @State private var offset: CGFloat = 0
    @State private var showDeleteButton = false
    @State private var isDeleting = false
    
    // 删除按钮宽度
    private let deleteButtonWidth: CGFloat = 80
    // 期望的间距
    private let spacing: CGFloat = 10
    // 最大偏移量
    private let maxOffset: CGFloat = 90 // 80 + 10
    
    /**
     计算删除按钮的大小，基于滑动距离
     */
    private var deleteButtonScale: CGFloat {
        let currentRatio = min(abs(offset) / maxOffset, 1.0)
        // 从0.5开始变为1.0，使按钮有一个明显的放大效果
        return 0.5 + (0.5 * currentRatio)
    }
    
    /**
     计算删除按钮位置的偏移量
     */
    private var deleteButtonOffset: CGFloat {
        // 随着滑动增加，按钮应该向左移动以保持间距
        return min(10, 10 * (1 - abs(offset) / maxOffset))
    }
    
    /**
     计算删除按钮的透明度，基于滑动距离
     */
    private var deleteButtonOpacity: Double {
        // 当滑动超过20时才开始显示，并且渐进式增加透明度
        if offset >= 0 { return 0 }
        
        let threshold: CGFloat = 20
        let visibleRange: CGFloat = 60 // 从开始显示到完全显示的距离
        
        if abs(offset) < threshold {
            return 0
        }
        if abs(offset) >= threshold + visibleRange {
            return 1
        }
        // 线性递增透明度
        return Double((abs(offset) - threshold) / visibleRange)
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // 删除按钮背景层
            Button {
                if !system {
                    // 触发删除动画
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDeleting = true
                        offset = -UIScreen.main.bounds.width // 向左滑出屏幕
                    }
                    
                    // 延迟执行实际删除操作
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            modelContext.delete(folder)
                        }
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
            .opacity(deleteButtonOpacity)
            .offset(x: -14 - deleteButtonOffset)
            
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
            .scaleEffect(y: isDeleting ? 0.5 : 1.0)
            .opacity(isDeleting ? 0 : 1)
            .gesture(
                !system && !isEditMode ?
                DragGesture()
                    .onChanged { gesture in
                        let dragAmount = gesture.translation.width
                        // 允许向左滑动超出最大偏移量，不做限制
                        if dragAmount < 0 {
                            // 添加一个阻尼效果，使得超出maxOffset后移动变得更慢
                            if dragAmount < -maxOffset {
                                let extraOffset = dragAmount + maxOffset // 额外超出的距离
                                offset = -maxOffset + (extraOffset * 0.2) // 超出部分只取20%的位移
                            } else {
                                offset = dragAmount
                            }
                        } else if offset != 0 {
                            // 允许用户滑回原位
                            offset = min(0, dragAmount)
                        }
                    }
                    .onEnded { gesture in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.5)) {
                            if offset < -40 {
                                // 无论滑动多远，最终都回弹到maxOffset位置
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
