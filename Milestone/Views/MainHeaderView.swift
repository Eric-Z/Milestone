import SwiftUI

struct MainHeaderView: View {
    
    @State var milestones: [Milestone]
    
    var body: some View {
        VStack {
            HStack {
                Text("MileStone")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            if (!milestones.isEmpty) {
                HStack {
                    Text("\(milestones.count) 个里程碑")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color.grayText)
                    
                    Spacer()
                }
            }
        }
    }
}
