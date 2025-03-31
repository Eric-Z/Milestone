import SwiftUI

struct NoMilestoneView: View {
    
    var body: some View {
        ZStack {
            // 虚线边框
            RoundedRectangle(cornerRadius: 21)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundStyle(.areaBorder)
                .padding(.bottom, 77)
            
            // 内容
            VStack(spacing: 0) {
                Spacer()
                Image("NoData")
                Text("点击加号即可新建里程碑")
                    .font(.system(size: 14))
                    .foregroundStyle(.textNote)
                    .padding(.top, 20)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .contentShape(RoundedRectangle(cornerRadius: 21))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    NoMilestoneView()
}
