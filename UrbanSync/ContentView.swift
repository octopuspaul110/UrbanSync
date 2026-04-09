//
//  ContentView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 08/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var authVM             = AuthViewModel()
    @State private var splashDone : Bool  = false
    
//    user @AppStorage to save/load UserDefaults
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome : Bool = false
    
//    Guest mode, user tapped "Browse as Guest" on welcome screen
    @State private var isGuest : Bool = false
    
    var body: some View {
        Group {
            if !hasSeenWelcome {
//                First launch ever - show welcome onboarding
                WelcomeOnBoardingView(hasSeenWelcome : $hasSeenWelcome,isGuest : $isGuest)
            } else if !splashDone {
//                show animated splash screen
                SplashView()
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation{splashDone = true}
                        }
                    }
            } else if isGuest {
//                Guest mode - show feed and search only. does not show Tickets and Profile tabs. shows "Sign In" banner so users can register.
                GuestTabView(onSignIn : {
                    isGuest = false // Switch to auth flow
                })
            } else if authVM.currentUser == nil {
//                Not logged in - show login screen.
                LoginView(authVM : authVM)
            } else if !authVM.onboardingCompleted {
//                Logged in but hasn't completed interest selection.
                OnboardingContainerView(authVM : authVM)
            } else {
//                Fully authenticated and onboarded - show main app.
                MainTabView(authVm : authVM)
            }
        }
        .preferredColorScheme(.dark)
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
