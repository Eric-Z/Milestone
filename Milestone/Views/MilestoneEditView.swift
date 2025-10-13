import SwiftUI
import SwiftData

struct MilestoneEditView: View {
    
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var milestone: Milestone
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(.backgroundPrimary)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    TextField("请输入标题", text: $milestone.title)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 15)
                        .background(.backgroundSecondary)
                        .cornerRadius(22)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("类型")
                            
                            Spacer()
                            
                            Picker("", selection: $milestone.type) {
                                Text("一天").tag(MilestonType.singleDay)
                                Text("多天").tag(MilestonType.multiDay)
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.horizontal, 8)
                        
                        Divider()
                        
                        HStack {
                            Text("全天")
                            
                            Spacer()
                            
                            Toggle(isOn: $milestone.allDay) {
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        Divider()
                        
                        if self.milestone.type == MilestonType.singleDay {
                            HStack {
                                Text("时间")
                                
                                Spacer()
                                
                                DatePicker("时间", selection: $milestone.date, displayedComponents: self.milestone.allDay ? [.date] : [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .accentColor(.highlight)
                                    .environment(\.locale, Locale(identifier: "zh_CN"))
                            }
                            .padding(.horizontal, 8)
                        } else {
                            HStack {
                                Text("开始")
                                
                                Spacer()
                                
                                DatePicker("开始", selection: $milestone.date, displayedComponents: self.milestone.allDay ? [.date] : [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .accentColor(.highlight)
                                    .environment(\.locale, Locale(identifier: "zh_CN"))
                            }
                            .padding(.horizontal, 8)
                            
                            Divider()
                            
                            HStack {
                                Text("结束")
                                
                                Spacer()
                                
                                DatePicker("结束", selection: $milestone.date2, displayedComponents: self.milestone.allDay ? [.date] : [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .fixedSize()
                                    .accentColor(.highlight)
                                    .environment(\.locale, Locale(identifier: "zh_CN"))
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .padding()
                    .background(.backgroundSecondary)
                    .cornerRadius(22)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationTitle("新建里程碑")
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
                        .disabled(self.milestone.title.isEmpty)
                    }
                }
            }
        }
        .alert("标题已被使用", isPresented: $showAlert) {
            Button("好", role: .cancel) {}
        } message: {
            Text("请选取一个不同的标题")
        }
    }
    
    // MARK: 方法
    /**
     保存里程碑
     */
    private func save() {
        self.showAlert = self.exist()
        if showAlert {
            return
        }
        try? modelContext.save()
    }
    
    /**
     检查里程碑是否存在
     */
    private func exist() -> Bool {
        if self.milestone.title.isEmpty {
            return false
        }
        return milestones.contains { $0.title == self.milestone.title && $0.id != self.milestone.id }
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
        
        let folder = Folder(name: "旅行")
        context.insert(folder)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let milestone = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", date: formatter.date(from: "2025-04-25")!)
        
        context.insert(milestone)
        
        return MilestoneEditView(milestone: milestone).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
