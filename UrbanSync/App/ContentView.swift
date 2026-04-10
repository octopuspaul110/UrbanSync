//
//  ContentView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 08/04/2026.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var authVM             = AuthViewModel()
    @State private var splashDone : Bool  = false
    
//    user @AppStorage to save/load UserDefaults
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome : Bool = false
    
//    Guest mode, user tapped "Browse as Guest" on welcome screen
    @State private var isGuest : Bool = false
    
    var body: some View {
        Group {
            if !splashDone {
                SplashView()
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline : .now() + 2.5) {
                            withAnimation{
                                splashDone.toggle()
                            }
                        }
                    }
            } else if authVM.isLoading {
//                checking auth state with Firebase
                ProgressView()
                    .tint(.urbanAccent)
                    .frame(maxWidth : .infinity, maxHeight : .infinity)
                    .background(Color.urbanBackground)
            } else if authVM.currentUser == nil {
//                Not logged in - show login screen
                LoginView(authVM : authVM)
            } else if !(authVM.onboardingCompleted) {
//                Logged in but hasn't completed onboarding.
                OnboardingContainerView(authVM : authVM)
            } else {
//                Logged in and onboarded - show main app.
                MainTabView(authVM : authVM)
            }
        }
        .preferredColorScheme(.dark)
    }
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
