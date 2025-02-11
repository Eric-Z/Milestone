import SwiftUI
import Foundation

struct MainMilestoneView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var milestone: Milestone
    
    var body: some View {
        HStack(spacing: 0) {
            let days = daysBetween(Date(), milestone.date)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(milestone.title)
                        .font(.system(size: 16))
                    if (days == 0) {
                        Text("就是今天！")
                            .font(.system(size: 16))
                            .foregroundStyle(.accent)
                    } else if (days > 0) {
                        Text("还有")
                            .font(.system(size: 16))
                    } else {
                        Text("已经")
                            .font(.system(size: 16))
                    }
                }
                
                HStack(spacing: 0) {
                    if (!milestone.tag.isEmpty) {
                        Text("#" + milestone.tag)
                            .font(.system(size: 12))
                            .foregroundStyle(.grayText)
                    }
                    if (!milestone.tag.isEmpty && !milestone.remark.isEmpty) {
                        Text("|")
                            .font(.system(size: 8))
                            .foregroundColor(.grayBorder)
                            .padding(.horizontal, 4)
                    }
                    if (!milestone.remark.isEmpty) {
                        Text(milestone.remark)
                            .font(.system(size: 12))
                            .foregroundStyle(.grayText)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 10)
            .padding(.leading, 16)
            
            Spacer()
            
            if (days != 0) {
                Text("\(abs(days))")
                    .font(.system(size: 18, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(days > 0 ? .blueDays: .accent)
                Text("天")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundStyle(days > 0 ? .blueDays: .accent)
                    .padding(.trailing, 16)
            } else {
                Text("🎉")
                    .font(.system(size: 18, design: .rounded))
                    .padding(.trailing, 16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.tag)
        )
        .contextMenu {
            Button {
            } label: {
                Label("编辑", systemImage: "pencil.tip.crop.circle")
            }
            Button(role: .destructive) {
                modelContext.delete(milestone)
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 10)
    }
    
    func daysBetween(_ from: Date, _ to: Date) -> Int {
        let calendar = Calendar.current
        let startOfFrom = calendar.startOfDay(for: from)
        let startOfTo = calendar.startOfDay(for: to)
        let components = calendar.dateComponents([.day], from: startOfFrom, to: startOfTo)
        return components.day ?? 0
    }
}
