import SwiftUI
import Combine
import SwiftData

struct MilestoneListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query private var milestones: [Milestone]
    
    @State private var filteredMilestones: [Milestone] = []
    
    @State private var showSelectFolder: Bool = false
    @State private var showEditFolder: Bool = false
    @State private var showAddButton: Bool = true
    @State private var showDatePicker: Bool = false
    @State private var showDeleteConfirm: Bool = false
    
    @State private var onAddMode: Bool = false
    @State private var onSelectMode: Bool = false
    
    // 获取自动显示添加视图的信号
    @ObservedObject private var autoShowPublisher = AutoShowAddPublisher.shared
    
    @State var close = PassthroughSubject<Void, Never> ()
    
    var folder: Folder
    
    // MARK: - 主视图
    var body: some View {
        ZStack(alignment: .bottom) {
            mainContent
                .zIndex(0)
            
            if onAddMode {
                maskLayer
                    .zIndex(1)
            }
            
            if onAddMode {
                addOverlay
                    .zIndex(2)
            }
            
            if showAddButton {
                floatingActionButton
                    .zIndex(3)
            }
            
            if onSelectMode && milestones.count >= 1 {
                bottomToolbarView
                    .zIndex(3)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onAppear {
            filterAndSort()
            
            if (folder.id == Constants.FOLDER_DELETED_UUID) {
                showAddButton = false
            }
            
            // 如果收到自动显示添加视图的信号，执行添加
            if autoShowPublisher.shouldAutoShow {
                // 延迟执行以确保视图已完全加载
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    add()
                    // 重置标志，避免影响其他视图
                    autoShowPublisher.shouldAutoShow = false
                }
            }
        }
        .sheet(isPresented: $showEditFolder) {
            FolderEditView(folder: folder)
        }
    }
    
    // MARK: - 主视图
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            listOrEmpty
        }
    }
    
    // MARK: - 标头
    private var header: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                let selectedMilestoneCount = filteredMilestones.count(where: { $0.isChecked })
                
                if onSelectMode && selectedMilestoneCount > 0 {
                    Text("已选定\(selectedMilestoneCount)项")
                        .font(.system(size: FontSizes.largeTitleText, weight: .semibold))
                } else {
                    Text("\(folder.name)")
                        .font(.system(size: FontSizes.largeTitleText, weight: .semibold))
                }
                
                Group {
                    if filteredMilestones.isEmpty {
                        Text("暂无里程碑")
                            .font(.system(size: FontSizes.largeNoteText))
                    } else {
                        HStack(spacing: 5) {
                            Text("\(filteredMilestones.count)")
                                .font(.system(size: FontSizes.largeNoteNumber))
                            Text("个里程碑")
                                .font(.system(size: FontSizes.largeNoteText))
                        }
                    }
                }
                .foregroundStyle(.textNote)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }
    
    // MARK: - 里程碑列表或空页面
    @ViewBuilder
    private var listOrEmpty: some View {
        if filteredMilestones.isEmpty && folder.id != Constants.FOLDER_DELETED_UUID {
            if !onAddMode {
                NoMilestoneView()
                    .transition(.opacity)
            } else {
                Spacer()
            }
        } else {
            milestoneList
        }
    }
    
    // MARK: - 里程碑列表
    private var milestoneList: some View {
        List {
            SwipeViewGroup {
                ForEach(filteredMilestones) { milestone in
                    SwipeView {
                        MilestoneView(
                            folder: folder,
                            onSelectMode: onSelectMode,
                            milestone: milestone
                        )
                        .confirmationDialog("里程碑将被删除，此操作不能撤销。", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                            Button("删除里程碑", role: .destructive) {
                                modelContext.delete(milestone)
                                try? modelContext.save()
                                
                                withAnimation(.spring()) {
                                    filterAndSort()
                                }
                                showDeleteConfirm = false
                            }
                            Button("取消", role: .cancel) {
                                showDeleteConfirm = false
                            }
                        }
                    } leadingActions: { context in
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: milestone.date).day ?? 0
                        
                        if !onSelectMode && !milestone.isEditing {
                            SwipeAction(systemImage: milestone.isPinned ? "pin.slash" : "pin", backgroundColor: days > 0 ? .textHighlight2 : .textHighlight1) {
                                milestone.isPinned.toggle()
                                withAnimation(.spring()) {
                                    filterAndSort()
                                }
                                close.send()
                            }
                            .swipeActionChangeLabelVisibilityOnly(true)
                            .allowSwipeToTrigger()
                            .onReceive(close) { _ in
                                context.state.wrappedValue = .closed
                            }
                            .foregroundStyle(.white)
                        }
                    } trailingActions: { context in
                        if !onSelectMode && !milestone.isEditing {
                            SwipeAction(systemImage: "trash", backgroundColor: .red) {
                                delete(milestone)
                                close.send()
                            }
                            .swipeActionChangeLabelVisibilityOnly(true)
                            .allowSwipeToTrigger()
                            .onReceive(close) { _ in
                                context.state.wrappedValue = .closed
                            }
                            .foregroundStyle(.white)
                        }
                    }
                    .swipeActionCornerRadius(21)
                    .swipeActionWidth(60)
                    .padding(.horizontal, Distances.itemPaddingH)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Distances.listGap, trailing: 0))
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    // MARK: - 遮罩层
    private var maskLayer: some View {
        Color.black.opacity(0.1)
            .ignoresSafeArea()
            .onTapGesture {
                if (self.showDatePicker) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.3)) {
                        self.showDatePicker.toggle()
                    }
                } else {
                    dismiss()
                }
            }
            .transition(.opacity)
    }
    
    // MARK: - 新增里程碑弹框
    private var addOverlay: some View {
        MilestoneAddView(
            folder: folder,
            showDatePicker: $showDatePicker,
            onSave: {
                dismiss()
                filterAndSort()
            }
        )
        .padding(.horizontal, Distances.listPadding)
        .padding(.bottom, 120)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - 新增里程碑按钮
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            Button {
                add()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(Color.textHighlight1)
                    .clipShape(Circle())
                    .padding(.bottom,  50)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .transition(.opacity)
    }
    
    // MARK: - 工具栏
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                    
                    Text("文件夹")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                }
                .padding(.vertical, 11)
            }
        }
        
        if onSelectMode {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                        onSelectMode.toggle()
                        close.send()
                    }
                } label: {
                    Text("完成")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .foregroundColor(.textHighlight1)
                }
            }
        } else {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    if (folder.isSystem) {
                        if (!filteredMilestones.isEmpty) {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                                    onSelectMode.toggle()
                                    close.send()
                                    milestones.forEach { $0.isChecked = false }
                                    try? modelContext.save()
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 17))
                                    .foregroundStyle(.textHighlight1)
                            }
                        }
                    } else {
                        Menu {
                            Button(action: {
                                showEditFolder = true
                            }) {
                                Label("重新命名", systemImage: "pencil")
                            }
                            .disabled(folder.isSystem)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                                    onSelectMode = true
                                    close.send()
                                    milestones.forEach { $0.isChecked = false }
                                    try? modelContext.save()
                                }
                            }) {
                                Label("选择里程碑", systemImage: "checkmark.circle")
                            }
                            .disabled(filteredMilestones.isEmpty)
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 17))
                                .foregroundStyle(.textHighlight1)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 底部菜单栏
    private var bottomToolbarView: some View {
        HStack(spacing: 0) {
            let isAllChecked = filteredMilestones.allSatisfy { $0.isChecked }
            let isAllNotChecked = filteredMilestones.allSatisfy { !$0.isChecked }
            let operateAll = isAllChecked || isAllNotChecked
            Button {
            } label: {
                Group {
                    if (operateAll) {
                        Text("移动全部")
                        
                    } else {
                        Text("移动")
                    }
                }
                .font(.system(size: 17))
                .foregroundStyle(.textHighlight1)
                .onTapGesture {
                    showSelectFolder.toggle()
                }
                .sheet(isPresented: $showSelectFolder, onDismiss: filterAndSort) {
                    let toMoveMilestons = operateAll ? filteredMilestones : filteredMilestones.filter{ $0.isChecked }
                    FolderSelectionView(milestones: toMoveMilestons, folder: folder)
                }
            }
            
            Spacer()
            
            Button {
                if operateAll {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    if folder.id != Constants.FOLDER_DELETED_UUID {
                        filteredMilestones.forEach {
                            $0.folderId = Constants.FOLDER_DELETED_UUID.uuidString
                            $0.deleteDate = Date()
                        }
                        try? modelContext.save()
                    } else {
                        filteredMilestones.forEach { modelContext.delete($0) }
                        try? modelContext.save()
                    }
                    
                    filterAndSort()
                    
                    // 退出编辑模式
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                        onSelectMode = false
                    }
                } else {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    
                    if folder.id != Constants.FOLDER_DELETED_UUID {
                        filteredMilestones.forEach {
                            if $0.isChecked {
                                $0.folderId = Constants.FOLDER_DELETED_UUID.uuidString
                                $0.deleteDate = Date()
                            }
                        }
                        try? modelContext.save()
                    } else {
                        filteredMilestones.forEach {
                            if $0.isChecked {
                                modelContext.delete($0)
                            }
                        }
                        try? modelContext.save()
                    }
                    
                    filterAndSort()
                    
                    // 退出编辑模式
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                        onSelectMode = false
                    }
                }
            } label: {
                if (operateAll) {
                    Text("全部删除")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                } else {
                    Text("删除")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
    
    // MARK: - 方法
    /**
     展示新增里程碑弹窗
     */
    private func add() {
        showAddButton = false
        
        if !onAddMode {
            // 收起键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                onAddMode = true
            }
        }
    }
    
    /**
     隐藏新增/更新里程碑弹窗
     */
    private func dismiss() {
        showAddButton = true
        // 收起键盘
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.spring()) {
            onAddMode = false
        }
    }
    
    /**
     删除里程碑
     */
    private func delete(_ milestone: Milestone) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        if folder.id != Constants.FOLDER_DELETED_UUID {
            milestone.folderId = Constants.FOLDER_DELETED_UUID.uuidString
            milestone.deleteDate = Date()
            try? modelContext.save()
        } else {
            showDeleteConfirm = true
        }
        
        filterAndSort()
    }
    
    /**
     里程碑列表排序
     */
    private func filterAndSort() {
        if folder.id == Constants.FOLDER_DELETED_UUID {
            filteredMilestones = milestones
                .filter { $0.deleteDate != nil }
        } else {
            filteredMilestones = milestones
                .filter { $0.deleteDate == nil }
                .filter { $0.folderId == folder.id.uuidString || folder.id == Constants.FOLDER_ALL_UUID}
        }
        
        filteredMilestones = filteredMilestones
            .sorted { m1, m2 in
                // Pinned items first
                if m1.isPinned != m2.isPinned {
                    return m1.isPinned
                }
                
                // Then sort by date proximity
                let now = Date()
                let diff1 = m1.date.timeIntervalSince(now)
                let diff2 = m2.date.timeIntervalSince(now)
                
                // Future dates before past dates
                if (diff1 >= 0 && diff2 < 0) { return true }
                if (diff1 < 0 && diff2 >= 0) { return false }
                
                // If both future or both past, sort by closeness to now
                return abs(diff1) < abs(diff2)
            }
    }
}

#Preview {
    do {
        let schema = Schema([
            Folder.self, Milestone.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let folder = Folder(name: "旅行")
        
        let milestone1 = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", remark: "冲绳一下", date: formatter.date(from: "2025-04-25")!)
        milestone1.isPinned = true
        
        let milestone2 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", remark: "", date: formatter.date(from: "2025-06-25")!)
        milestone2.isPinned = false
        
        context.insert(folder)
        context.insert(milestone1)
        context.insert(milestone2)
        
        return MilestoneListView(folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
