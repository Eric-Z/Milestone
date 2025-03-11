import SwiftUI

struct MainTagView: View {
    
    var tags: [Tag]
    var milestones: [Milestone]
    @Binding var selectedTag: String
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 20)
                    ForEach(allTags, id: \.self) { tag in
                        let tagValid = allTagsInMilestones.contains(tag.content)
                        if (tagValid) {
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
                            .padding(.trailing, 10)
                        } else {
                            Button(action: {
                            }) {
                                Text(tag.content)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.clear)
                                    .foregroundColor(.grayText)
                                    .cornerRadius(8)
                            }
                            .overlay (
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [3]))
                                    .foregroundStyle(.grayBorder)
                            )
                            .padding(.trailing, 10)
                        }
                    }
                }
            }
            
            HStack {
                Group {
                    if (selectedTag == "#所有标签") {
                        Text("已显示所有里程碑。")
                    } else {
                        Text("显示符合所选标签的里程碑：\(selectedTag)。")
                    }
                }
                .font(.system(size: 12))
                .foregroundStyle(.grayText)
                
                Spacer()
            }
            .padding(.leading, 30)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
    }
    /**
     标签处理
     */
    var allTags: [Tag] {
        if tags.isEmpty {
            return []
        }
        return [Tag(content: "#所有标签") ] + tags
    }
    
    /**
     提取里程碑中的所有标签
     */
    var allTagsInMilestones: Set<String> {
        var tagSet = Set(milestones.map{ $0.tag })
        tagSet.insert("#所有标签")
        return tagSet
    }
}

#Preview {
    let tag1 = Tag(content: "#旅游")
    let tag2 = Tag(content: "#生日")
    
    let milestone = Milestone(title: "北海道之行", tag: "#旅游", remark: "备注 1", date: Date())
    MainTagView(tags: [tag1, tag2], milestones: [milestone], selectedTag: .constant("#旅游"))
    
    Spacer()
}
