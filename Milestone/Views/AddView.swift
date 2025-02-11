import SwiftUI
import Glur

struct AddReminderView: View {
    @State private var title: String = ""
    @State private var remark: String = ""
    @State private var date: Date = Date()
    @State private var tags: String = ""
    
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
                
                TextField("标签（选填）", text: $tags)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.tag)
            )
            .padding(.bottom, 10)
            
            Spacer()
        }
        .padding(.horizontal, 14)
    }
}

struct AddReminderView_Previews: PreviewProvider {
    static var previews: some View {
        AddReminderView()
    }
}
