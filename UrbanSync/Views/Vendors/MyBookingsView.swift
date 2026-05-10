//
//  MyBookingsView.swift
//  UrbanSync
//

import SwiftUI
import Kingfisher

struct MyBookingsView: View {
    @State private var selectedTab = 0  // 0 = Sent, 1 = Received
    @State private var sentBookings: [VendorBooking] = []
    @State private var receivedBookings: [VendorBooking] = []
    @State private var isLoading = true
    @State private var hasVendorProfile = false
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tabs
                HStack(spacing: 0) {
                    tabButton(title: "Sent", count: sentBookings.count, index: 0)
                    if hasVendorProfile {
                        tabButton(title: "Received", count: receivedBookings.count, index: 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                if isLoading {
                    Spacer()
                    ProgressView().tint(.urbanAccent)
                    Spacer()
                } else {
                    let bookings = selectedTab == 0 ? sentBookings : receivedBookings
                    
                    if bookings.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: selectedTab == 0 ? "paperplane" : "tray")
                                .font(.system(size: 48))
                                .foregroundColor(.urbanTextTertiary)
                            Text(selectedTab == 0 ? "No bookings sent" : "No bookings received")
                                .font(.jakartaSubheadline)
                                .foregroundColor(.urbanTextPrimary)
                            Text(selectedTab == 0 ? "Browse vendors to make a booking" : "Bookings will appear here when clients request you")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(32)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(bookings) { booking in
                                    NavigationLink(destination: BookingDetailView(
                                        bookingId: booking.id,
                                        isVendorView: selectedTab == 1
                                    )) {
                                        bookingCard(booking, isVendorView: selectedTab == 1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                        }
                        .refreshable { await fetchAll() }
                    }
                }
            }
        }
        .navigationTitle("My Bookings")
        .navigationBarTitleDisplayMode(.inline)
        .task { await fetchAll() }
    }
    
    @ViewBuilder
    private func bookingCard(_ booking: VendorBooking, isVendorView: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if isVendorView {
                    // Show client
                    HStack(spacing: 8) {
                        if let urlStr = booking.clientAvatar, let url = URL(string: urlStr) {
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.urbanSurfaceLight)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text((booking.clientName ?? "U").prefix(1).uppercased())
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.urbanAccent)
                                )
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(booking.clientName ?? "Client")
                                .font(.jakarta(.semiBold, size: 13))
                                .foregroundColor(.urbanTextPrimary)
                            Text("requesting your service")
                                .font(.jakartaCaption2)
                                .foregroundColor(.urbanTextTertiary)
                        }
                    }
                } else {
                    // Show vendor
                    HStack(spacing: 8) {
                        if let urlStr = booking.vendorCover, let url = URL(string: urlStr) {
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else if let cat = booking.vendorCategory {
                            let info = VendorCategoryInfo.info(for: cat)
                            ZStack {
                                Color(hex: info.color).opacity(0.3)
                                Image(systemName: info.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: info.color))
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Text(booking.vendorName ?? "Vendor")
                                .font(.jakarta(.semiBold, size: 13))
                                .foregroundColor(.urbanTextPrimary)
                            if let cat = booking.vendorCategory {
                                Text(VendorCategoryInfo.info(for: cat).label)
                                    .font(.jakartaCaption2)
                                    .foregroundColor(.urbanTextTertiary)
                            }
                        }
                    }
                }
                Spacer()
                statusPill(booking.status)
            }
            
            Divider().background(Color.urbanSurfaceLight)
            
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text(booking.eventDate.formatted(.dateTime.day().month(.abbreviated).year()))
                        .font(.jakartaCaption2)
                }
                .foregroundColor(.urbanTextSecondary)
                
                if let location = booking.eventLocation, !location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(location)
                            .font(.jakartaCaption2)
                            .lineLimit(1)
                    }
                    .foregroundColor(.urbanTextSecondary)
                }
            }
            
            Text(booking.scope)
                .font(.jakartaCaption)
                .foregroundColor(.urbanTextSecondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(Color.urbanSurface)
        .cornerRadius(12)
    }
    
    private func statusPill(_ status: String) -> some View {
        let (color, label): (Color, String) = {
            switch status {
            case "pending": return (.urbanGold, "Pending")
            case "accepted": return (.urbanMint, "Accepted")
            case "declined": return (.urbanCoral, "Declined")
            case "completed": return (.urbanAccent, "Completed")
            case "cancelled": return (.urbanTextTertiary, "Cancelled")
            default: return (.urbanTextTertiary, status.capitalized)
            }
        }()
        
        return Text(label)
            .font(.system(size: 9, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(Capsule())
    }
    
    private func tabButton(title: String, count: Int, index: Int) -> some View {
        Button {
            withAnimation { selectedTab = index }
        } label: {
            VStack(spacing: 6) {
                HStack(spacing: 5) {
                    Text(title)
                        .font(.jakarta(.medium, size: 14))
                    if count > 0 {
                        Text("\(count)")
                            .font(.jakartaCaption2)
                            .foregroundColor(.urbanAccent)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Color.urbanAccent.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .foregroundColor(selectedTab == index ? .urbanTextPrimary : .urbanTextTertiary)
                Rectangle()
                    .fill(selectedTab == index ? Color.urbanAccent : .clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func fetchAll() async {
        isLoading = true
        defer { isLoading = false }
        
        struct R: Decodable { let bookings: [VendorBooking] }
        
        // Sent
        do {
            let r: R = try await APIClient.shared.get("/api/bookings/sent")
            sentBookings = r.bookings
        } catch {
            print("❌ sent: \(error)")
        }
        
        // Received (only if user has vendor profile)
        do {
            let r: R = try await APIClient.shared.get("/api/bookings/received")
            receivedBookings = r.bookings
            hasVendorProfile = true
        } catch {
            hasVendorProfile = false
        }
    }
}