import SwiftUI

struct MilestoneView: View {
    var folder: Folder??
    
    @State private var title: String = ""
    @State private var remark: String = ""
    @State private var date: Date = Date()
    @State private var isCompleted: Bool = true
    @State private var showDatePicker: Bool = false
    
    /**
     添加日期格式化器
     */
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0) {
                        TextField("里程碑", text: $title)
                            .font(.system(size: FontSize.bodyText, weight: .medium))
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            Text("完成")
                                .font(.system(size: FontSize.bodyText, weight: .semibold))
                                .foregroundColor(title.isEmpty ? .textPlaceholderDisable : .textHighlight1)
                        }
                        .disabled(title.isEmpty)
                    }
                    
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
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showDatePicker.toggle()
                        }
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 17))
                            .imageScale(.large)
                            .foregroundColor(.textHighlight1)
                    }
                    
                    Text(dateFormatter.string(from: date))
                        .font(.system(size: 17))
                        .foregroundColor(.textHighlight1)
                        .padding(.leading, 12)
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
            
            if showDatePicker {
                Color.black.opacity(0.1)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showDatePicker = false
                        }
                    }
                    .transition(.opacity)
                
                VStack(spacing: 0) {
                    DatePicker("选择日期", selection: $date, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                        .environment(\.calendar, Calendar(identifier: .gregorian))
                        .tint(.textHighlight1)
                        .onChange(of: date) {
                            withAnimation(.easeOut(duration: 0.2)) {
                                showDatePicker = false
                            }
                        }
                }
                .frame(width: 320, height: 320)
                .background(.areaBackgroundPopup)
                .cornerRadius(21)
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
                .transition(
                    .scale(scale: 0.5)
                    .combined(with: .opacity)
                )
            }
        }
    }
}

#Preview {
    MilestoneView()
}
