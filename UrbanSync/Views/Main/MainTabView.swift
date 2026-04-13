//
//  MainTabView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI
struct MainTabView: View {
    var authVM      : AuthViewModel
    @Binding var selectedTab: Int
    @State private var showCreateEvent = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Home",    systemImage: "house.fill",          value: 0) { HomeFeedView() }
                Tab("Snippet", systemImage: "play.square.stack",   value: 1) { Text("Snippets coming soon") }
                Tab("Map",     systemImage: "map.fill",            value: 2) { MapView() }
                Tab("Tickets", systemImage: "ticket.fill",         value: 3) { TicketsTabView() }
                Tab("Profile", systemImage: "person.fill",         value: 4) { ProfileView(authVM: authVM) }
            }
            .tint(.urbanAccent)
            .onChange(of: selectedTab) { _, _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .fullScreenCover(isPresented: $showCreateEvent) {
            CreateEventView()
        }
    }
}



//#Preview {
//    MainTabView()
//}
