//
//  WelcomeOnboardingView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 08/04/2026.
//

import SwiftUI

struct WelcomeOnboardingView: View {
    @Binding var hasSeenWelcome     : Bool
    @Binding var isGuest            : Bool
    @State private var currentPage  : Int = 0
    
    let pages : [(icon : String,title : String,desc : String)] = [
        (
            "sparkles",
            "Discover Events",
            "Find owambe, tech meetups, concerts, Religious Events and cultural festivals happening near you. Personalized to you interests"
        ),
        (
            "paperplane.fill",
            "Create Events",
            "Launch your events with just a few clicks. Share the link with friends and family. They can send gifts, RSVP and get notified."
        ),
        (
            "ticket.fill",
            "Get Tickets Instantly",
            "Buy tickets. Free events? just RSVP. Your QR code ticket is always in the app."
        ),
        (
            "map.fill",
            "Events on a Map",
            "See what's happening near you on a map. Filter by date, category and more. Tap a pin, see the events,get directions."
        ),
        (
            "person.3.fill",
            "Built for Nigerians",
            "From Sallah and Christmas celebrations to Lagos nightlife, UrbanSync understands Nigerian events like no other app."
        )
    ]
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            VStack(spacing : 0) {
                //                Skip Button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            withAnimation{
                                currentPage = pages.count - 1
                            }
                        }
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextSecondary)
                        .padding(.trailing,24)
                    }
                }
                .frame(height : 44)
                TabView(selection : $currentPage) {
                    ForEach(Array(pages.enumerated()),id: \.offset) { index, page in
                        VStack(spacing : 32) {
                            Spacer()
                            
//                            Symbol with sf symbol
                            Image(systemName: page.icon)
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.urbanAccent,.urbanCoral],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.bottom,16)
                            
//                            Title
                            Text(page.title)
                                .font(.jakartaTitle)
                                .foregroundColor(.urbanTextPrimary)
                                .multilineTextAlignment(.center)
                            
//                            Description
                            Text(page.desc)
                                .font(.jakartaBody)
                                .foregroundColor(.urbanTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal,40)
                            Spacer()
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
//                Page Indicators Dots
                HStack(spacing :8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.urbanAccent : Color.urbanSurfaceLight)
                            .frame(width: index == currentPage ? 24 : 8, height : 8)
                            .animation(.spring(duration : 0.3),value : currentPage)
                    }
                }
                .padding(.bottom,32)
//                Buttons(last page only shows both,others show Next)
                if currentPage == pages.count - 1 {
//                    Last page: Get Started + Browse as Guest.
                    VStack(spacing : 12) {
                        Button {
//                            Haptic Feedback
                            UIImpactFeedbackGenerator(style : .medium).impactOccurred()
                            hasSeenWelcome = true
                        } label : {
                            Text("Get Started")
//                                .font(.custom("Chillax-Variable",size : 17))
                                .font(.jakarta(.semibold,size: 17))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.urbanAccent)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        Button {
//                            Guest mode: skip auth, go straight to feed.
                            isGuest = true
                            hasSeenWelcome = true
                        } label: {
                            Text("Check Events")
//                                .font(.custom("Chillax-Variable",size : 17))
                                .font(.jakarta(.medium,size : 15))
                                .foregroundColor(.urbanTextSecondary)
                        }
                    }
                    .padding(.horizontal,24)
                    .padding(.bottom,40)
                } else {
                    Button {
                        withAnimation{currentPage += 1}
                    } label : {
                        Text("Next")
                            .font(.jakarta(.semibold,size : 17))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.urbanAccent)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal,24)
                    .padding(.bottom,40)
                }
            }
        }
    }
}

#Preview {
    WelcomeOnboardingView(
        hasSeenWelcome: .constant(false),
        isGuest: .constant(true)
    )
}
