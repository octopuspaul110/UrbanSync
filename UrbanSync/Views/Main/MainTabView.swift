//
//  MainTabView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI

struct MainTabView: View {
    var authVM: AuthViewModel
    @State private var selectedTab: Int = 0
    @State private var showCreateEvent = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab){
                Tab("Home",systemImage: "house.fill",value: 0) {
                    HomeFeedView()
                }
                Tab("Snippet",systemImage: "play.square.stack",value: 1) {
//                    SnippetsView()
                    Text("Snippets to be implemented")
                }
                Tab("Map", systemImage: "map.fill", value: 3) {
                    MapView()
                }
                Tab("Tickets", systemImage: "ticket.fill", value: 2) {
                   TicketsTabView()
                }
                Tab("Profile", systemImage: "person.fill", value: 4) {
                    ProfileView(authVM: authVM)
                }
            }
            .tint(.urbanAccent)
            .onChange(of: selectedTab) {_,_ in
                UIImpactFeedbackGenerator(style : .light).impactOccurred()
            }
//            Floating create Button
            FloatingCreateButton(showCreateEvent : $showCreateEvent)
        }
        .fullScreenCover(isPresented: $showCreateEvent) {
            CreateEventView()
        }
    }
}



//#Preview {
//    MainTabView()
//}
