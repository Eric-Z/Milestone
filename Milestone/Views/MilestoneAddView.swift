import SwiftUI
import SwiftData

struct MilestoneAddView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var type: String = "Multi-Day"
    @State private var allDay: Bool = true
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var repeatType: String = "Never"
    @State private var photos: [Image] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Title
                TextField("Title", text: $title)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                // Type + Date Section
                VStack(alignment: .leading, spacing: 8) {
                    sectionRow("Type", value: type)
                    Divider()
                    Toggle(isOn: $allDay) {
                        Text("All-Day")
                    }
                    Divider()
                    datePickerRow(title: "Starts", date: $startDate)
                    Divider()
                    datePickerRow(title: "Ends", date: $endDate)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                .padding(.horizontal)
                
                // Repeat Section
                VStack(alignment: .leading, spacing: 8) {
                    sectionRow("Repeat", value: repeatType)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                .padding(.horizontal)
                
                // Photos Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Photos")
                        Spacer()
                        Text("\(photos.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        ForEach(0..<min(5, photos.count), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(width: 60, height: 60)
                        }
                        Spacer()
                    }
                    
                    Button("Add More...") {
                        // action to add photo
                    }
                    .font(.callout)
                    .foregroundStyle(.orange)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.medium)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        //                        self.save()
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.medium)
                    }
                    .tint(.textHighlight1)
                    .disabled(self.title.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Reusable Components
    
    @ViewBuilder
    private func sectionRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private func datePickerRow(title: String, date: Binding<Date>) -> some View {
        HStack {
            Text(title)
            Spacer()
            DatePicker("", selection: date, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .fixedSize()
        }
    }
}

#Preview {
    MilestoneAddView()
}
