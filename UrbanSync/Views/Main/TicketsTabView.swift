//
//  TicketsTabView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI
import Kingfisher

struct TicketsTabView: View {
    @State private var tickets : [Ticket] = []
    @State private var isLoading = true
    @State private var selectedTicket : Ticket?
    
    var upcomingTickets: [Ticket] {
        tickets.filter {($0.startTime ?? .distantPast) > Date()}
    }
    var pastTickets : [Ticket] {
        tickets.filter{($0.startTime ?? .distantPast) <= Date()}
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView().tint(.urbanAccent)
                } else if tickets.isEmpty{
//                    Empty State
                    VStack(spacing : 16) {
                        Image("ticket-x")
                            .font(.jakartaLargeTitle)
                            .foregroundColor(.urbanTextTertiary)
                        Text("No tickets yet")
                            .font(.jakartaTitle3)
                            .foregroundColor(.urbanTextPrimary)
                        Text("When you RSVP or buy tickets, they show up here.")
                            .font(.jakartaBody)
                            .foregroundColor(.urbanTextSecondary)
                            .multilineTextAlignment(.center)
                        Button{
                            HomeFeedView()
                        } label : {
                            Text("Check Events out")
                                .font(.jakartaTitle2)
                                .foregroundColor(.urbanTextPrimary)
                                .background(Color.urbanTextSecondary)
                                .padding(16)
                                .clipShape(Capsule())
                        }.padding(.bottom,10)
                        Button {
                            print("This opens a webview to file disputes on tickets")
                        } label : {
                            Text("Dispute Tickets")
                                .font(.jakartaCaption2)
                                .foregroundColor(.white)
                                .underline(true)
                        }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading,spacing : 24) {
//                            Upcoming Tickets
                            if !upcomingTickets.isEmpty {
                                sectionHeader("Upcoming",count : upcomingTickets.count)
                                ForEach(upcomingTickets) { ticket in
                                    ticketCard(ticket)
                                        .onTapGesture{
                                            UIImpactFeedbackGenerator(style : .light).impactOccurred()
                                            selectedTicket = ticket
                                        }
                                }
                            }
                            
//                            Past Tickets
                            if !pastTickets.isEmpty {
                                sectionHeader("Past",count : pastTickets.count)
                                ForEach(pastTickets) { ticket in
                                    ticketCard(ticket)
                                        .opacity(0.5)
                                        .onTapGesture{
                                            UIImpactFeedbackGenerator(style : .light).impactOccurred()
                                            selectedTicket = ticket}
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationTitle(Text("My Tickets").font(.jakartaTitle2).foregroundColor(.white))
            .task { await fetchTickets() }
            .refreshable {await fetchTickets()}
            .sheet(item: $selectedTicket) {
                ticket in
                TicketDetailSheet(ticket : ticket)
                    .presentationDetents([.medium,.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
//    Section Header
    private func sectionHeader(_ title : String,count : Int) -> some View {
        HStack {
            Text(title)
                .font(.jakartaTitle3)
                .foregroundColor(.urbanTextPrimary)
            Text("\(count)")
                .font(.jakartaCaption)
                .foregroundColor(.urbanAccent)
                .padding(.horizontal,8)
                .padding(.vertical,2)
                .background(Color.urbanAccent.opacity(0.15))
                .cornerRadius(10)
        }
    }
    
//    Ticket Card
    private func ticketCard(_ ticket : Ticket) -> some View {
        HStack(spacing : 12) {
            if let url = ticket.coverImageUrl.flatMap({URL(string : $0)}) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.urbanSurfaceLight)
                    .frame(width: 70, height: 70)
                    .overlay(Image(systemName: "ticket.fill").foregroundColor(.urbanTextTertiary))
            }
            VStack(alignment : .leading,spacing : 4){
                Text(ticket.title ?? "Event")
                    .font(.jakartaHeadline)
                    .foregroundColor(.urbanTextPrimary)
                    .lineLimit(1)
                if let time = ticket.startTime {
                    Text(time.shortFormatted)
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                }
                if let tier = ticket.tierName {
                    Text(tier)
                        .font(.jakartaCaption2)
                        .foregroundColor(.urbanAccent)
                }
            }
            Spacer()
                
//            Status badge
            Text(ticket.status.uppercased())
                .font(.jakarta(.bold,size : 10))
                .foregroundColor(statusColor(ticket.status))
                .padding(.horizontal,8)
                .padding(.vertical,4)
                .background(statusColor(ticket.status).opacity(0.15))
                .cornerRadius(6)
        }
        .padding(12)
        .background(Color.urbanSurface)
        .cornerRadius(14)
    }
    
    private func statusColor(_ status : String) -> Color {
        switch status {
        case "confirmed" : return .urbanMint
        case "pending"   : return .urbanGold
        case "checked_in": return .urbanAccent
        case "cancelled" : return .urbanCoral
        default          : return .urbanTextSecondary
        }
    }
    private func fetchTickets() async {
        do {
            let response : PaginatedResponse<Ticket> = try await APIClient.shared.get("api/tickets/my")
            tickets     = response.tickets ?? []
            isLoading   = false
        } catch {isLoading = false}
    }
}

//#Preview {
//    TicketsTabView()
//}
