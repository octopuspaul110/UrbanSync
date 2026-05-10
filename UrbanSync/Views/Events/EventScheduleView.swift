
import SwiftUI

struct EventScheduleView: View {
    let eventId: UUID
    let isCreator: Bool
    @State private var items: [ScheduleItem] = []
    @State private var isLoading = true
    @State private var showAddItem = false
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView().tint(.urbanAccent)
            } else if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 40))
                        .foregroundColor(.urbanTextTertiary)
                    Text("No schedule yet")
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextPrimary)
                    if isCreator {
                        Button {
                            showAddItem = true
                        } label: {
                            Text("Add first session")
                                .font(.jakarta(.medium, size: 14))
                                .foregroundColor(.urbanAccent)
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            scheduleRow(item)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isCreator {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.urbanAccent)
                    }
                }
            }
        }
        .task { await fetchSchedule() }
        .sheet(isPresented: $showAddItem) {
            AddScheduleItemView(eventId: eventId) {
                Task { await fetchSchedule() }
            }
        }
    }
    
    @ViewBuilder
    private func scheduleRow(_ item: ScheduleItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Time column
            VStack(spacing: 2) {
                Text(item.startTime.formatted(.dateTime.hour().minute()))
                    .font(.jakarta(.semiBold, size: 13))
                    .foregroundColor(.urbanAccent)
                Text(item.endTime.formatted(.dateTime.hour().minute()))
                    .font(.jakartaCaption2)
                    .foregroundColor(.urbanTextTertiary)
            }
            .frame(width: 50)
            
            // Timeline dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.urbanAccent)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.urbanAccent.opacity(0.2))
                    .frame(width: 2)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.jakarta(.semiBold, size: 15))
                    .foregroundColor(.urbanTextPrimary)
                
                if let desc = item.description, !desc.isEmpty {
                    Text(desc)
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                        .lineLimit(3)
                }
                
                if let speaker = item.speakerName {
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 10))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(speaker)
                                .font(.jakarta(.medium, size: 12))
                            if let title = item.speakerTitle {
                                Text(title)
                                    .font(.jakartaCaption2)
                                    .foregroundColor(.urbanTextTertiary)
                            }
                        }
                    }
                    .foregroundColor(.urbanTextSecondary)
                }
                
                if let location = item.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 9))
                        Text(location)
                            .font(.jakartaCaption2)
                    }
                    .foregroundColor(.urbanTextTertiary)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    private func fetchSchedule() async {
        do {
            struct R: Decodable { let schedule: [ScheduleItem] }
            let r: R = try await APIClient.shared.get(
                "/api/events/\(eventId)/schedule", authenticated: false
            )
            items = r.schedule
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

// Add Schedule Item
struct AddScheduleItemView: View {
    let eventId: UUID
    var onSaved: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var speakerName = ""
    @State private var speakerTitle = ""
    @State private var location = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        field("Session Title") {
                            TextField("e.g Opening Keynote", text: $title)
                        }
                        field("Description") {
                            TextField("What this session covers", text: $description, axis: .vertical)
                                .lineLimit(3...5)
                        }
                        field("Speaker Name") {
                            TextField("e.g John Doe", text: $speakerName)
                        }
                        field("Speaker Title") {
                            TextField("e.g CTO, TechCorp", text: $speakerTitle)
                        }
                        field("Location / Room") {
                            TextField("e.g Hall A", text: $location)
                        }
                        field("Start Time") {
                            DatePicker("", selection: $startTime)
                                .tint(.urbanAccent)
                        }
                        field("End Time") {
                            DatePicker("", selection: $endTime, in: startTime...)
                                .tint(.urbanAccent)
                        }
                        
                        if let error = errorMessage {
                            Text(error).font(.jakartaCaption).foregroundColor(.urbanCoral)
                        }
                        
                        Button {
                            Task { await save() }
                        } label: {
                            Text(isSaving ? "Saving..." : "Add Session")
                                .font(.jakarta(.semiBold, size: 16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(title.isEmpty ? Color.urbanSurfaceLight : Color.urbanAccent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(title.isEmpty || isSaving)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Add Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundColor(.urbanTextPrimary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func field<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.jakartaCaption).foregroundColor(.urbanTextSecondary)
            content()
                .font(.jakartaBody)
                .foregroundColor(.urbanTextPrimary)
                .padding(12)
                .background(Color.urbanSurface)
                .cornerRadius(10)
        }
    }
    
    private func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            struct Body: Encodable {
                let title: String
                let description: String?
                let speaker_name: String?
                let speaker_title: String?
                let location: String?
                let start_time: String
                let end_time: String
            }
            let fmt = ISO8601DateFormatter()
            struct R: Decodable { let schedule_item_id: UUID }
            let _: R = try await APIClient.shared.post(
                "/api/events/\(eventId)/schedule",
                body: Body(
                    title: title,
                    description: description.isEmpty ? nil : description,
                    speaker_name: speakerName.isEmpty ? nil : speakerName,
                    speaker_title: speakerTitle.isEmpty ? nil : speakerTitle,
                    location: location.isEmpty ? nil : location,
                    start_time: fmt.string(from: startTime),
                    end_time: fmt.string(from: endTime)
                )
            )
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct ScheduleItem: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String?
    let speakerName: String?
    let speakerTitle: String?
    let startTime: Date
    let endTime: Date
    let location: String?
    let sortOrder: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, location
        case speakerName = "speaker_name"
        case speakerTitle = "speaker_title"
        case startTime = "start_time"
        case endTime = "end_time"
        case sortOrder = "sort_order"
    }
}