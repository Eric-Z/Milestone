import SwiftUI

struct MainTagView: View {
    
    @State var tags: [Tag]
    @Binding var selectedTag: String
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                        .frame(width: 20)
                    ForEach(allTags, id: \.self) { tag in
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
            .padding(.horizontal, 28)
            .padding(.top, 10)
            .padding(.bottom, 12)
        }
    }
    
    var allTags: [Tag] {
        if tags.isEmpty {
            return []
        }
        return [Tag(content: "#所有标签") ] + tags
    }
}

