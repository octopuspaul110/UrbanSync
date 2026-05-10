
import SwiftUI
import Kingfisher

struct EventSeriesView: View {
    let eventId: UUID
    @State private var parent: SeriesParent?
    @State private var instances: [SeriesInstance] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView().tint(.urbanAccent)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Parent info
                        if let parent {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(parent.title)
                                    .font(.jakartaTitle2)
                                    .foregroundColor(.urbanTextPrimary)
                                
                                HStack(spacing: 12) {
                                    if let recurrence = parent.recurrence {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 11))
                                            Text(recurrence.capitalized)
                                                .font(.jakartaCaption)
                                        }
                                        .foregroundColor(.urbanAccent)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.urbanAccent.opacity(0.12))
                                        .cornerRadius(8)
                                    }
                                    
                                    if let venue = parent.venueName {
                                        HStack(spacing: 4) {
                                            Image(systemName: "mappin")
                                                .font(.system(size: 10))
                                            Text("\(venue)\(parent.city.map { ", \($0)" } ?? "")")
                                                .font(.jakartaCaption)
                                        }
                                        .foregroundColor(.urbanTextSecondary)
                                    }
                                }
                                
                                if let days = parent.recurrenceDays, !days.isEmpty {
                                    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                                    let dayStr = days.sorted().map { dayNames[$0] }.joined(separator: ", ")
                                    Text("Every \(dayStr)")
                                        .font(.jakartaCaption)
                                        .foregroundColor(.urbanTextTertiary)
                                }
                                
                                if let endDate = parent.recurrenceEndDate {
                                    Text("Series ends \(endDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.jakartaCaption2)
                                        .foregroundColor(.urbanTextTertiary)
                                }
                            }
                            .padding(16)
                            .background(Color.urbanSurface)
                            .cornerRadius(14)
                        }
                        
                        // Instances
                        Text("Upcoming (\(instances.count))")
                            .font(.jakarta(.semiBold, size: 16))
                            .foregroundColor(.urbanTextPrimary)
                        
                        if instances.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 36))
                                    .foregroundColor(.urbanTextTertiary)
                                Text("No upcoming instances")
                                    .font(.jakartaCaption)
                                    .foregroundColor(.urbanTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(instances) { instance in
                                NavigationLink(destination: EventDetailView(eventId: instance.id)) {
                                    instanceCard(instance)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Event Series")
        .navigationBarTitleDisplayMode(.inline)
        .task { await fetchSeries() }
    }
    
    @ViewBuilder
    private func instanceCard(_ instance: SeriesInstance) -> some View {
        let isLive = instance.startTime <= Date() && instance.endTime > Date()
        let isPast = instance.endTime <= Date()
        
        HStack(spacing: 14) {
            // Date block
            VStack(spacing: 2) {
                Text(instance.startTime.formatted(.dateTime.day()))
                    .font(.jakarta(.bold, size: 22))
                    .foregroundColor(isLive ? .urbanCoral : isPast ? .urbanTextTertiary : .urbanAccent)
                Text(instance.startTime.formatted(.dateTime.month(.abbreviated)))
                    .font(.jakartaCaption2)
                    .foregroundColor(.urbanTextSecondary)
                Text(instance.startTime.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 9))
                    .foregroundColor(.urbanTextTertiary)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(instance.startTime.formatted(.dateTime.hour().minute()))
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextPrimary)
                    Text("—")
                        .foregroundColor(.urbanTextTertiary)
                    Text(instance.endTime.formatted(.dateTime.hour().minute()))
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextSecondary)
                }
                
                HStack(spacing: 8) {
                    if isLive {
                        LiveBadge()
                    }
                    
                    if let occ = instance.occurrenceNumber {
                        Text("#\(occ)")
                            .font(.jakartaCaption2)
                            .foregroundColor(.urbanTextTertiary)
                    }
                    
                    Text(instance.status.capitalized)
                        .font(.jakarta(.medium, size: 10))
                        .foregroundColor(instance.status == "published" ? .urbanMint : .urbanTextTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((instance.status == "published" ? Color.urbanMint : Color.urbanSurfaceLight).opacity(0.15))
                        .cornerRadius(4)
                }
                
                Text(instance.joinCode)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.urbanTextTertiary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.urbanTextTertiary)
        }
        .padding(14)
        .background(Color.urbanSurface)
        .cornerRadius(12)
        .opacity(isPast ? 0.5 : 1.0)
    }
    
    private func fetchSeries() async {
        do {
            let response: SeriesResponse = try await APIClient.shared.get(
                "/api/events/\(eventId)/series"
            )
            parent = response.parent
            instances = response.upcomingInstances
            isLoading = false
        } catch {
            print("❌ fetchSeries: \(error)")
            isLoading = false
        }
    }
}

// Models
struct SeriesResponse: Decodable {
    let parent: SeriesParent
    let upcomingInstances: [SeriesInstance]
    let totalUpcoming: Int
    
    enum CodingKeys: String, CodingKey {
        case parent
        case upcomingInstances = "upcoming_instances"
        case totalUpcoming = "total_upcoming"
    }
}

struct SeriesParent: Decodable {
    let id: UUID
    let title: String
    let recurrence: String?
    let recurrenceDays: [Int]?
    let recurrenceInterval: Int?
    let recurrenceEndDate: Date?
    let venueName: String?
    let city: String?
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, recurrence, city, category
        case recurrenceDays = "recurrence_days"
        case recurrenceInterval = "recurrence_interval"
        case recurrenceEndDate = "recurrence_end_date"
        case venueName = "venue_name"
    }
}

struct SeriesInstance: Decodable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let slug: String
    let joinCode: String
    let status: String
    let occurrenceNumber: Int?
    let isPaid: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, slug, status
        case startTime = "start_time"
        case endTime = "end_time"
        case joinCode = "join_code"
        case occurrenceNumber = "occurence_number"
        case isPaid = "is_paid"
    }
}