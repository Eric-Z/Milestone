import SwiftUI
import SwiftData

struct MilestoneListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Query private var milestones: [Milestone]
    @State private var filteredMilestone: [Milestone] = []
    @State private var isAddMode = false;
    
    var folder: Folder
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(folder.name)")
                        .font(.system(size: FontSize.largeTitleText, weight: .semibold))
                    
                    if filteredMilestone.isEmpty {
                        Text("暂无里程碑")
                            .font(.system(size: FontSize.largeNoteText))
                            .foregroundStyle(.textNote)
                    } else {
                        HStack(spacing: 0) {
                            Text("\(filteredMilestone.count)")
                                .font(.system(size: FontSize.largeNoteNumber))
                                .foregroundStyle(.textNote)
                            Text("个里程碑")
                                .font(.system(size: FontSize.largeNoteText))
                                .foregroundStyle(.textNote)
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 0)
            .padding(.bottom, 12)
            
            if filteredMilestone.isEmpty && !isAddMode {
                NoMilestoneView()
            }
            if isAddMode {
                MilestoneView(folder: folder)
                    .padding(.horizontal, Distance.listPadding)
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(
            VStack {
                Spacer()
                
                Button {
                    isAddMode = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 54, height: 54)
                        .background(Color.textHighlight1)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding(.bottom, 50)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17))
                            .foregroundStyle(.textHighlight1)
                            
                        Text("文件夹")
                            .font(.system(size: 17))
                            .foregroundStyle(.textHighlight1)
                    }
                    .padding(.vertical, 11)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 17))
                        .foregroundStyle(.textHighlight1)
                }
            }
        }
        .onAppear {
            filteredMilestone = milestones.filter { milestone in
                milestone.folderId == folder.id.uuidString
            }
        }
    }
}

#Preview {
    let folder = Folder(name: "全部里程碑", sortOrder: 1)
    MilestoneListView(folder: folder)
}
