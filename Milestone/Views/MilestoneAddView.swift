import SwiftUI
import SwiftData

struct MilestoneAddView: View {
    
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var folder: Folder
    
    @State private var title: String = ""
    @State private var type: MilestonType = MilestonType.singleDay
    @State private var allDay: Bool = true
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(.backgroundPrimary)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    TextField("请输入标题", text: $title)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 15)
                        .background(.backgroundSecondary)
                        .cornerRadius(22)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("类型")
                            
                            Spacer()
                            
                            Picker("", selection: $type) {
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
                            
                            Toggle(isOn: $allDay) {
                            }
                        }
                        .padding(.horizontal, 8)
                        
                        Divider()
                        
                        if self.type == MilestonType.singleDay {
                            HStack {
                                Text("时间")
                                
                                Spacer()
                                
                                DatePicker("时间", selection: $startDate, displayedComponents: self.allDay ? [.date] : [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .accentColor(.highlight)
                                    .environment(\.locale, Locale(identifier: "zh_CN"))
                            }
                            .padding(.horizontal, 8)
                        } else {
                            HStack {
                                Text("开始")
                                
                                Spacer()
                                
                                DatePicker("开始", selection: $startDate, displayedComponents: self.allDay ? [.date] : [.date, .hourAndMinute])
                                    .labelsHidden()
                                    .accentColor(.highlight)
                                    .environment(\.locale, Locale(identifier: "zh_CN"))
                            }
                            .padding(.horizontal, 8)
                            
                            Divider()
                            
                            HStack {
                                Text("结束")
                                
                                Spacer()
                                
                                DatePicker("结束", selection: $endDate, displayedComponents: self.allDay ? [.date] : [.date, .hourAndMinute])
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
                        .disabled(self.title.isEmpty)
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
    
    // MARK: - 方法
    /**
     保存里程碑
     */
    private func save() {
        self.showAlert = self.exist()
        if showAlert {
            return
        }
        
        let newMilestone = Milestone(folderId: folder.id.uuidString, title: self.title, date: startDate)
        newMilestone.type = self.type
        
        if newMilestone.type == MilestonType.multiDay {
            newMilestone.date2 = self.endDate
        }
        modelContext.insert(newMilestone)
        try? modelContext.save()
    }
    
    /**
     检查里程碑是否存在
     */
    private func exist() -> Bool {
        if title.isEmpty {
            return false
        }
        return milestones.contains { $0.title == self.title }
    }
    
}

#Preview {
    MilestoneAddView(folder: Folder(name: "旅行"))
}
