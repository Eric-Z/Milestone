import SwiftUI
import SwiftData

struct MainTagView: View {
    
    @Query private var milestones: [Milestone]
    @Binding var selectedTag: String
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                        .frame(width: 20)
                    ForEach(allTags, id: \.self) { tag in
                        Button(action: {
                            selectedTag = tag
                        }) {
                            Text(tag)
                                .font(.system(size: 14))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(selectedTag == tag ? .accent : Color.tag)
                                .foregroundColor(selectedTag == tag ? .white : .grayText)
                                .cornerRadius(8)
                        }
                        .overlay (
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedTag == tag ? .accent : .grayBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 2)
            }
            
            HStack {
                Group {
                    if (selectedTag == "所有标签") {
                        Text("已显示所有里程碑。")
                    } else {
                        Text("显示符合所选标签的里程碑：\(selectedTag)。")
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(.grayText)
                
                Spacer()
            }
            .padding(.horizontal, 28)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
    }
    
    var allTags: [String] {
        var tags = milestones.map { "#" + $0.tag }
        tags = Array(Set(tags)).sorted()
        tags.insert(contentsOf: ["所有标签"], at:  0)
        return tags
    }
}

#Preview {
    do {
        let container = try ModelContainer(for: Milestone.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        context.insert(Milestone(title: "北海道之行", tag: "旅游", remark: "", date: Date()))
        context.insert(Milestone(title: "庄慧的生日", tag: "生日", remark: "", date: Date()))
        
        return MainTagView(selectedTag: .constant("所有标签"))
            .modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
