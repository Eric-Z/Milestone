import SwiftUI
import Combine
import SwiftData

struct MilestoneListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var milestones: [Milestone]
    
    @State private var filteredMilestones: [Milestone] = []
    @State private var showSelectFolder = false
    @State private var showEditFolder = false
    @State private var showAddButton = true
    @State private var showDatePicker = false
    @State private var showDeleteConfirm = false
    @State private var isAdding = false
    @State private var isSelecting = false
    
    @ObservedObject private var autoShowPublisher = ShowAddMilestonePublisher.shared
    @State private var closeSwipe = PassthroughSubject<Void, Never>()
    
    let folder: Folder
    
    // MARK: - 主视图
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("\(milestones.count) 个里程碑")
                        .font(.system(size: 15))
                        .foregroundStyle(.textNote)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.horizontal)
                
                if (hasPinned()) {
                    HStack(spacing: 0) {
                        Text("置顶")
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                List {
                    
                }
                
                Spacer()
            }
            .navigationTitle(folder.name)
        }
        
        //        ZStack(alignment: .bottom) {
        //            mainContent
        //                .zIndex(0)
        //
        //            if isAdding {
        //                maskLayer
        //                    .zIndex(1)
        //
        //                addOverlay
        //                    .zIndex(2)
        //            }
        //
        //            if showAddButton {
        //                floatingActionButton
        //                    .zIndex(3)
        //            }
        //        }
        //        .toolbar { toolbarContent }
        //        .onAppear {
        //            filterAndSort()
        //
        //            if folder.id == Constants.FOLDER_DELETED_UUID {
        //                showAddButton = false
        //            }
        //
        //            if autoShowPublisher.show {
        //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        //                    add()
        //                    autoShowPublisher.show = false
        //                }
        //            }
        //        }
        //        .sheet(isPresented: $showEditFolder) {
        //            FolderEditView(folder: folder)
        //        }
        //        .safeAreaInset(edge: .bottom) {
        //            if isSelecting && filteredMilestones.count >= 1 {
        //                bottomToolbarView
        //                    .background(.areaBackground)
        //                    .overlay(Divider(), alignment: .top)
        //            }
        //        }
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
                let selectedCount = filteredMilestones.count(where: { $0.isChecked })
                
                Group {
                    if selectedCount > 0 {
                        Text("已选定\(selectedCount)项")
                    } else {
                        Text("\(folder.name)")
                    }
                }
                .font(.system(size: FontSizes.largeTitleText, weight: .semibold))
                
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
        if filteredMilestones.isEmpty {
            if folder.id == Constants.FOLDER_DELETED_UUID || isAdding {
                Spacer()
            } else {
                NoMilestoneView()
                    .transition(.opacity)
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
                            milestone: milestone
                        )
                        .confirmationDialog("里程碑将被删除，此操作不能撤销。", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                            Button("删除里程碑", role: .destructive) {
                                hapticFeedback()
                                
                                modelContext.delete(milestone)
                                try? modelContext.save()
                                
                                NotificationCenter.default.post(name: Notification.Name("MilestoneDeleted"), object: nil)
                                
                                withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                                    filterAndSort()
                                }
                            }
                            Button("取消", role: .cancel) {
                            }
                        }
                    } leadingActions: { context in
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: milestone.date).day ?? 0
                        
                        if !isSelecting && !milestone.isEditing {
                            SwipeAction(systemImage: milestone.isPinned ? "pin.slash" : "pin", backgroundColor: days > 0 ? .textHighlight2 : .textHighlight1) {
                                milestone.isPinned.toggle()
                                withAnimation(.spring()) {
                                    filterAndSort()
                                }
                                closeSwipe.send()
                            }
                            .swipeActionChangeLabelVisibilityOnly(true)
                            .allowSwipeToTrigger()
                            .onReceive(closeSwipe) { _ in
                                context.state.wrappedValue = .closed
                            }
                            .foregroundStyle(.white)
                        }
                    } trailingActions: { context in
                        if !isSelecting && !milestone.isEditing {
                            SwipeAction(systemImage: "trash", backgroundColor: .red) {
                                delete(milestone)
                                closeSwipe.send()
                            }
                            .swipeActionChangeLabelVisibilityOnly(true)
                            .allowSwipeToTrigger()
                            .onReceive(closeSwipe) { _ in
                                context.state.wrappedValue = .closed
                            }
                            .foregroundStyle(.white)
                        }
                    }
                    .swipeMinimumDistance(30)
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
                if self.showDatePicker {
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
            folder: folder
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
        if isSelecting {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                        isSelecting.toggle()
                        showAddButton = true
                        closeSwipe.send()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .fontWeight(.medium)
                        .foregroundStyle(.textHighlight1)
                        .frame(width: 56, height: 44)
                        .cornerRadius(22)
                }
            }
        } else {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    if folder.isSystem {
                        if !filteredMilestones.isEmpty {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 1)) {
                                    showAddButton = false
                                    isSelecting.toggle()
                                    closeSwipe.send()
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
                                    showAddButton = false
                                    isSelecting = true
                                    closeSwipe.send()
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
            let checkedCount = filteredMilestones.count { $0.isChecked }
            let operateAll = checkedCount == 0 || checkedCount == filteredMilestones.count
            Button {
            } label: {
                Text(operateAll ? "移动全部" : "移动")
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
                let toDelete = operateAll ? filteredMilestones : filteredMilestones.filter { $0.isChecked }
                deleteMilestones(toDelete)
            } label: {
                Text(operateAll ? "全部删除" : "删除")
                    .font(.system(size: 17))
                    .foregroundStyle(.textHighlight1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
    }
    
    // MARK: - 方法
    private func hasPinned() -> Bool {
        return milestones.contains(where: { $0.isPinned })
    }
    
    /**
     展示新增里程碑弹窗
     */
    private func add() {
        showAddButton = false
        
        if !isAdding {
            // 收起键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                isAdding = true
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
            isAdding = false
        }
    }
    
    /**
     删除里程碑
     */
    private func delete(_ milestone: Milestone) {
        hapticFeedback()
        
        if folder.id != Constants.FOLDER_DELETED_UUID {
            milestone.folderId = Constants.FOLDER_DELETED_UUID.uuidString
            milestone.deleteDate = Date()
            try? modelContext.save()
            
            NotificationCenter.default.post(name: Notification.Name("MilestoneDeleted"), object: nil)
        } else {
            showDeleteConfirm = true
        }
        
        filterAndSort()
    }
    
    /**
     触觉反馈
     */
    private func hapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /**
     批量删除里程碑
     */
    private func deleteMilestones(_ milestones: [Milestone]) {
        hapticFeedback()
        
        if folder.id != Constants.FOLDER_DELETED_UUID {
            milestones.forEach {
                $0.folderId = Constants.FOLDER_DELETED_UUID.uuidString
                $0.deleteDate = Date()
            }
            try? modelContext.save()
            
            // 发送通知，通知父视图数据已更新
            NotificationCenter.default.post(name: Notification.Name("MilestoneDeleted"), object: nil)
        } else {
            milestones.forEach { modelContext.delete($0) }
            try? modelContext.save()
        }
        
        filterAndSort()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
            isSelecting = false
            showAddButton = true
        }
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
        
        let milestone1 = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", date: formatter.date(from: "2025-04-25")!)
        milestone1.isPinned = true
        
        let milestone2 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        milestone2.isPinned = false
        
        let milestone3 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone4 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone5 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone6 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone7 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone8 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone9 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone10 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone11 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        let milestone12 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", date: formatter.date(from: "2025-06-25")!)
        
        context.insert(folder)
        context.insert(milestone1)
        context.insert(milestone2)
        context.insert(milestone3)
        context.insert(milestone4)
        context.insert(milestone5)
        context.insert(milestone6)
        context.insert(milestone7)
        context.insert(milestone8)
        context.insert(milestone9)
        context.insert(milestone10)
        context.insert(milestone11)
        context.insert(milestone12)
        
        return MilestoneListView(folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
