import SwiftUI

struct NoMilestoneView: View {
    
    var body: some View {
        ZStack {
            // 虚线边框
            RoundedRectangle(cornerRadius: 21)
                .foregroundStyle(.backgroundPrimary)
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
        .contentShape(RoundedRectangle(cornerRadius: 22))
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

#Preview {
    NoMilestoneView()
}
