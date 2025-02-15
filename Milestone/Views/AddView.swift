import SwiftUI
import SwiftData

struct AddView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Tag.content, order: .forward) private var tags: [Tag]
    
    @State private var title: String = ""
    @State private var remark: String = ""
    @State private var date: Date = Date()
    @State private var selectedTag: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button("取消") {
                }
                
                Spacer()
                
                Text("添加里程碑")
                    .font(.system(size: 17))
                
                Spacer()
                
                Button("保存") {
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
                    ForEach(tags, id: \.self) { tag in
                        Button(action: {
                            selectedTag = tag.content
                        }) {
                            Text(tag.content)
                                .font(.system(size: 14))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(selectedTag == tag.content ? .accent : Color.tag)
                                .foregroundColor(selectedTag == tag.content ? .white : .grayText)
                                .cornerRadius(8)
                        }
                        .overlay (
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTag == tag.content ? .accent : .grayBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Tag.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        context.insert(Tag(content: "#旅游"))
        context.insert(Tag(content: "#生日"))
        context.insert(Tag(content: "#假期"))
        context.insert(Tag(content: "#纪念日"))
        
        return AddView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
