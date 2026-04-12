//
//  HomeFeedView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
struct HomeFeedView: View {
    @State private var feedVM = FeedViewModel()
    @State private var selectedCategory : String?
    @State private var billboardColorToSetAsGradientForBackGround : Color = .black
    @State private var scrollOffset: CGFloat = 0
    @State private var authVM = AuthViewModel()
    
    @State private var showEventTypePicker = false
    @State private var showOfficialCreate  = false
    @State private var showCelebrationCreate = false
    
    @State private var showEventMenu = false
    
    let categories = [
        ("celebration", "Celebrations", "party.popper.fill"),
        ("nightlife", "Nightlife", "moon.stars.fill"),
        ("tech", "Tech", "laptopcomputer"),
        ("heritage", "Heritage", "building.columns.fill"),
        ("religious", "Religious", "hands.and.sparkles.fill"),
        ("corporate", "Corporate", "briefcase.fill"),
        ("community", "Community", "person.3.fill"),
        ("public_square", "Public", "megaphone.fill"),
        ("concert", "Concerts", "music.mic"),
        ("sports", "Sports", "sportscourt.fill"),
    ]
    
    private let collapseThreshold: CGFloat = 300
    private var isScrolled: Bool { scrollOffset > collapseThreshold }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment : .top) {
                
                LinearGradient(
                    colors: [isScrolled ? Color.black : billboardColorToSetAsGradientForBackGround.opacity(0.85),
                             isScrolled ? Color.black : billboardColorToSetAsGradientForBackGround.opacity(0.4),
                             Color.urbanBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: isScrolled)
                .animation(.easeInOut(duration: 1.2), value: billboardColorToSetAsGradientForBackGround)
                
                ScrollView{
                    VStack(spacing : 0) {
                        
                        // Offset tracker anchor
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: -geo.frame(in: .named("scroll")).minY
                            )
                        }
                        .frame(height: 0)
                        //                        horizontal scrolling row of category buttons.
                        if !isScrolled {
                            ScrollView(.horizontal,showsIndicators: false){
                                HStack(spacing : 8){
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
                            .transition(.move(edge : .top).combined(with: .opacity))
                        }
                        
                        // Billboard at the top
                        BillboardView(events: feedVM.events) {
                            color in
                            withAnimation(.easeInOut(duration: 0.8)) {
                                billboardColorToSetAsGradientForBackGround = color
                            }
                        }
                        
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
                        .padding(.top,16)
                    }
                    
                }
                .coordinateSpace(name : "scroll")
                .onPreferenceChange(ScrollOffsetKey.self){
                    value in
                    withAnimation(.easeInOut(duration: 0.3)){
                        scrollOffset = value
                    }
                }
                .refreshable {
                    await feedVM.fetchFeed()
                }
                .navigationTitle("UrbanSync")
                .navigationDestination(for: UUID.self){ eventId in
                    EventDetailView(eventId: eventId)
                }
                .task {
                    if feedVM.events.isEmpty{
                        await feedVM.fetchFeed()
                    }
                }
                
                //                Sticky top bar - always visible
                VStack(spacing: 0 ){
                    HStack{
                        VStack(alignment: .leading){
                            HStack(spacing : 1) {
                                Image("logo image 3")
                                    .font(.system(size: 20))
                                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 0)
                                Text("UrbanSync")
                                    .font(.jakartaTitle2.weight(.semibold))
                                    .foregroundColor(.white)
                            }
                            Text("Yo \(authVM.userProfile?.name ?? "Boss")")
                                .font(.jakartaTitle2.weight(.semibold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        NavigationLink(destination: SearchView()) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(
                                    isScrolled
                                    ? Color.white.opacity(0.15)
                                    : Color.clear
                                )
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal,16)
                    .padding(.top,8)
                    .padding(.bottom,10)
                    
                    if isScrolled{
                        Divider()
                            .background(Color.white.opacity(0.15))
                            .transition(.opacity)
                    }
                }
                .background(
                    isScrolled
                    ? Color.black.opacity(0.75)
                    : Color.clear
                )
                .background {
                    if isScrolled {
                        Color.black.opacity(0.6)
                            .background(.ultraThinMaterial)
                    }
                }
                .animation(.easeInOut(duration: 0.3),value: isScrolled)
                
//            FAB - bottom right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment : .trailing,spacing : 12){
//                            Menu options, slide up when showEventMenu is true
                            if showEventMenu {
                                VStack(alignment : .trailing, spacing: 10){
                                    eventMenuOption(
                                        title       : "Official Event",
                                        subtitle    : "Tech, Concert, Conference, Nightclub...",
                                        icon        : "building.2.fill"
                                    ){
                                        showEventMenu       = false
                                        showOfficialCreate  = true
                                    }
                                    eventMenuOption(
                                        title       : "Official Event",
                                        subtitle    : "Wedding, Birthday, Owambe...",
                                        icon        : "party.popper.fill"
                                    ){
                                        showEventMenu           = false
                                        showCelebrationCreate   = true
                                    }
                                }
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                            
//                            FAB
                            Button {
                                withAnimation(.spring(duration: 0.35)) {
                                    showEventMenu.toggle()
                                }
                            } label: {
                                Image(systemName: showEventMenu ? "xmark" : "plus")
                                    .font(.system(size : 22,weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 56,height: 56)
                                    .background(Color.urbanAccent)
                                    .clipShape(Circle())
                                    .rotationEffect(.degrees(showEventMenu ? 45 : 0))
                                    .animation(.spring(duration : 0.35), value: showEventMenu)
                            }
                        }
                        .padding(.trailing,20)
                        .padding(.bottom,32)
                    }
                }
            }
            .confirmationDialog("What kind of event?", isPresented: $showEventTypePicker, titleVisibility: .visible) {
                Button("Official Event") { showOfficialCreate = true }
                Button("Celebration")    { showCelebrationCreate = true }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showOfficialCreate) {
                CreateEventView()
            }
            .sheet(isPresented: $showCelebrationCreate) {
                CreateCelebrationView()
            }
            .onTapGesture {
                if showEventMenu {
                    withAnimation(.spring(duration : 0.35)){
                        showEventMenu = false
                    }
                }
            }
        }
    }
    @ViewBuilder
    private func eventMenuOption(
        title           : String,
        subtitle        : String,
        icon            : String,
        action          : @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing : 12){
                VStack(alignment: .trailing) {
                    Text(title)
                        .font(.jakartaSubheadline.weight(.medium))
                        .foregroundColor(.urbanTextPrimary)
                    Text(subtitle)
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                }
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 40,height: 40)
                    .background(Color.urbanAccent.opacity(0.85))
                    .clipShape(Circle())
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
