//
//  EventDetailView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI
import Kingfisher

struct EventDetailView: View {
    let eventId : UUID
    @State private var event : Event?
    @State private var tiers : [TicketTier] = []
    @State private var rsvpCount : Int = 0
    @State private var isLoading : Bool = true
    @State private var showTicketPurchase : Bool = false
    
    private func fallbackColor(_ cat : String) -> Color {
        switch cat.lowercased() {
        case "sports":          return .green
        case "concert":         return .orange
        case "tech":            return .blue
        case "celebration":     return .pink
        case "nightlife":       return .purple
        case "heritage":        return .brown
        case "conference":      return .teal
        case "corporate":       return .yellow
        case "art":             return .indigo
        case "public_square":   return .cyan
        default:                return Color.urbanAccent
        }
    }
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView().tint(.urbanAccent)
            } else if let event = event {
                ScrollView {
                    VStack(alignment : .leading,spacing : 0) {
//                        Cover Image with Gradient overlay
                        ZStack(alignment: .bottomLeading){
                            if let url = event.coverImageUrl.flatMap({URL(string : $0)}) {
                                KFImage(url)
                                    .resizable()
                                    .aspectRatio(16/9,contentMode: .fill)
                                    .frame(height: 250)
                                    .clipped()
                            } else {
                                Rectangle()
                                    .fill(Color.categoryColor(for : event.category ?? ""))
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
                                if event.visibility == "private" {
                                    EventBadge(
                                        text: "PRIVATE",
                                        color: .urbanAccent,
                                        icon: "lock.fill"
                                    )
                                } else {
                                    EventBadge(
                                        text: "PUBLIC",
                                        color: .urbanMint,
                                        icon: "globe"
                                    )
                                }
                                if let cheapest = tiers.min(by: {$0.priceKobo < $1.priceKobo}){
                                    EventBadge(
                                        text: cheapest.priceKobo == 0 ? "FREE" : cheapest.formattedPrice,
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
                                    color: Color.categoryColor(for: event.category ?? "")
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
                            
//                            Date and Time
                            HStack(spacing : 12) {
                                detailRow(icon : "calendar",text : event.startTime.fullFormatted)
                            }
                            
//                            Venue
                            if let venue = event.venueName {
                                detailRow(icon : "mappin.and.ellipse",text : "\(venue)\(event.city.map{",\($0)"} ?? "")")
                            }
                            
//                            RSVP Count
                            detailRow(icon : "person.2.fill",text : "\(rsvpCount) attending")
                            
//                            Description
                            if let desc = event.description {
                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.urbanTextSecondary)
                                    .padding(.top,8)
                            }
                            
//                            Ticket Tiers
                            if !tiers.isEmpty {
                                VStack(alignment: .leading,spacing: 12) {
                                    Text("Tickets")
                                        .font(.headline)
                                        .foregroundColor(.urbanTextPrimary)
                                    ForEach(tiers) { tier in
                                        tierCard(tier)
                                    }
                                }
                                .padding(.top,8)
                            }
                        }
                        .padding(16)
                    }
                }
//                Bottom Action Bar
                VStack {
                    Spacer()
                    HStack(spacing : 12) {
//                        share button
                        ShareLink(item: URL(string:"https://urbansync.app/e/\(event.slug)")!){
                            Image(systemName: "square.and.arrow.up")
                                .frame(width: 50,height: 50)
                                .background(Color.urbanSurface)
                                .cornerRadius(12)
                                .foregroundColor(.urbanTextPrimary)
                        }
                        
//                        Get Tickets button
                        Button{
                            showTicketPurchase = true
                        } label : {
                            Text(tiers.allSatisfy({$0.priceKobo == 0}) ? "RSVP FREE" : "GET Tickets")
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
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchEventDetail()
        }
        .sheet(isPresented: $showTicketPurchase) {
            if let event = event {
                TicketPurchaseView(event : event,tiers : tiers)
            }
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
