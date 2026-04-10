//
//  HomeFeedView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI

struct HomeFeedView: View {
    @State private var feedVM = FeedViewModel()
    @State private var selectedCategory : String?
    
    let categories = [
        ("celebration", "Celebrations", "party.popper.fill"),
        ("nightlife", "Nightlife", "moon.stars.fill"),
        ("tech", "Tech", "laptopcomputer"),
        ("heritage", "Heritage", "building.columns.fill"),
        ("concert", "Concerts", "music.mic"),
        ("sports", "Sports", "sportscourt.fill")
    ]
    var body: some View {
        NavigationStack{
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing : 0) {
                        // Billboard at the top
                        BillboardView(events: feedVM.events)
                        
//                        horizontal scrolling row of category buttons.
                        ScrollView(.horizontal,showsIndicators: false){
                            HStack(spacing : 12){
                                chipButton(
                                    "All",
                                    icon : "sparkles",
                                    isSelected : selectedCategory == nil){
                                    selectedCategory = nil
                                }
                                ForEach(categories, id :\.0) {cat in
                                    chipButton(
                                        cat.1,
                                        icon : cat.2,
                                        isSelected : selectedCategory == cat.0){
                                        selectedCategory = nil
                                    }
                                }
                            }
                            .padding(.horizontal,16)
                        }
                        .padding(.vertical,12)
                        
//                        Event Cards
                        LazyVStack(spacing : 16){
                            ForEach(filteredEvents) {event in
                                NavigationLink(value: event.id){
                                    EventCardView(event:event)
                                }
                                .buttonStyle(.plain)
                            }
//                            Infinite scroll trigger
                            if feedVM.hasMore {
                                ProgressView()
                                    .tint(.urbanAccent)
                                    .padding()
                                    .onAppear{
                                        Task {
                                            await feedVM.fetchFeed()
                                        }
                                    }
                            }
                            
                        }
                        .padding(.horizontal,16)
                    }
                    
                }
                .refreshable {
                    await feedVM.fetchFeed()
                }
            }
            .navigationTitle("UrbanSync")
            .navigationDestination(for: UUID.self){ eventId in
                EventDetailView(eventID: eventId)
            }
            .task {
                if feedVM.events.isEmpty{
                    await feedVM.fetchFeed()
                }
            }
        }
    }
//    filter events by selected category
    private var filteredEvents : [Event]{
        guard let cat = selectedCategory else {return feedVM.events}
        return feedVM.events.filter{$0.category == cat}
    }
    
    @ViewBuilder
    private func chipButton(
        _ title: String,
        icon : String,
        isSelected : Bool,
        action : @escaping () -> Void) -> some View {
            Button(action: action){
                HStack(spacing : 6){
                    Image(systemName : icon)
                        .font(.caption)
                    Text(title)
                        .font(.jakartaSubheadline.weight(.medium))
                }
                .padding(.horizontal,14)
                .padding(.vertical,8)
                .background(isSelected ? Color.urbanAccent : Color.urbanSurface)
                .foregroundColor(isSelected ? .white : .urbanTextSecondary)
                .cornerRadius(20)
            }
        }
}

//#Preview {
//    HomeFeedView()
//}
