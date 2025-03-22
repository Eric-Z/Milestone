import SwiftUI

struct NoDataView: View {
    
    @State private var showAddView = false
    
    var body: some View {
        ZStack {
            // 虚线边框
            RoundedRectangle(cornerRadius: 21)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundStyle(.grayBorder)
            
            // 内容
            VStack(spacing: 0) {
                Spacer()
                Image("NoData")
                Text("点击空白处即可新建里程碑")
                    .font(.system(size: 14))
                    .foregroundStyle(.grayText)
                    .padding(.top, 20)
                Spacer()
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                Button {
                    showAddView = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 54))
                }
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $showAddView) {
                AddView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }
}


#Preview {
    NoDataView()
}
