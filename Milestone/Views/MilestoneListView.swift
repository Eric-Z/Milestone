import SwiftUI
import SwiftData

struct MilestoneListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query private var milestones: [Milestone]
    
    @State private var filteredMilestone: [Milestone] = []
    @State private var showAddEditView: Bool = false
    @State private var selectedMilestone: Milestone? = nil
    @State private var onEditMode: Bool = false
    
    // 获取自动显示添加视图的信号
    @ObservedObject private var autoShowPublisher = AutoShowAddPublisher.shared
    
    var folder: Folder
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mainContentView
                .zIndex(0)
            
            if showAddEditView {
                maskLayer
                    .zIndex(1)
            }
            
            if showAddEditView {
                addEditOverlay
                    .zIndex(2)
            }
            
            if !showAddEditView {
                floatingActionButton
                    .zIndex(3)
            }
            
            if onEditMode && milestones.count >= 1 {
                bottomToolbarView
                    .zIndex(3)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar { toolbarContent }
        .onAppear {
            filterAndSort()
            
            // 如果收到自动显示添加视图的信号，执行添加
            if autoShowPublisher.shouldAutoShow {
                // 延迟执行以确保视图已完全加载
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    presentAddEditView()
                    // 重置标志，避免影响其他视图
                    autoShowPublisher.shouldAutoShow = false
                }
            }
        }
    }
    
    private var mainContentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            listViewOrEmptyState
        }
    }
    
    /**
     标题
     */
    private var headerView: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(folder.name)")
                    .font(.system(size: FontSizes.largeTitleText, weight: .semibold))
                
                Group {
                    if filteredMilestone.isEmpty {
                        Text("暂无里程碑")
                            .font(.system(size: FontSizes.largeNoteText))
                    } else {
                        HStack(spacing: 0) {
                            Text("\(filteredMilestone.count)")
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
        .padding(.top, 0)
        .padding(.bottom, 12)
    }
    
    /**
     里程碑列表或空视图
     */
    @ViewBuilder
    private var listViewOrEmptyState: some View {
        if filteredMilestone.isEmpty {
            if !showAddEditView {
                NoMilestoneView()
                    .transition(.opacity)
            } else {
                Spacer()
            }
        } else {
            milestoneList
        }
    }
    
    /**
     里程碑列表
     */
    private var milestoneList: some View {
        List {
            ForEach(filteredMilestone) { milestone in
                MilestoneView(onEditMode: onEditMode, folder: folder, milestone: milestone)
                    .padding(.horizontal, Distances.itemPaddingH)
                    .padding(.bottom, Distances.itemGap)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Distances.listGap, trailing: 0))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !onEditMode {
                            selectedMilestone = milestone
                            presentEditView(milestone: milestone)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            delete(milestone)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            milestone.pinned.toggle()
                            withAnimation(.spring()) {
                                filterAndSort()
                            }
                        } label: {
                            Label("置顶", systemImage: milestone.pinned ? "pin.slash" : "pin")
                        }
                        .tint(.textHighlight1)
                    }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    /**
     遮罩层
     */
    private var maskLayer: some View {
        Color.black.opacity(0.1)
            .ignoresSafeArea()
            .onTapGesture {
                dismissAddEditView()
            }
            .transition(.opacity)
    }
    
    /**
     新增/更新里程碑弹框
     */
    private var addEditOverlay: some View {
        MilestoneAddEditView(
            milestone: selectedMilestone,
            folder: folder,
            onSave: {
                dismissAddEditView()
                filterAndSort()
            }
        )
        .padding(.horizontal, Distances.listPadding)
        .padding(.bottom, 120)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    /**
     新增里程碑按钮
     */
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            Button {
                selectedMilestone = nil
                presentAddEditView()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 54, height: 54)
                    .background(Color.textHighlight1)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.bottom,  50)
            }
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .transition(.opacity)
    }
    
    /**
     工具栏
     */
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
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                    onEditMode.toggle()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 17))
                    .foregroundStyle(.textHighlight1)
            }
        }
    }
    
    /**
     底部菜单栏
     */
    private var bottomToolbarView: some View {
        HStack(spacing: 0) {
            let isAllChecked = filteredMilestone.allSatisfy { $0.isChecked }
            let isAllNotChecked = filteredMilestone.allSatisfy { !$0.isChecked }
            let operateAll = isAllChecked || isAllNotChecked
            Button {
            } label: {
                if (operateAll) {
                    Text("移动全部")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                } else {
                    Text("移动")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                }
            }
            
            Spacer()
            
            Button {
                if operateAll {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    filteredMilestone.forEach { modelContext.delete($0) }
                    try? modelContext.save()
                    
                    filterAndSort()
                    
                    // 退出编辑模式
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                        onEditMode = false
                    }
                } else {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    filteredMilestone.forEach {
                        if $0.isChecked {
                            modelContext.delete($0)
                        }
                    }
                    try? modelContext.save()
                    
                    filterAndSort()
                    
                    // 退出编辑模式
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                        onEditMode = false
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
    
    /**
     展示新增里程碑弹窗
     */
    private func presentAddEditView() {
        if !showAddEditView {
            // 收起键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.3)) {
                showAddEditView = true
            }
        }
    }
    
    /**
     展示编辑里程碑弹窗
     */
    private func presentEditView(milestone: Milestone) {
        if !showAddEditView {
            // 收起键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            selectedMilestone = milestone
            withAnimation(.spring()) {
                showAddEditView = true
            }
        }
    }
    
    /**
     隐藏新增/更新里程碑弹窗
     */
    private func dismissAddEditView() {
        // 收起键盘
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.spring()) {
            showAddEditView = false
        }
    }
    
    /**
     删除里程碑
     */
    private func delete(_ milestone: Milestone) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        modelContext.delete(milestone)
        try? modelContext.save()
        
        filterAndSort()
    }
    
    /**
     里程碑列表排序
     */
    private func filterAndSort() {
        filteredMilestone = milestones
            .filter { $0.folderId == folder.id.uuidString || folder.id == Constants.FOLDER_ALL_UUID}
            .sorted { m1, m2 in
                // Pinned items first
                if m1.pinned != m2.pinned {
                    return m1.pinned
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
        
        let folder = Folder(name: "旅行", sortOrder: 1)
        
        let milestone1 = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", remark: "冲绳一下", date: formatter.date(from: "2025-04-25")!)
        milestone1.pinned = true
        
        let milestone2 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", remark: "", date: formatter.date(from: "2025-06-25")!)
        milestone2.pinned = false
        
        context.insert(folder)
        context.insert(milestone1)
        context.insert(milestone2)
        
        return MilestoneListView(folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
