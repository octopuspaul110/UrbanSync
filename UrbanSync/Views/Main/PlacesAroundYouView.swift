import SwiftUI
import Kingfisher
import CoreLocation

struct PlacesAroundYouView: View {
    @State private var places: [EventPlace] = []
    @State private var isLoading = true
    @State private var locationService = LocationService()
    @State private var selectedPlace: EventPlace?
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView().tint(.urbanAccent)
                    Text("Finding places near you...")
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                }
            } else if places.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "mappin.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.urbanTextTertiary)
                    Text("No event places nearby")
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextPrimary)
                    Text("Events created near you will show their venues here")
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        Text("\(places.count) event places near you")
                            .font(.jakartaCaption)
                            .foregroundColor(.urbanTextTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(places) { place in
                            NavigationLink(destination: PlaceEventsView(place: place)) {
                                placeCard(place)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Places Around You")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            locationService.requestPermission()
            locationService.startUpdating()
            // Wait for location
            for _ in 0..<10 {
                try? await Task.sleep(for: .milliseconds(500))
                if locationService.currentLocation != nil { break }
            }
            await fetchPlaces()
        }
    }
    
    @ViewBuilder
    private func placeCard(_ place: EventPlace) -> some View {
        HStack(spacing: 14) {
            // Venue icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.urbanAccent.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.urbanAccent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(place.venueName)
                    .font(.jakarta(.semiBold, size: 15))
                    .foregroundColor(.urbanTextPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 10))
                    Text("\(place.city)\(place.state.map { ", \($0)" } ?? "")")
                        .font(.jakartaCaption)
                }
                .foregroundColor(.urbanTextSecondary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.system(size: 9))
                        Text("\(place.totalEvents) events")
                            .font(.jakartaCaption2)
                    }
                    .foregroundColor(.urbanTextTertiary)
                    
                    if place.upcomingCount > 0 {
                        HStack(spacing: 3) {
                            Circle().fill(Color.urbanMint).frame(width: 5, height: 5)
                            Text("\(place.upcomingCount) upcoming")
                                .font(.jakartaCaption2)
                        }
                        .foregroundColor(.urbanMint)
                    }
                    
                    if let dist = place.distanceKm {
                        Text(String(format: "%.1f km", dist))
                            .font(.jakartaCaption2)
                            .foregroundColor(.urbanAccent)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.urbanTextTertiary)
        }
        .padding(14)
        .background(Color.urbanSurface)
        .cornerRadius(14)
    }
    
    private func fetchPlaces() async {
        do {
            let lat = locationService.currentLocation?.latitude ?? 6.5244
            let lng = locationService.currentLocation?.longitude ?? 3.3792
            
            struct R: Decodable { let places: [EventPlace] }
            let r: R = try await APIClient.shared.get(
                "/api/events/places?lat=\(lat)&lng=\(lng)&radius_km=20",
                authenticated: false
            )
            places = r.places
            isLoading = false
        } catch {
            print("❌ fetchPlaces: \(error)")
            isLoading = false
        }
    }
}

// ── Place Events View ──
struct PlaceEventsView: View {
    let place: EventPlace
    @State private var pastEvents: [Event] = []
    @State private var upcomingEvents: [Event] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView().tint(.urbanAccent)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Venue header
                        VStack(alignment: .leading, spacing: 6) {
                            Text(place.venueName)
                                .font(.jakartaTitle2)
                                .foregroundColor(.urbanTextPrimary)
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.system(size: 12))
                                Text("\(place.city)\(place.state.map { ", \($0)" } ?? "")")
                                    .font(.jakartaCaption)
                            }
                            .foregroundColor(.urbanTextSecondary)
                            
                            Text("\(place.totalEvents) total events at this venue")
                                .font(.jakartaCaption2)
                                .foregroundColor(.urbanTextTertiary)
                        }
                        
                        // Upcoming events (clickable)
                        if !upcomingEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Upcoming Events")
                                        .font(.jakarta(.semiBold, size: 16))
                                        .foregroundColor(.urbanTextPrimary)
                                    Spacer()
                                    Text("\(upcomingEvents.count)")
                                        .font(.jakartaCaption2)
                                        .foregroundColor(.urbanMint)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.urbanMint.opacity(0.15))
                                        .cornerRadius(8)
                                }
                                
                                ForEach(upcomingEvents) { event in
                                    NavigationLink(destination: EventDetailView(eventId: event.id)) {
                                        venueEventCard(event, clickable: true)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Past events (not clickable)
                        if !pastEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Past Events")
                                        .font(.jakarta(.semiBold, size: 16))
                                        .foregroundColor(.urbanTextTertiary)
                                    Spacer()
                                    Text("\(pastEvents.count)")
                                        .font(.jakartaCaption2)
                                        .foregroundColor(.urbanTextTertiary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.urbanSurfaceLight)
                                        .cornerRadius(8)
                                }
                                
                                ForEach(pastEvents) { event in
                                    venueEventCard(event, clickable: false)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle(place.venueName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await fetchPlaceEvents() }
    }
    
    @ViewBuilder
    private func venueEventCard(_ event: Event, clickable: Bool) -> some View {
        HStack(spacing: 12) {
            if let urlStr = event.coverImageUrl, let url = URL(string: urlStr) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.categoryColor(for: event.category ?? "").opacity(0.3))
                    .frame(width: 56, height: 56)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.jakarta(.medium, size: 14))
                    .foregroundColor(clickable ? .urbanTextPrimary : .urbanTextTertiary)
                    .lineLimit(1)
                Text(event.startTime.formatted(.dateTime.day().month(.abbreviated).year()))
                    .font(.jakartaCaption2)
                    .foregroundColor(.urbanTextTertiary)
                if let cat = event.category {
                    Text(cat.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.system(size: 9))
                        .foregroundColor(.urbanTextTertiary)
                }
            }
            
            Spacer()
            
            if clickable {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundColor(.urbanTextTertiary)
            }
        }
        .padding(12)
        .background(Color.urbanSurface)
        .cornerRadius(12)
        .opacity(clickable ? 1.0 : 0.6)
    }
    
    private func fetchPlaceEvents() async {
        do {
            let encoded = place.venueName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? place.venueName
            struct R: Decodable { let events: [Event]; let total: Int; let has_more: Bool }
            let r: R = try await APIClient.shared.get(
                "/api/events/search?venue=\(encoded)&limit=50",
                authenticated: false
            )
            let now = Date()
            upcomingEvents = r.events.filter { $0.endTime > now }
            pastEvents = r.events.filter { $0.endTime <= now }
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

// ── Model ──
struct EventPlace: Codable, Identifiable {
    var id: String { venueName }
    let venueName: String
    let city: String
    let state: String?
    let latitude: Double?
    let longitude: Double?
    let totalEvents: Int
    let upcomingCount: Int
    let distanceKm: Double?
    
    enum CodingKeys: String, CodingKey {
        case city, state, latitude, longitude
        case venueName = "venue_name"
        case totalEvents = "total_events"
        case upcomingCount = "upcoming_count"
        case distanceKm = "distance_km"
    }
}