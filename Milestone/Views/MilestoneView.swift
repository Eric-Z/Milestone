import SwiftUI

struct MilestoneView: View {
    @State private var title: String = "里程碑"
    @State private var remark: String = ""
    @State private var date: Date = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 15)) ?? Date()
    @State private var isCompleted: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    TextField("里程碑", text: $title)
                        .font(.system(size: FontSize.bodyText, weight: .medium))
                    
                    Spacer()
                    
                    Button(action: {
                        isCompleted.toggle()
                    }) {
                        Text("完成")
                            .font(.system(size: FontSize.bodyText, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                }
                
                // 备注部分
                HStack(spacing: 0) {
                    TextField("添加备注", text: $remark)
                        .font(.system(size: 14))
                        .foregroundColor(.textPlaceholderDisable)
                }
                
            }
            .padding(.horizontal, Distance.itemPaddingH)
            .padding(.vertical, Distance.itemPaddingV)
            .frame(height: 72)
            
            HStack(spacing: 0) {
                Image(systemName: "calendar")
                    .font(.system(size: 17))
                    .imageScale(.large)
                    .foregroundColor(.textHighlight1)
            }
            .padding(.horizontal, Distance.itemPaddingH)
            .padding(.top, 10)
            .padding(.bottom, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .areaItem, location: 0.00),
                        Gradient.Stop(color: .areaItemLight, location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.areaBackground)
        .cornerRadius(21)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 21)
                .inset(by: 0.5)
                .stroke(.areaBorder, lineWidth: 1)
        )
    }
    
}

#Preview {
    MilestoneView()
        .padding(.horizontal)
}
