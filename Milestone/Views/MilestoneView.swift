import SwiftUI
import SwiftData
import Foundation

struct MilestoneView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]
    
    let onSelectMode: Bool
    let folder: Folder
    @State var milestone: Milestone

    @State private var onEditMode: Bool = false
    @State private var showDatePicker: Bool = false
    
    // MARK: - 主视图
    var body: some View {
        if !onEditMode {
            viewMode
        } else {
            editMode
        }
    }
    
    // MARK: - 只读
    @ViewBuilder
    private var viewMode: some View {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: milestone.date).day ?? 0
        
        HStack(spacing: 0) {
            
            if onSelectMode {
                Button(action: {
                    milestone.isChecked.toggle()
                    try? modelContext.save()
                }) {
                    Image(systemName: milestone.isChecked ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(milestone.pinned ? .white : milestone.isChecked ? .textHighlight1 : .textPlaceholderDisable)
                        .font(.system(size: FontSizes.bodyText))
                }
                .buttonStyle(.plain)
                .padding(.trailing, Distances.itemPaddingH)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Group {
                    if days > 0 {
                        Text("\(milestone.title)还有")
                    } else if days < 0 {
                        Text("\(milestone.title)已经")
                    } else {
                        HStack(spacing: 0) {
                            Text("\(milestone.title)")
                            Text("就是今天！")
                                .foregroundStyle(milestone.pinned ? .white : .textHighlight1)
                        }
                    }
                }
                .font(.system(size: FontSizes.bodyText, weight: .semibold))
                .foregroundStyle(milestone.pinned ? .white : .accent)
                
                if !milestone.remark.isEmpty {
                    Text("\(milestone.remark)")
                        .font(.system(size: FontSizes.noteText))
                        .padding(.top, Distances.itemGap)
                        .foregroundStyle(milestone.pinned ? .white : .textNote)
                }
                
                let milestoneFolder = folders.first{ $0.id.uuidString == milestone.folderId }
                if folder.id == Constants.FOLDER_ALL_UUID {
                    HStack(spacing: 0) {
                        Group {
                            Image(systemName: "folder")
                            
                            Text(milestoneFolder?.name ?? Constants.FOLDER_ALL)
                                .padding(.leading, Distances.itemGap)
                        }
                        .font(.system(size: FontSizes.noteText))
                        .foregroundStyle(milestone.pinned ? .white : .textNote)
                        .padding(.top, Distances.itemGap)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 0) {
                Group {
                    if days > 0 {
                        Group {
                            Text("\(days)")
                            Text("天")
                                .padding(.leading, Distances.itemGap)
                        }
                        .foregroundStyle(milestone.pinned ? .white : .textHighlight2)
                    } else if days < 0 {
                        Group {
                            Text("\(-days)")
                            Text("天")
                                .padding(.leading, Distances.itemGap)
                        }
                        .foregroundStyle(milestone.pinned ? .white : .textHighlight1)
                    } else {
                        Text("🎉")
                    }
                }
                .font(.system(size: FontSizes.bodyNumber, weight: .semibold, design: .rounded))
                .foregroundStyle(milestone.pinned ? .white : .accentColor)
            }
        }
        .onTapGesture {
            milestone.isChecked.toggle()
            try? modelContext.save()
        }
        .padding(.horizontal, Distances.itemPaddingH)
        .padding(.vertical, Distances.itemPaddingV)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(milestone.pinned ? (days > 0 ? .textHighlight2 : .textHighlight1) : .areaItem)
        .cornerRadius(21)
    }
    
    // MARK: - 编辑
    @ViewBuilder
    private var editMode: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    TextField("里程碑", text: $milestone.title)
                        .font(.system(size: FontSizes.bodyText, weight: .medium))
                    
                    Spacer()
                    
                    Button(action: {
                        try? modelContext.save()
                        
                        
                    }) {
                        Text("完成")
                            .font(.system(size: FontSizes.bodyText, weight: .semibold))
                            .foregroundColor(milestone.title.isEmpty ? .textPlaceholderDisable : .textHighlight1)
                    }
                    .disabled(milestone.title.isEmpty)
                }
                
                TextField("添加备注", text: $milestone.remark)
                    .font(.system(size: 14))
                    .foregroundColor(.textPlaceholderDisable)
            }
            .padding(.horizontal, Distances.itemPaddingH)
            .padding(.vertical, Distances.itemPaddingV)
            .frame(height: 72)
            
            Button {
                // 收起键盘
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showDatePicker.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.system(size: 17))
                        .imageScale(.large)
                    
                    Text(dateFormatter.string(from: milestone.date))
                        .font(.system(size: 17))
                }
                .foregroundColor(.textHighlight1)
                .padding(.horizontal, Distances.itemPaddingH)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.areaItem)
            }
            .buttonStyle(.plain)
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
                DatePicker("选择日期", selection: $milestone.date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .environment(\.calendar, Calendar(identifier: .gregorian))
                    .tint(.textHighlight1)
                    .onChange(of: milestone.date) {
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
    
    // MARK: - 方法
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
