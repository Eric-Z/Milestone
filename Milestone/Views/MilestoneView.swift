import SwiftUI
import SwiftData
import Foundation

struct MilestoneView: View {
    
    @Query(sort: \Folder.sortOrder) private var folders: [Folder]
    
    var folder: Folder
    var milestone: Milestone
    
    var body: some View {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: milestone.date).day ?? 0
        
        HStack(spacing: 0) {
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
                
                let milestoneFolder = folders.first{ $0.id.uuidString == milestone.folderId }!
                if folder.id == Constants.FOLDER_ALL_UUID && milestoneFolder.id != Constants.FOLDER_ALL_UUID {
                    HStack(spacing: 0) {
                        Group {
                            Image(systemName: "folder")
                                
                            Text(milestoneFolder.name)
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
        .padding(.horizontal, Distances.itemPaddingH)
        .padding(.vertical, Distances.itemPaddingV)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(milestone.pinned ? (days > 0 ? .textHighlight2 : .textHighlight1) : .areaItem)
        .cornerRadius(21)
    }
}

#Preview {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    let folder = Folder(name: "旅行", sortOrder: 1)
    
    let milestone = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", remark: "冲绳一下", date: formatter.date(from: "2025-04-25")!)
    milestone.pinned = true
    
    return MilestoneView(folder: folder, milestone: milestone)
}
