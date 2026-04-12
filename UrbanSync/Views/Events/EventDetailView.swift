//
//  EventDetailView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI
import Kingfisher
import MapKit

struct EventDetailView: View {
    let eventId : UUID
    @State private var event : Event?
    @State private var tiers : [TicketTier] = []
    @State private var rsvpCount : Int = 0
    @State private var isLoading : Bool = true
    @State private var showTicketPurchase : Bool = false
    @State private var scrollOffset: CGFloat = 0
    
    private var isScrolled: Bool { scrollOffset > 180 }
    
    private func fallbackColor(_ cat : String) -> Color {
        switch cat.lowercased() {
        case "sports"       :   return .green
        case "concert"      :   return .orange
        case "tech"         :   return .blue
        case "celebration"  :   return .pink
        case "nightlife"    :   return .purple
        case "heritage"     :   return .brown
        case "conference"   :   return .teal
        case "corporate"    :   return .yellow
        case "art"          :   return .indigo
        case "public_square":   return .cyan
        default             :   return Color.urbanAccent
        }
    }
    
    var body: some View {
        ZStack(alignment : .top) {
            Color.urbanBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView().tint(.urbanAccent)
            } else if let event = event {
                
//                Scrollable content
                ScrollView {
                    VStack(alignment : .leading,spacing : 0) {
                        
                        // Scroll offset tracker
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named("detailScroll")).minY
                            )
                        }
                        .frame(height: 0)
                        
//                        Cover Image with Gradient overlay
                        ZStack(alignment: .bottomLeading){
                            if let url = event.coverImageUrl.flatMap({URL(string : $0)}) {
                                KFImage(url)
                                    .resizable()
                                    .aspectRatio(16/9,contentMode: .fill)
                                    .frame(height: 250)
                                    .clipped()
                            } else {
                                ZStack {
                                    fallbackColor(event.category ?? "")
                                        .opacity(0.3)
                                        .frame(height: 250)
                                    Image(systemName: categoryIcon(event.category ?? ""))
                                        .font(.system(size: 64))
                                        .foregroundColor(fallbackColor(event.category ?? "").opacity(0.6))
                                }
                                .frame(height: 250)
                            }
//                            Dark gradient from bottom for text readability.
                            LinearGradient(
                                colors : [fallbackColor(event.category ?? ""),.urbanBackground],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height : 120)
                            .frame(maxHeight: .infinity,alignment: .bottom)
                            
//                            Status Badges
                            HStack(spacing : 8) {
                                if let category = event.category {
                                    EventBadge(
                                        text: category.replacingOccurrences(of: "_", with: " ").capitalized,
                                        color: fallbackColor(category),
                                        icon: categoryIcon(category)
                                    )
                                }
                                
                                if event.isLive {
                                    EventBadge(
                                        text: "LIVE",
                                        color: .urbanCoral,
                                        icon: "antenna.radiowaves.left.and.right"
                                    )
                                } else if event.isUpcoming {
                                    EventBadge(
                                        text: "UPCOMING",
                                        color: .urbanGold,
                                        icon: "clock.fill"
                                    )
                                }
                                EventBadge(
                                    text: event.visibility == "private" ? "PRIVATE" : "PUBLIC",
                                    color: event.visibility == "private" ? .urbanAccent : .urbanMint,
                                    icon: event.visibility == "private" ? "lock.fill" : "globe"
                                )
                                if let cheapest = tiers.min(by: {$0.priceKobo < $1.priceKobo}){
                                    EventBadge(
                                        text: cheapest.priceKobo == 0 ? "FREE RSVP" : cheapest.formattedPrice,
                                        color: cheapest.priceKobo == 0 ? .urbanMint : .urbanGold,
                                        icon: cheapest.priceKobo == 0 ? "gift.fill" : "ticket.fill"
                                    )
                                }
                            }
                            .padding(16)
                        }
//                        Glowing Progress Bar
//                        from event creation to start
                        if !event.hasEnded, let created = event.createdAt{
                            VStack(alignment: .leading,spacing : 4) {
                                GlowingProgressBar(
                                    progress: event.startTime.progressUntilStart(createdAt: created),
//                                    color: Color.categoryColor(for: event.category ?? "")
                                )
                                Text(event.startTime.relativeFormatted)
                                    .font(.jakartaCaption)
                                    .foregroundColor(.urbanTextSecondary)
                            }
                            .padding(.horizontal,16)
                            .padding(.top,12)
                        }
//                        Event Info
                        VStack(alignment: .leading,spacing: 16) {
//                            Title
                            Text(event.title)
                                .font(.jakartaTitle.weight(.bold))
                                .foregroundColor(.urbanTextPrimary)
                            
                            // Creator row
                            if let creator = event.creatorName {
                                HStack(spacing: 10) {
                                    // Creator avatar circle
                                    ZStack {
                                        Circle()
                                            .fill(fallbackColor(event.category ?? "").opacity(0.3))
                                            .frame(width: 36, height: 36)
                                        Text(creator.prefix(2).uppercased())
                                            .font(.jakartaCaption.weight(.medium))
                                            .foregroundColor(fallbackColor(event.category ?? ""))
                                    }
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("Hosted by")
                                            .font(.jakartaCaption)
                                            .foregroundColor(.urbanTextTertiary)
                                        Text(creator)
                                            .font(.jakartaSubheadline.weight(.medium))
                                            .foregroundColor(.urbanTextSecondary)
                                    }
                                }
                            }
                            
//                            Date and Time
                            detailRow(
                                icon : "calendar",
                                text : event.startTime.fullFormatted
                            )
                            
                            // Recurrence
                            if let summary = recurrenceSummary(for: event) {
                                VStack(alignment: .leading, spacing: 10) {

                                    // Recurrence row
                                    detailRow(icon: "arrow.clockwise", text: summary)

                                    // Occurrence number — e.g "Week 12 of Lagos Friday Night"
                                    if let occurrence = event.occurrenceNumber, let parentId = event.recurrenceParentId {
                                        HStack(spacing: 8) {
                                            Image(systemName: "number.circle.fill")
                                                .foregroundColor(.urbanAccent)
                                                .frame(width: 20)
                                            Text("Occurrence \(occurrence) of this series")
                                                .foregroundColor(.urbanTextSecondary)
                                                .font(.subheadline)
                                        }
                                    }

                                    // End date
                                    if let endDate = event.recurrenceEndDate {
                                        detailRow(
                                            icon: "calendar.badge.checkmark",
                                            text: "Series ends \(endDate.formatted(date: .abbreviated, time: .omitted))"
                                        )
                                    }

                                    // Series pill — tappable if it's a child instance
                                    if event.recurrenceParentId != nil {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.clockwise")
                                                .font(.system(size: 10))
                                            Text("Part of a recurring series")
                                                .font(.jakartaCaption)
                                        }
                                        .foregroundColor(.urbanAccent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.urbanAccent.opacity(0.1))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            
//                            Venue
                            if let venue = event.venueName {
                                detailRow(
                                    icon : "mappin.and.ellipse",
                                    text : "\(venue)\(event.city.map{", \($0)"} ?? "")\(event.state.map { ", \($0)" } ?? "")"
                                )
                            }
                            
                            // Dress code
                            if let dress = event.dressCode, !dress.isEmpty {
                                detailRow(icon: "tshirt.fill", text: dress)
                            }
                            
                            // RSVP Count
                            detailRow(icon : "person.2.fill",text : "\(rsvpCount) attending")
                            
//                            Map
                            if let lat = event.latitude, let lng = event.longitude{
                                VStack(spacing : 12){
//                                    Small map preview showing the event pin.
                                    Map(initialPosition : .region(MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    ))){
                                        Marker(event.venueName ?? event.title,coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng))
                                            .tint(Color.categoryColor(for: event.category ?? ""))
                                    }
                                    .frame(height: 150)
                                    .cornerRadius(12)
                                    .allowsHitTesting(false) //Prevent map gestures; it is just a preview.
                                    
//                                    Direction Buttons
                                    HStack(spacing : 12){
//                                        Apple Maps button
                                        Button {
//                                            Apple Maps URL scheme.
//                                            "daddr" = destination address (lat,lng)
//                                            "dirflg=d = driving directions.
                                            if let url = URL(string : "http://maps.apple.com/?daddr=\(lat),\(lng)&dirflg=d"){
                                                UIApplication.shared.open(url)
                                            }
                                        } label : {
                                            Label("Apple Maps",systemImage : "map.fill")
                                                .font(.jakartaSubheadline)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical,10)
                                                .background(Color.urbanSurface)
                                                .foregroundColor(.urbanTextPrimary)
                                                .cornerRadius(10)
                                        }
//                                        Google Maps button
                                        Button {
                                            let googleMapsURL = URL(string: "comgooglemaps://?daddr=\(lat),\(lng)&directionsmode=driving")!
//                                            Google Maps URL scheme
                                            let webURL = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lng)")!
                                            UIApplication.shared.open(
                                                UIApplication.shared.canOpenURL(googleMapsURL) ? googleMapsURL : webURL
                                            )
                                        } label : {
                                            Label("Google Maps",systemImage: "location.fill")
                                                .font(.jakartaSubheadline)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical,10)
                                                .background(Color.urbanSurface)
                                                .foregroundColor(.urbanTextPrimary)
                                                .cornerRadius(10)
                                        }
                                    }
                                }.padding(.top,8)
                            }

