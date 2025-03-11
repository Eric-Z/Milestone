import SwiftUI

struct MainHeaderView: View {
    
    var milestones: [Milestone]
    
    var body: some View {
        HStack {
            // 主题栏
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("MileStone")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                    Spacer()
                }
                
                if (!milestones.isEmpty) {
                    HStack {
                        Text("\(milestones.count) 个里程碑")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(Color.grayText)
                        Spacer()
                    }
                }
            }
        }
        .padding(.leading, 28)
        .padding(.vertical, 12)
    }
}

#Preview {
    let milestone = Milestone(title: "北海道之行", tag: "#旅游", remark: "备注 1", date: Date())
    MainHeaderView(milestones: [milestone])
    
    Spacer()
}
