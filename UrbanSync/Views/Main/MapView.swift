//
//  MapView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//

import SwiftUI
import MapKit
 
struct MapView: View {
    
    @State private var locationService = LocationService()
    @State private var events: [Event] = []
    @State private var selectedEvent: Event?
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
 
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map
                Map(position: $cameraPosition, selection: $selectedEvent) {
                    // User location dot.
                    UserAnnotation()
 
                    // Event pins.
                    ForEach(events.filter { $0.latitude != nil && $0.longitude != nil }) { event in
                        Annotation(event.title, coordinate: CLLocationCoordinate2D(
                            latitude: event.latitude!,
                            longitude: event.longitude!
                        ), anchor: .bottom) {
                            // Custom pin: category-colored circle with icon.
                            VStack(spacing: 0) {
                                Image(systemName: categoryIcon(for: event.category ?? ""))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(Color.categoryColor(for: event.category ?? ""))
                                    .clipShape(Circle())
                                    .shadow(color: Color.categoryColor(for: event.category ?? "").opacity(0.5), radius: 6)
                                // Triangle point below the circle.
                                Triangle()
                                    .fill(Color.categoryColor(for: event.category ?? ""))
                                    .frame(width: 12, height: 8)
                            }
                            .onTapGesture { selectedEvent = event }
                        }
                        .tag(event)
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea()
 
                // ── Bottom Card (when event is selected) ──
                if let event = selectedEvent {
                    NavigationLink(value: event.id) {
                        EventCardView(event: event)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100)
                            .transition(.move(edge: .bottom))
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: UUID.self) { eventId in
                EventDetailView(eventId: eventId)
            }
            .task {
                locationService.requestPermission()
                await fetchNearbyEvents()
            }
        }
    }
 
    private func fetchNearbyEvents() async {
        // Default to Lagos coordinates if location not available.
        let lat = locationService.currentLocation?.latitude ?? 6.5244
        let lng = locationService.currentLocation?.longitude ?? 3.3792
 
        do {
            let response: PaginatedResponse<Event> = try await APIClient.shared.get(
                "/api/events/nearby?lat=\(lat)&lng=\(lng)&radius_km=50",
                authenticated: false
            )
            self.events = response.events ?? []
        } catch { }
    }
 
    private func categoryIcon(for category: String) -> String {
        switch category {
        case "celebration": return "party.popper.fill"
        case "nightlife": return "moon.stars.fill"
        case "tech": return "laptopcomputer"
        case "concert": return "music.mic"
        case "sports": return "sportscourt.fill"
        default: return "mappin"
        }
    }
}
 
// Triangle shape for the pin pointer.
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}

#Preview {
    MapView()
}
