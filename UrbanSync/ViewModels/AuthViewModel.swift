//
//  AuthViewModel.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

@Observable
class AuthViewModel{
//    current firebase user. nil = not logged in
    var currentUser : FirebaseAuth.User?
    
//    backend's user profile data.
    var userProfile : User?
    
//    Whether onboarding is complete (determines which screen to show)
    var onboardingCompleted = false
    
//    Loading state for showing spinners on buttons.
    var isLoading = false
    
//    Error message to display in an alert.
    var errorMessage : String?
    
    init() {
//        Check if user is already logged in from a previous session.
//        Firebase persists the session on device, user only logs in once
        self.currentUser = Auth.auth().currentUser
        if currentUser != nil {
            Task {
                await fetchProfile()
            }
        }
    }
    
//    Email/password registration
    func register(
        name        : String,
        email       : String,
        password    : String
    ) async {
        isLoading       = true
        errorMessage    = nil
        defer{isLoading.toggle()}
        do {
//            create firebase account
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )
            self.currentUser = result.user
            
//            Send email verification.
            try await result.user.sendEmailVerification()
            
//            Register with backend
            let body : [String: String] = [
                "name"          : name,
                "email"         : email,
                "firebase_uid"  : result.user.uid
            ]
            let response : AuthResponse = try await APIClient.shared.post(
                "/api/auth/register",
                body: body
            )
            self.onboardingCompleted = response.onboardingCompleted ?? false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
//    login viewModel
    func login(
        email           : String,
        password        : String
    )async {
        isLoading = true
        errorMessage = nil
        defer {isLoading.toggle()}
        do {
//            sign in with firebase
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            self.currentUser = result.user
            
//            call backend login endpoint
            let response : AuthResponse = try await APIClient.shared.post(
                "/api/auth/login",
                body: [:] as [String : String])
            self.onboardingCompleted = response.onboardingCompleted ?? false
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
    }
    
//    Google Sign-In
    func signInWithGoogle() async {
        isLoading       = true
        errorMessage    = nil
        defer {isLoading.toggle()}
        do {
//            Get root view controller for google sign in UI
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                errorMessage = "Cannot find root view controller"
                return
            }
            
//            present the google Sign-In sheet
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            
//            Get the ID token from Google
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Missing Google ID token"
                return
            }
            
//            create firebase credential from google token
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
//            Sign in to firebase with google credential
            let authResult = try await Auth.auth().signIn(with: credential)
            self.currentUser = authResult.user
            
//            Call backend google login endpoint
            let response : AuthResponse = try await APIClient.shared.post(
                "/api/auth/login/google",
                body    : [:] as [String:String]
            )
            self.onboardingCompleted = response.onboardingCompleted ?? false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
//    Apple Sign in, triggered from Apple Sign in button delegate
    func handleAppleSignIn(
        authorization       : ASAuthorization
    ) async {
        isLoading = true
        defer{isLoading.toggle()}
        
        guard let appleCredential = authorization.credential as?
                ASAuthorizationAppleIDCredential,
              let identityToken = appleCredential.identityToken,
              let tokenString   = String(data : identityToken,encoding : .utf8) else {
            errorMessage = "Invalid Apple credential"
            return
        }
        do {
//            Create firebase credential from Apple Token.
            let credential = OAuthProvider.appleCredential(
                withIDToken: tokenString,
                rawNonce: nil,
                fullName: appleCredential.fullName
            )
            let authResult = try await Auth.auth().signIn(with: credential)
            self.currentUser = authResult.user
            
//            Apple sends only name on first sign up
            let name = [appleCredential.fullName?.givenName, appleCredential.fullName?.familyName]
                .compactMap{$0}.joined(separator: " ")
            
            let body : [String:String] = name.isEmpty ? [:] : ["name" : name]
            let response : AuthResponse = try await APIClient.shared.post("/api/auth/login/apple", body: body)
            self.onboardingCompleted = response.onboardingCompleted ?? false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
//    Fetch profile from backend
    func fetchProfile() async {
        do {
            struct ProfileResponse: Decodable {
                let user: User
            }
            let response : ProfileResponse = try await APIClient.shared.get("/api/auth/profile")
            self.userProfile = response.user
            self.onboardingCompleted = response.user.onBoardingCompleted
//            backend wraps user in a "user" key along with stats.
            
        }catch{
//            Silently fail - user will see login screen
        }
    }
    
//    logout
    func logout() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        userProfile = nil
        onboardingCompleted = false
    }
}


