//
//  ProfileView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//
import SwiftUI
import Kingfisher
 
struct ProfileView: View {
    var authVM: AuthViewModel
    @State private var myTickets: [Ticket] = []
    @State private var showDeleteAlert = false
 
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
 
                ScrollView {
                    VStack(spacing: 24) {
                        //  Profile Header
                        VStack(spacing: 12) {
                            // Profile image or placeholder.
                            if let urlStr = authVM.userProfile?.profileImageUrl,
                               let url = URL(string: urlStr) {
                                KFImage(url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.urbanTextTertiary)
                            }
 
                            Text(authVM.userProfile?.name ?? "User")
                                .font(.title2.weight(.bold))
                                .foregroundColor(.urbanTextPrimary)
 
                            if let city = authVM.userProfile?.city {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin")
                                    Text(city)
                                }
                                .font(.subheadline)
                                .foregroundColor(.urbanTextSecondary)
                            }
 
                            if let bio = authVM.userProfile?.bio {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.urbanTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 20)
 
                        //  My Tickets Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Tickets")
                                .font(.headline)
                                .foregroundColor(.urbanTextPrimary)
 
                            if myTickets.isEmpty {
                                Text("No tickets yet. Browse events to get started!")
                                    .foregroundColor(.urbanTextTertiary)
                                    .padding()
                            } else {
                                ForEach(myTickets) { ticket in
                                    ticketRow(ticket)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
 
                        //  Settings
                        VStack(spacing: 0) {
                            settingsRow(icon: "bell.fill", title: "Notifications")
                            settingsRow(icon: "lock.fill", title: "Privacy Policy")
                            settingsRow(icon: "doc.text.fill", title: "Terms of Service")
 
                            //  Delete Account
                            Button {
                                showDeleteAlert = true
                            } label: {
                                settingsRow(icon: "trash.fill", title: "Delete Account", destructive: true)
                            }
 
                            //  Logout 
                            Button {
                                authVM.logout()
                            } label: {
                                settingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", destructive: true)
                            }
                        }
                        .background(Color.urbanSurface)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    }
                }
            }
            .navigationTitle("Profile")
            .task {
                await fetchTickets()
            }
            .alert("Delete Account?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        try? await APIClient.shared.delete("/api/auth/account")
                        authVM.logout()
                    }
                }
            } message: {
                Text("This permanently deletes your account and all data. This cannot be undone.")
            }
        }
    }
 
    private func ticketRow(_ ticket: Ticket) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.title ?? "Event")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.urbanTextPrimary)
                if let time = ticket.startTime {
                    Text(time.shortFormatted)
                        .font(.caption)
                        .foregroundColor(.urbanTextSecondary)
                }
            }
            Spacer()
            Text(ticket.status.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundColor(ticket.status == "confirmed" ? .urbanMint : .urbanGold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((ticket.status == "confirmed" ? Color.urbanMint : Color.urbanGold).opacity(0.15))
                .cornerRadius(6)
        }
        .padding(12)
        .background(Color.urbanSurface)
        .cornerRadius(12)
    }
 
    private func settingsRow(icon: String, title: String, destructive: Bool = false) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(destructive ? .urbanCoral : .urbanTextSecondary)
                .frame(width: 24)
            Text(title)
                .foregroundColor(destructive ? .urbanCoral : .urbanTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.urbanTextTertiary)
        }
        .padding(16)
    }
 
    private func fetchTickets() async {
        do {
            let response: PaginatedResponse<Ticket> = try await APIClient.shared.get("/api/tickets/my")
            myTickets = response.tickets ?? []
        } catch { }
    }
}
