//
//  welcomeOnboarding2.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 13/04/2026.
//

import SwiftUI

struct WelcomeOnboardingView2: View {
    @Binding var hasSeenWelcome     : Bool
    @Binding var isGuest            : Bool
    @State private var currentPage  : Int = 0
    
    var onLogin                    : () -> Void
    var onSignUp                   : () -> Void
    
    let pages : [(icon : String,title : String,desc : String)] = [
        (
            "sparkles",
            "Discover Events",
            "Find owambe, tech meetups, concerts, religious Events and cultural festivals happening near you. Personalized to you interests"
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
            "mappin.and.ellipse",
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
            ZStack(alignment: .bottom) {
                // Background
//                Image("logo-onboarding")
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()

                Color.black.opacity(0.9).ignoresSafeArea()

                VStack(spacing: 0) {
//                     Skip button
                    HStack {
                        Image("Group 8")
                            .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 100)
                                .clipped()
                    }.offset(x: -90, y: -30)


                    // Pages
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            VStack(spacing: 24) {
                                Spacer()

                                Image(systemName: page.icon)
                                    .font(.system(size: 100))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors    : [
                                                .blue, .red,.urbanCoral.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint  : .bottomTrailing
                                        )
                                    )

                                Text(page.title)
                                    .font(.jakartaTitle)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)

                                Text(page.desc)
                                    .font(.jakartaBody)
                                    .foregroundColor(.white.opacity(0.9))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 36)

                                Spacer()
                                Spacer()
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut, value: currentPage)
                    

                    // Dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? .urbanAccent : Color.white.opacity(0.5))
                                .frame(width: i == currentPage ? 20 : 8, height: 8)
                                .animation(.spring(duration: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 24)

                    // Bottom action box
                    VStack(spacing: 12) {                            // Last page — show login, signup, guest
                            Button {
                                hasSeenWelcome = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                onSignUp()
                            } label: {
                                Text("Create an account")
                                    .font(.jakarta(.semibold, size: 17))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.urbanAccent)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }

                            Button {
                                hasSeenWelcome = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                onLogin()
                            } label: {
                                Text("Log in")
                                    .font(.jakarta(.semibold, size: 17))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white.opacity(0.12))
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                    )
                            }

                            Button {
                                isGuest        = true
                                hasSeenWelcome = true
                            } label: {
                                Text("Browse as guest")
                                    .font(.jakarta(.medium, size: 14))
                                    .foregroundColor(.white.opacity(0.45))
                            }
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(
                        // Transparent frosted box
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.ultraThinMaterial)
                            .opacity(0.85)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                }
            }
        }
}

#Preview {
    WelcomeOnboardingView2(
        hasSeenWelcome: .constant(false),
        isGuest: .constant(true),
        onLogin: {},
        onSignUp: {}
    )
}

