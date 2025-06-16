import SwiftUI
import SwiftData

struct MilestoneAddView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var folder: Folder?
    @Binding var showDatePicker: Bool
    
    @State private var title: String = ""
    @State private var remark: String = ""
    @State private var date: Date = Date()
    
    var onSave: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    TextField("里程碑", text: $title)
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                    
                    Spacer()
                    
                    Button(action: {
                        saveMilestone()
                    }) {
                        Text("完成")
                            .font(.system(size: FontSizes.bodyText, weight: .semibold))
                            .foregroundColor(title.isEmpty ? .textPlaceholderDisable : .textHighlight1)
                    }
                    .disabled(title.isEmpty)
                }
                
                TextField("添加备注", text: $remark)
                    .font(.system(size: FontSizes.bodyText))
                    .kerning(0.17)
                    .foregroundColor(.textPlaceholderDisable)
                    .padding(.top, 8)
            }
            .padding(.horizontal, Distances.itemPaddingH)
            .padding(.top, 14)
            .frame(height: 72)
            
            HStack(spacing: 0) {
                Button {
                    // 收起键盘
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showDatePicker.toggle()
                    }
                } label: {
                    HStack(spacing: 0) {
                        Text(dateFormatter.string(from: date))
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.textHighlight1)
                    .padding(.horizontal, Distances.itemPaddingH)
                    .padding(.top, 8)
                    .padding(.bottom, 14)
                    .frame(alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            
            HStack(alignment: .top, spacing: 14) {
                Button {
                    
                } label: {
                    Image(systemName: "pin")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .foregroundStyle(.textHighlight1)
                        .padding(12)
                        .background(
                            Circle()
                            .fill(.areaBackground)
                            .frame(width: 44, height: 44, alignment: .center)
                        )
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "folder")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .foregroundStyle(.textHighlight1)
                        .padding(12)
                        .background(
                            Circle()
                            .fill(.areaBackground)
                            .frame(width: 44, height: 44, alignment: .center)
                        )
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                        .foregroundStyle(.red)
                        .padding(12)
                        .background(Circle().fill(.areaBackground))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 13)
            .padding(.bottom, 14)
            .frame(maxWidth: .infinity, alignment: .topLeading)
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
        .background(Color(.systemBackground))
        .cornerRadius(21)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 21)
                .inset(by: 0.5)
                .stroke(.areaBorder, lineWidth: 1)
        )
        
        if showDatePicker {
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
    
    /**
     保存里程碑
     */
    private func saveMilestone() {
        let newMilestone = Milestone(
            folderId: folder?.id == Constants.FOLDER_ALL_UUID ? nil : folder?.id.uuidString,
            title: title,
            remark: remark,
            date: date
        )
        modelContext.insert(newMilestone)
        
        // 保存更改
        try? modelContext.save()
        
        // 调用保存完成回调
        onSave()
    }
    
    /**
     添加日期格式化器
     */
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }
}

#Preview {
    MilestoneAddView(showDatePicker: Binding.constant(false))
}
