import SwiftUI
import SwiftData
import SwipeActions

struct MilestoneListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode
    
    @Query private var milestones: [Milestone]
    
    @State private var filteredMilestone: [Milestone] = []
    @State private var showAddEditView: Bool = false // State to control overlay visibility
    
    @Namespace private var animation
    
    var folder: Folder
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Layer 0: Main Content (Header + List)
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(folder.name)")
                            .font(.system(size: FontSizes.largeTitleText, weight: .semibold))
                        
                        Group {
                            // Count only real milestones
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
                
                // List or Empty View
                if filteredMilestone.isEmpty {
                    // Keep NoMilestoneView logic if needed, but ensure it doesn't conflict with Add/Edit overlay
                     if !showAddEditView { // Only show if not adding/editing
                         NoMilestoneView()
                             .transition(.opacity)
                     } else {
                         // Optionally show a placeholder or empty space while adding
                         Spacer()
                     }
                } else {
                    List {
                        // Loop through real milestones only
                        ForEach(filteredMilestone) { milestone in
                             MilestoneView(folder: folder, milestone: milestone)
                                .padding(.horizontal, Distances.itemPaddingH)
                                .padding(.bottom, Distances.itemGap)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: Distances.listGap, trailing: 0))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteMilestone(milestone)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                                // Removed the 'else' branch for MilestoneAddEditView
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .zIndex(0) // Base layer

            // Layer 1: Background Dimming/Tap Layer (Conditional)
            if showAddEditView {
                Color.black.opacity(0.1) // Dimming effect
                    .ignoresSafeArea()
                    .onTapGesture {
                         // 收起键盘
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation(.spring()) {
                            showAddEditView = false
                        }
                    }
                    .zIndex(1)
                    .transition(.opacity) // Animate background fade
            }

            // Layer 2: Add/Edit View Overlay (Conditional)
            if showAddEditView {
                MilestoneAddEditView(milestone: nil, folder: folder, onSave: {
                    // Save is handled internally, just dismiss the view
                    withAnimation(.spring()) {
                        showAddEditView = false
                    }
                    // Refresh list after save
                    filterAndSortMilestone()
                })
                .padding(.horizontal, Distances.listPadding) // Add padding to position it
                .padding(.bottom, 120) // Add bottom padding to avoid FAB position
                .zIndex(2)
                .transition(.move(edge: .bottom).combined(with: .opacity)) // Animate from bottom
            }
            
            // Layer 3: Floating Action Button (FAB)
            VStack {
                Spacer()
                // Only show FAB when add/edit view is not visible
                if !showAddEditView {
                    Button {
                        if !showAddEditView { // Prevent opening if already open
                            // 收起键盘
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            withAnimation(.spring()) {
                                showAddEditView = true
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 54, height: 54)
                            .background(Color.textHighlight1)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .padding(.bottom, 50)
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .zIndex(3) // Ensure FAB is on top
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
             // Keep toolbar items as they were
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
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                }
            }
        }
        .onAppear {
            // Simple filter and sort on appear
            filterAndSortMilestone()
        }
        // Remove tap gesture from here if it exists
    }
    
    /**
     Delete Milestone
     */
    private func deleteMilestone(_ milestone: Milestone) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        modelContext.delete(milestone)
        try? modelContext.save()
        filterAndSortMilestone() // Refresh list
    }

    /**
     里程碑排序 (Simplified - no temporary item logic)
     */
    private func filterAndSortMilestone() {
        // Filter for milestones belonging to the current folder
        filteredMilestone = milestones.filter { milestone in
            milestone.folderId == folder.id.uuidString
        }.sorted { m1, m2 in
            // Pinned items first
            if m1.pinned != m2.pinned {
                return m1.pinned
            }
            
            // Then sort by date proximity
            let now = Date()
            let diff1 = m1.date.timeIntervalSince(now)
            let diff2 = m2.date.timeIntervalSince(now)
            
            // Future dates before past dates
            if (diff1 >= 0 && diff2 < 0) {
                return true
            }
            if (diff1 < 0 && diff2 >= 0) {
                return false
            }
            
            // If both future or both past, sort by closeness to now
            return abs(diff1) < abs(diff2)
        }
    }
}

#Preview {
    // Preview remains largely the same, just don't need temporary item logic
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
