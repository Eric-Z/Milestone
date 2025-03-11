import SwiftUI
import SwiftData

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Tag.content, order: .forward) private var tags: [Tag]
    
    let milestone: Milestone
    
    @State private var title: String
    @State private var remark: String
    @State private var date: Date
    @State private var selectedTag: String
    
    @State private var showAlert = false
    
    init(milestone: Milestone) {
        self.milestone = milestone
        // 初始化 State 变量
        _title = State(initialValue: milestone.title)
        _remark = State(initialValue: milestone.remark)
        _date = State(initialValue: milestone.date)
        _selectedTag = State(initialValue: String(milestone.tag.dropFirst())) // 去掉 "#" 前缀
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button("取消") {
                    dismiss()
                }
                
                Spacer()
                
                Text("编辑里程碑")
                    .font(.system(size: 17))
                
                Spacer()
                
                Button("保存") {
                    showAlert = title.isEmpty
                    
                    if (!showAlert) {
                        // 更新现有的 milestone
                        milestone.title = title
                        milestone.remark = remark
                        milestone.date = date
                        milestone.tag = "#" + selectedTag
                        
                        dismiss()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("错误"),
                          message: Text("标题不能为空"),
                          dismissButton: .default(Text("确定")))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .padding(.bottom, 10)
            
            Group {
                HStack {
                    Image(systemName: "textformat.alt")
                        .foregroundStyle(.accent)
                    
                    TextField("标题", text: $title)
                }
                
                HStack {
                    Image(systemName: "text.bubble")
                        .foregroundStyle(.accent)
                    
                    TextField("备注（选填）", text: $remark)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.tag)
            )
            .padding(.bottom, 10)
            
            HStack {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.accent)
                    
                    Text("日期")
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.tag)
                )
                
                HStack {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .accentColor(.accent)
                        .cornerRadius(15)
                }
            }
            .padding(.bottom, 10)
            
            HStack {
                Image(systemName: "tag")
                    .foregroundStyle(.accent)
                
                TextField("标签（选填）", text: $selectedTag)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.tag)
            )
            .padding(.bottom, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(filterTag, id: \.self) { tag in
                        Button(action: {
                            selectedTag = String(tag.content.dropFirst())
                        }) {
                            Text(tag.content)
                                .font(.system(size: 14))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background("#" + selectedTag == tag.content ? .accent : Color.tag)
                                .foregroundColor("#" + selectedTag == tag.content ? .white : .grayText)
                                .cornerRadius(8)
                        }
                        .overlay (
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTag == tag.content ? .accent : .grayBorder, lineWidth: 1)
                        )
                    }
                    
                    let newTagMode = tags.filter { $0.content == "#" + selectedTag }.isEmpty
                    if (newTagMode && !selectedTag.isEmpty) {
                        Button(action: {
                            modelContext.insert(Tag(content: "#" + selectedTag))
                        }) {
                            Text("+ 创建\" \(selectedTag) \"")
                                .font(.system(size: 14))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(Color.newTag)
                                .foregroundColor(.accent)
                                .cornerRadius(8)
                        }
                        .overlay (
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.accent)
                        )
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
    }
    
    var filterTag: [Tag] {
        if self.selectedTag.isEmpty {
            return tags
        } else {
            return tags.filter { $0.content.contains(selectedTag) }
        }
    }
} 