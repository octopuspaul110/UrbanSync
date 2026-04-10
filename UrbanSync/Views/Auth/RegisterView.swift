//
//  RegisterView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI

struct RegisterView: View {
    var authVM : AuthViewModel
    
    @State private var name             : String = ""
    @State private var email            : String = ""
    @State private var password         : String = ""
    @State private var confirmPassword  : String = ""
    @Environment(\.dismiss) private var dismiss
    
//    Computed Validation
    private var isValid : Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing : 20){
                    Text("Create Account")
                        .font(.jakartaTitle)
                        .foregroundColor(.urbanTextPrimary)
                    Text("Join the UrbanSync community")
                        .foregroundColor(.urbanTextSecondary)
                    
//                    Name Field
                    fieldSection(title : "Full Name") {
                        TextField("", text: $name)
                            .textContentType(.name)
                    }
                    
//                    Email Field
                    fieldSection(title : "Email") {
                        TextField("", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    
//                    Password Field
                    fieldSection(title : "Password (min 6 character)"){
                        SecureField("", text: $password)
                            .textContentType(.password)
                    }
                    
//                    Confirm Password
                    fieldSection(title : "Confirm Password"){
                        SecureField("", text: $confirmPassword)
                    }
                    
//                    Password mismatch warning
                    if !confirmPassword.isEmpty && password != confirmPassword {
                        Text("Passwords do not match")
                            .font(.jakartaCaption)
                            .foregroundColor(.urbanCoral)
                    }
                    
//                    Register Button
                    Button {
                        Task { await authVM.register(
                            name: name,
                            email: email,
                            password: password
                            )
                        }
                    } label : {
                        Group {
                            if authVM.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth : .infinity)
                        .padding()
                        .background(isValid ? Color.urbanAccent : Color.urbanSurfaceLight)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isValid || authVM.isLoading)
                }
                .padding(.horizontal,24)
                .padding(.top,40)
            }
        }
        .navigationBarBackButtonHidden(false)
    }
//    Reusable field section with title and styled input
    @ViewBuilder
    private func fieldSection<Content : View>(title : String,@ViewBuilder content : () -> Content) -> some View {
        VStack(alignment: .leading,spacing : 8) {
            Text(title)
                .font(.jakartaCaption)
                .foregroundColor(.urbanTextSecondary)
            content()
                .padding()
                .background(Color.urbanSurface)
                .cornerRadius(12)
                .foregroundColor(.urbanTextPrimary)
        }
    }
}

