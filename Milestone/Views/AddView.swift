import SwiftUI
import SwiftData

struct AddView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Tag.content, order: .forward) private var tags: [Tag]
    
    @State private var title: String = ""
    @State private var remark: String = ""
    @State private var date: Date = Date()
    @State private var selectedTag: String = ""
    
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button("取消") {
                    dismiss()
                }
                
                Spacer()
                
                Text("添加里程碑")
                    .font(.system(size: 17))
                
                Spacer()
                
                Button("保存") {
                    showAlert = title.isEmpty
                    
                    let finalTag = selectedTag.isEmpty ? "" : "#" + selectedTag
                    if (!showAlert) {
                        let newMilestone = Milestone(title: title, tag: finalTag, remark: remark, date: date)
                        modelContext.insert(newMilestone)
                        dismiss()
                    }
                }
                .alert(isPresented: $showAlert) { // 添加警报
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
