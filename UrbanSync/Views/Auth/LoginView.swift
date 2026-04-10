//
//  LoginView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    var authVM : AuthViewModel
    
    @State private var email        : String = ""
    @State private var password     : String = ""
    @State private var showRegister : Bool = false
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                ScrollView {
                    VStack(spacing : 24) {
                        Spacer().frame(height : 60)
                        
//                      Logo
                        Image(systemName: "bolt.circle.fill")
                            .font(.system(size: 60))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.urbanAccent)
                        
                        Text("Welcome Back")
                            .font(.jakartaTitle)
                            .foregroundColor(.urbanTextPrimary)
                        
                        Text("Sign in to discover events")
                            .font(.jakartaFootnote)
                            .foregroundColor(.urbanTextSecondary)
                        
//                        Email Field
                        VStack(alignment : .leading,spacing: 8) {
                            Text("Email")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                            TextField("", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color.urbanSurface)
                                .cornerRadius(12)
                                .foregroundColor(.urbanTextPrimary)
                        }
                        
//                        Password field
                        VStack(alignment : .leading,spacing: 8) {
                            Text("Password")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                            SecureField("", text: $password)
                                .textContentType(.password)
                                .padding()
                                .background(Color.urbanSurface)
                                .cornerRadius(12)
                                .foregroundColor(.urbanTextPrimary)
                        }
                        
//                        login button
                        Button{
                            Task{
                                await authVM.login(email: email, password: password)
                            }
                        } label : {
                            Group {
                                if authVM.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.jakartaTitle2)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.urbanAccent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(email.isEmpty || password.isEmpty || authVM.isLoading)
                        
//                        Divider
                        HStack{
                            Rectangle()
                                .frame(height : 1)
                                .foregroundColor(.urbanSurfaceLight)
                            Text("or")
                                .foregroundColor(.urbanTextTertiary)
                                .font(.jakartaCaption)
                            Rectangle()
                                .frame(height : 1)
                                .foregroundColor(.urbanSurfaceLight)
                        }
//                        Google Sign in
                        Button {
                            Task {await authVM.signInWithGoogle()}
                        } label : {
                            HStack {
                                Label("Sign in with Google", systemImage: "google")
                            }
                            .frame(maxWidth : .infinity)
                            .padding()
                            .background(Color.urbanSurface)
                            .foregroundColor(.urbanTextPrimary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color.urbanSurfaceLight,
                                        lineWidth: 1)
                            )
                        }
                        
                        // ── Apple Sign-In ──
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            switch result {
                            case .success(let auth):
                                Task { await authVM.handleAppleSignIn(authorization: auth) }
                            case .failure(let error):
                                authVM.errorMessage = error.localizedDescription
                            }
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 50)
                        .cornerRadius(12)
                        
//                        Register Link
                        Button {
                            showRegister = true
                        } label : {
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(.urbanTextSecondary)
                                Text("Sign Up")
                                    .foregroundColor(.urbanAccent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(.horizontal,24)
                }
            }
            .navigationDestination(
                isPresented: $showRegister,
            ) {
                RegisterView(auth : authVM)
            }
            .alert("Error", isPresented: .init(
                get: {authVM.errorMessage != nil},
                set: {if !$0 {authVM.errorMessage = nil}}
            )) {
                Button("OK") {
                    authVM.errorMessage = nil
                }
            }message : {
                    Text(authVM.errorMessage ?? "")
            }
        }
    }
}

//#Preview {
//    LoginView()
//}
