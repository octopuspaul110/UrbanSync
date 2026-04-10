//
//  BillBoardView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI
import Combine

struct BillboardImage: View {
    let url: String?
    let category: String

    var body: some View {
        if let urlString = url, let imageUrl = URL(string: urlString) {
            AsyncImage(url: imageUrl) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure, .empty:
                    fallbackView
                @unknown default:
                    fallbackView
                }
            }
        } else {
            fallbackView
        }
    }

    private var fallbackView: some View {
        ZStack {
            fallbackColor.opacity(0.25)
            VStack(spacing: 8) {
                Image(systemName: fallbackIcon)
                    .font(.system(size: 52))
                    .foregroundColor(fallbackColor)
            }
        }
    }

    private var fallbackIcon: String {
        switch category.lowercased() {
        case "celebration":         return "party.popper.fill"
        case "nightlife":           return "moon.stars.fill"
        case "tech":                return "laptopcomputer"
        case "heritage":            return "building.columns.fill"
        case "religious":           return "hands.and.sparkles.fill"
        case "corporate":           return "briefcase.fill"
        case "community":           return "person.3.fill"
        case "public_square":       return "megaphone.fill"
        case "concert":             return "music.mic"
        case "sports":              return "sportscourt.fill"
        default:                    return "calendar"
        }
    }

    private var fallbackColor: Color {
        switch category.lowercased() {
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
}

struct BillboardView: View {
    let events: [Event]
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()


    @State private var featuredEvents: [Event] = []

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(featuredEvents.enumerated()), id: \.offset) { index, event in
                BillboardCard(event: event){
                    withAnimation {
                        featuredEvents.removeAll { $0.id == event.id }
                            if currentIndex >= featuredEvents.count {
                                currentIndex = max(0, featuredEvents.count - 1)
                        }
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 420)
        .overlay(alignment: .bottomTrailing) {
            // Dot indicators
            HStack(spacing: 5) {
                ForEach(0..<featuredEvents.count, id: \.self) { i in
                    Capsule()
                        .fill(i == currentIndex ? Color.white : Color.white.opacity(0.35))
                        .frame(width: i == currentIndex ? 18 : 6, height: 6)
                        .animation(.spring(duration: 0.3), value: currentIndex)
                }
            }
            .padding([.bottom, .trailing], 14)
        }
        .onReceive(timer) { _ in
            guard featuredEvents.count > 1 else { return }
            withAnimation {
                currentIndex = (currentIndex + 1) % featuredEvents.count
            }
        }
        .onAppear{
            featuredEvents = Array(events.shuffled().prefix(5))
        }
    }
}

struct BillboardCard: View {
    let event: Event
    var onSave: () -> Void
    @State private var saved = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Cover image
            BillboardImage(url: event.coverImageUrl, category: event.category ?? "")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Saved confirmation overlay
            if saved {
                ZStack {
                    Color.black.opacity(0.6)
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("Event saved, please check it out later.")
                            .font(.jakartaHeadline.weight(.medium))
                            .foregroundColor(.white)
                    }
                }
                .transition(.opacity)
            }

            // Content
            if !saved {
                VStack(alignment: .leading, spacing: 6) {
                    
                    HStack(spacing : 6){
                        if event.isLive {
                            Text("Live")
                                .font(.jakartaCaption.weight(.thin))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.urbanCoral)
                                .clipShape(Capsule())

                        }
                        else if event.isUpcoming {
                            Text("Upcoming")
                                .font(.jakartaCaption.weight(.thin))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.urbanGold)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.trailing,10)
                    Spacer()
                    
                    // Category badge + free ticket badge
                    HStack(spacing: 6) {
                        Text(event.category?.capitalized ?? "")
                            .font(.jakartaCaption.weight(.medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.urbanAccent)
                            .clipShape(Capsule())
                        
                        Text(event.isFree ? "Ticketed" : "Free RSVP")
                            .font(.jakartaCaption.weight(.medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.urbanAccent)
                            .clipShape(Capsule())
                        
                    }
                    
                    Text(event.title ?? "")
                        .font(.jakartaTitle2.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    if let venue = event.venueName, let city = event.city {
                        HStack (spacing: 6){
                            Text("\(event.startTime)")
                                .font(.jakartaSubheadline)
                                .foregroundColor(.white.opacity(0.65))
                            
                            Text("\(venue), \(city)")
                                .font(.jakartaSubheadline)
                                .foregroundColor(.white.opacity(0.65))
                        }
                    }
                    
                    // Buttons
                    HStack(spacing: 10) {
                        NavigationLink(value: event.id) {
                            Label("Check it", systemImage: "camera.filters")
                                .font(.jakartaSubheadline.weight(.medium))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 9)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        
                        Button {
                            // save action
                            // call save from api
                            withAnimation(.easeInOut(duration: 0.3)){
                                saved = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { onSave()}
                        } label: {
                            Label("Save", systemImage: "plus")
                                .font(.jakartaSubheadline.weight(.medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 9)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1.5))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .transition(.opacity)
            }
        }
        .clipped()
    }
}