//                            Description
                            if let desc = event.description {
                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.urbanTextSecondary)
                                    .padding(.top,8)
                            }
                            
                            // Metadata
                            if let metadata = event.metadata,
                               let dict = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(metadata)) as? [String: String],
                               !dict.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Extra details")
                                        .font(.jakartaHeadline.weight(.medium))
                                        .foregroundColor(.urbanTextPrimary)
                                    ForEach(dict.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(key.replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(.jakartaCaption)
                                                .foregroundColor(.urbanTextTertiary)
                                            Text(value)
                                                .font(.jakartaSubheadline)
                                                .foregroundColor(.urbanTextSecondary)
                                        }
                                        .padding(12)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.urbanSurface)
                                        .cornerRadius(10)
                                    }
                                }
                                .padding(.top, 8)
                            }
                            
//                            Ticket Tiers
                            if !tiers.isEmpty {
                                VStack(alignment: .leading,spacing: 12) {
                                    Text("Tickets")
                                        .font(.jakartaHeadline.weight(.medium))
                                        .foregroundColor(.urbanTextPrimary)
                                    ForEach(tiers) { tier in
                                        tierCard(tier)
                                    }
                                }
                                .padding(.top,8)
                            }
                            Spacer(minLength: 80)
                        }
                        .padding(16)
                    }
                }
                .coordinateSpace(name: "detailScroll")
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        scrollOffset = value
                    }
                }
                
                // Sticky nav bar — always on top
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        // Back button
                        Button {
                            // dismiss handled by NavigationStack
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(isScrolled ? Color.clear : Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }

                        // Creator avatar + title fade in on scroll
                        if isScrolled, let creator = event.creatorName {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(fallbackColor(event.category ?? "").opacity(0.4))
                                        .frame(width: 28, height: 28)
                                    Text(creator.prefix(2).uppercased())
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                Text(event.title)
                                    .font(.jakartaSubheadline.weight(.medium))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Spacer()

                        // Share
                        ShareLink(item: URL(string: "https://urbansync.app/e/\(event.slug)")!) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(isScrolled ? Color.white.opacity(0.15) : Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                    if isScrolled {
                        Divider()
                            .background(Color.white.opacity(0.1))
                    }
                }
                .background(
                    isScrolled
                        ? Color.urbanBackground.opacity(0.85)
                        : Color.clear
                )
                .background {
                    if isScrolled {
                        Color.urbanBackground
                            .background(.ultraThinMaterial)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isScrolled)
                
//                Bottom Action Bar
                VStack {
                    Spacer()
                    HStack(spacing : 12) {
                        Button {
                            showTicketPurchase = true
                        } label: {
                            Text(tiers.allSatisfy { $0.priceKobo == 0 } ? "RSVP Free" : "Get Tickets")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.urbanAccent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal,16)
                    .padding(.vertical,12)
                    .background(Color.urbanBackground.opacity(0.95))
                }
            }
        }
        .navigationBarHidden(true) // we handle our own nav bar
        .task { await fetchEventDetail() }
        .sheet(isPresented: $showTicketPurchase) {
            if let event = event {
                TicketPurchaseView(event: event, tiers: tiers)
            }
        }
    }
    private func categoryIcon(_ cat: String) -> String {
        switch cat.lowercased() {
        case "sports":        return "sportscourt.fill"
        case "concert":       return "music.mic"
        case "tech":          return "laptopcomputer"
        case "celebration":   return "party.popper.fill"
        case "nightlife":     return "moon.stars.fill"
        case "heritage":      return "building.columns.fill"
        case "corporate":     return "briefcase.fill"
        case "community":     return "person.3.fill"
        case "public_square": return "megaphone.fill"
        default:              return "calendar"
        }
    }
    
    private func recurrenceSummary(for event: Event) -> String? {
        guard let recurrence = event.recurrence, recurrence != "none" else { return nil }

        let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let interval = event.recurrenceInterval ?? 1

        switch recurrence {
        case "daily":
            return interval == 1 ? "Repeats every day" : "Repeats every \(interval) days"
        case "weekly":
            let days = (event.recurrenceDays ?? []).sorted().map { dayNames[$0] }.joined(separator: ", ")
            return "Repeats every week\(days.isEmpty ? "" : " on \(days)")"
        case "biweekly":
            let days = (event.recurrenceDays ?? []).sorted().map { dayNames[$0] }.joined(separator: ", ")
            return "Repeats every 2 weeks\(days.isEmpty ? "" : " on \(days)")"
        case "monthly":
            return interval == 1 ? "Repeats every month" : "Repeats every \(interval) months"
        case "custom":
            return "Custom schedule"
        default:
            return nil
        }
    }
    
//    Detail Row
    private func detailRow(icon :String,text : String) -> some View {
        HStack(spacing : 8) {
            Image(systemName: icon)
                .foregroundColor(.urbanAccent)
                .frame(width : 20)
            Text(text)
                .foregroundColor(.urbanTextSecondary)
        }
        .font(.subheadline)
    }
    
//    Helper :Tier Card
    private func tierCard(_ tier : TicketTier) -> some View {
        HStack {
            VStack(alignment: .leading,spacing : 4) {
                Text(tier.name)
                    .font(.jakartaHeadline.weight(.semibold))
                    .foregroundColor(.urbanTextSecondary)
                if let desc = tier.description {
                    Text(desc)
                        .font(.jakartaSubheadline.weight(.bold))
                        .foregroundColor(tier.priceKobo == 0 ? .urbanMint : .urbanGold)
                }
            }
            Spacer()
            VStack(alignment : .trailing,spacing : 4){
                if tier.isSoldOut {
                    Text("SOLD OUT")
                        .font(.jakartaCaption2.weight(.bold))
                        .foregroundColor(.urbanCoral)
                } else {
                    Text("\(tier.quantityTotal - tier.quantitySold) left")
                        .font(.caption2)
                        .foregroundColor(.urbanTextTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.urbanSurface)
        .cornerRadius(12)
    }
    
    private func fetchEventDetail() async {
        do {
            struct DetailResponse : Decodable {
                let event       : Event
                let tiers       : [TicketTier]
                let rsvp_count  : Int
            }
            let response : DetailResponse = try await APIClient.shared.get("/api/events/\(eventId)", authenticated: false)
            self.event     = response.event
            self.tiers     = response.tiers
            self.rsvpCount = response.rsvp_count
            self.isLoading = false
        } catch {
            self.isLoading = false
        }
    }
}

//#Preview {
//    EventDetailView()
//}
