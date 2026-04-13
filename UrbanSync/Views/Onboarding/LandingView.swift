//
//  LandingView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 13/04/2026.
//
import SwiftUI
import Kingfisher
import Combine

struct LandingView: View {
    var authVM: AuthViewModel
    var previewEvents   : [Event]? = nil
    var onNavigate      : (AppTab) -> Void
    
    enum AppTab {
        case home, search, tickets
    }
    
    @State private var featuredEvents   : [Event] = []
    @State private var currentIndex     : Int = 0
    @State private var isAnimating      : Bool = false
    @State private var textOpacity      : Double = 1
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .bottom) {
            // Banner
            ZStack {
                if featuredEvents.isEmpty {
                    Color.urbanBackground.ignoresSafeArea()
                } else {
                    ForEach(Array(featuredEvents.enumerated()), id: \.offset) { index, event in
                        bannerSlide(event: event)
                            .opacity(currentIndex == index ? 1 : 0)
                            .animation(.easeInOut(duration: 0.8), value: currentIndex)
                    }
                }
            }
            .ignoresSafeArea()

            // Fade to black
            LinearGradient(
                colors    : [.clear, Color.urbanBackground.opacity(0.5), Color.urbanBackground],
                startPoint: .top,
                endPoint  : .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Event meta
                if !featuredEvents.isEmpty {
                    let event = featuredEvents[currentIndex]
                    VStack(alignment: .leading, spacing: 5) {
                        Text("BY \((event.creatorName ?? "").uppercased())")
                            .font(.custom("Chillax-Variable", size: 9))
                            .foregroundColor(.white.opacity(0.4))
                            .kerning(1.5)

                        Text(event.title)
                            .font(.custom("Chillax-Variable", size: 22))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        Text("\(event.startTime.shortFormatted) · \(event.venueName ?? "")\(event.city.map { ", \($0)" } ?? "")")
                            .font(.custom("Chillax-Variable", size: 11))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .opacity(textOpacity)
                }

                // Dots
                HStack(spacing: 4) {
                    ForEach(0..<max(featuredEvents.count, 1), id: \.self) { i in
                        Capsule()
                            .fill(i == currentIndex ? Color.white : Color.white.opacity(0.2))
                            .frame(width: i == currentIndex ? 14 : 5, height: 5)
                            .animation(.spring(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Label
                Text("WHAT WOULD YOU LIKE TO DO?")
                    .font(.custom("Chillax-Variable", size: 9))
                    .foregroundColor(.white.opacity(0.35))
                    .kerning(2)
                    .padding(.bottom, 14)

                // Buttons
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    actionButton(
                        label   : "Join code",
                        sub     : "Search event",
                        icon    : "magnifyingglass",
                        gradient: [Color(hex: "0d2a4a"), Color(hex: "0d3d7a")],
                        rotation: -20, scale: 1.1
                    ) { onNavigate(.search) }

                    actionButton(
                        label   : "Private code",
                        sub     : "Unlock event",
                        icon    : "lock.fill",
                        gradient: [Color(hex: "2a0d4a"), Color(hex: "5a0d8a")],
                        rotation: 15, scale: 1.15
                    ) { onNavigate(.search) }

                    actionButton(
                        label   : "My tickets",
                        sub     : "View QR codes",
                        icon    : "ticket.fill",
                        gradient: [Color(hex: "0d3a1a"), Color(hex: "0d6a2a")],
                        rotation: -20, scale: 1.2
                    ) { onNavigate(.tickets) }

                    actionButton(
                        label   : "Browse events",
                        sub     : "See what's on",
                        icon    : "app.translucent",
                        gradient: [Color(hex: "4a1a0d"), Color(hex: "7a3a0d")],
                        rotation: 20, scale: 1.1
                    ) { onNavigate(.home) }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.urbanBackground)
        .onReceive(timer) { _ in
            guard !featuredEvents.isEmpty else { return }
            withAnimation(.easeInOut(duration: 0.35)) { textOpacity = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                currentIndex = (currentIndex + 1) % featuredEvents.count
                withAnimation(.easeInOut(duration: 0.35)) { textOpacity = 1 }
            }
        }
        .task { await fetchFeaturedEvents() }
    }

    // Banner slide
    @ViewBuilder
    private func bannerSlide(event: Event) -> some View {
        ZStack {
            fallbackColor(event.category ?? "").opacity(0.15).ignoresSafeArea()

            if let url = event.coverImageUrl.flatMap({ URL(string: $0) }) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(isAnimating ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
                    .ignoresSafeArea()
                    .clipped()
            } else {
                Image(systemName: categoryIcon(event.category ?? ""))
                    .font(.system(size: 140))
                    .foregroundColor(fallbackColor(event.category ?? "").opacity(0.8))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 4 : -4))
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear { isAnimating = true }
    }

    //  Action button
    @ViewBuilder
    private func actionButton(
        label   : String,
        sub     : String,
        icon    : String,
        gradient: [Color],
        rotation: Double,
        scale   : CGFloat,
        action  : @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                // Icon — rotated, scaled, pushed to bottom right, no background
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(.white.opacity(0.3))
                    .rotationEffect(.degrees(rotation+10))
                    .scaleEffect(scale)
                    .offset(x: 2, y: 3)

                // Text — top left
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.custom("DMSans-SemiBold", size: 12))
                        .foregroundColor(.white)
                    Text(sub)
                        .font(.custom("DMSans-Regular", size: 10))
                        .foregroundColor(.white.opacity(0.45))
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .frame(height: 72)
            .background(
                LinearGradient(
                    colors    : gradient,
                    startPoint: .topLeading,
                    endPoint  : .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    //  Helpers
    private func fallbackColor(_ cat: String) -> Color {
        switch cat.lowercased() {
        case "sports":        return .green
        case "concert":       return .orange
        case "tech":          return .blue
        case "celebration":   return .pink
        case "nightlife":     return .purple
        case "heritage":      return .brown
        case "corporate":     return .yellow
        case "community":     return .teal
        case "public_square": return .red
        default:              return .urbanAccent
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

    private func fetchFeaturedEvents() async {
        if let preview = previewEvents {
            featuredEvents = preview
            return
        }
        do {
            struct FeaturedResponse: Decodable { let events: [Event] }
            let response: FeaturedResponse = try await APIClient.shared.get(
                "/api/events/featured", authenticated: false
            )
            featuredEvents = response.events
        } catch {}
    }
}

#Preview {
    // Mock events for preview
    let mockEvents: [Event] = [
        Event(
            id              : UUID(),
            title           : "Lagos Developer Summit 2026",
            slug            : "lagos-dev-summit-2026",
            description     : "Nigeria's biggest dev conference",
            category        : "tech",
            status          : "published",
            visibility      : "public",
            venueName       : "Co-Creation Hub",
            venueAddress    : nil,
            city            : "Lagos",
            state           : "Lagos",
            latitude        : nil,
            longitude       : nil,
            startTime       : Date().addingTimeInterval(86400 * 8),
            endTime         : Date().addingTimeInterval(86400 * 8 + 3600 * 8),
            coverImageUrl   : nil,
            dressCode       : "Smart casual",
            joinCode        : "ABC123",
            privateJoinCode : "XYZ789",
            giftingEnabled  : false,
            maxCapacity     : nil,
            createdAt       : Date(),
            isPaid     : false,
            creatorName      : "AJEWOLE sam",
            metadata  : nil,
            recurrence: nil,
            recurrenceDays : nil,
            recurrenceInterval  : nil,
            recurrenceEndDate: nil,
            occurrenceNumber            : 0,
            recurrenceParentId          : nil as UUID?
        ),
        Event(
            id              : UUID(),
            title           : "Afrobeats Nite Vol. 12",
            slug            : "afrobeats-nite-12",
            description     : "The biggest music night in Lagos",
            category        : "concert",
            status          : "published",
            visibility      : "public",
            venueName       : "Eko Hotel",
            venueAddress    : nil,
            city            : "Lagos",
            state           : "Lagos",
            latitude        : nil,
            longitude       : nil,
            startTime       : Date().addingTimeInterval(86400 * 6),
            endTime         : Date().addingTimeInterval(86400 * 6 + 3600 * 6),
            coverImageUrl   : nil,
            dressCode       : "All white",
            joinCode        : "DEF456",
            privateJoinCode : "UVW012",
            giftingEnabled  : false,
            maxCapacity     : 500,
            createdAt       : Date(),
            isPaid     : false,
            creatorName      : "JIMI TOLA",
            metadata  : nil,
            recurrence: nil,
            recurrenceDays : nil,
            recurrenceInterval  : 0,
            recurrenceEndDate: nil,
            occurrenceNumber            : 0,
            recurrenceParentId          : nil as UUID?
        )
    ]

    // Inject mock events directly
    LandingViewPreview(events: mockEvents)
}

// Wrapper that bypasses the API call for preview
private struct LandingViewPreview: View {
    let events: [Event]
    @State private var authVM = AuthViewModel()

    var body: some View {
        LandingView(authVM: authVM, previewEvents: events) {_ in }
    }
}
