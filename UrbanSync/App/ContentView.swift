//
//  ContentView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 08/04/2026.
//
import SwiftUI
import FirebaseAuth
struct ContentView: View {
    @State private var authVM         = AuthViewModel()
    @State private var splashDone     : Bool = false
    @State private var selectedTab    : Int  = 0
    @State private var showLanding    : Bool = true
    @State private var showSearchSheet: Bool = false

    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var isGuest        = false
    @State private var showLogin      = false
    @State private var showSignUp     = false

    var body: some View {
        ZStack {
            if !splashDone {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation(.easeIn(duration: 0.4)) {
                                splashDone = true
                            }
                        }
                    }

            } else if !hasSeenWelcome {
                WelcomeOnboardingView2(
                    hasSeenWelcome : $hasSeenWelcome,
                    isGuest        : $isGuest,
                    onLogin        : { showLogin  = true },
                    onSignUp       : { showSignUp = true }
                )
                .sheet(isPresented: $showLogin) {
                    LoginView(authVM: authVM)
                }
                .sheet(isPresented: $showSignUp) {
                    RegisterView(authVM: authVM)
                }

            } else if authVM.isLoading {
                ProgressView()
                    .tint(.urbanAccent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.urbanBackground)

            } else if authVM.currentUser == nil {
                LoginView(authVM: authVM)

            } else if !authVM.onboardingCompleted {
                OnboardingContainerView(authVM: authVM)

            } else if showLanding {
                LandingView(authVM: authVM) { tab in
                    switch tab {
                    case .home:
                        selectedTab = 0
                        withAnimation { showLanding = false }
                    case .tickets:
                        selectedTab = 3
                        withAnimation { showLanding = false }
                    case .search:
                        withAnimation { showLanding = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showSearchSheet = true
                        }
                    }
                }
                .transition(.opacity)

            } else {
                MainTabView(authVM: authVM, selectedTab: $selectedTab)
                    .sheet(isPresented: $showSearchSheet) {
                        SearchView()
                    }
            }
        }
        .preferredColorScheme(.dark)
    }
}
