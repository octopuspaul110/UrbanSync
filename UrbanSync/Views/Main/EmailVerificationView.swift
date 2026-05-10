import SwiftUI
import FirebaseAuth
 
struct EmailVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isSending = false
    @State private var sent = false
    @State private var isChecking = false
    @State private var verified = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: verified ? "checkmark.circle.fill" : "envelope.badge.shield.half.filled")
                    .font(.system(size: 64))
                    .foregroundColor(verified ? .urbanMint : .urbanAccent)
                
                Text(verified ? "Email Verified!" : "Verify Your Email")
                    .font(.jakartaTitle2)
                    .foregroundColor(.urbanTextPrimary)
                
                if let email = Auth.auth().currentUser?.email {
                    Text(verified ? "You're all set" : "We'll send a verification link to")
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                    Text(email)
                        .font(.jakarta(.semiBold, size: 15))
                        .foregroundColor(.urbanAccent)
                }
                
                if verified {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.jakarta(.semiBold, size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.urbanMint)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                } else {
                    // Send verification email
                    Button {
                        Task { await sendVerification() }
                    } label: {
                        Text(isSending ? "Sending..." : (sent ? "Resend Email" : "Send Verification Email"))
                            .font(.jakarta(.semiBold, size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.urbanAccent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isSending)
                    .padding(.horizontal, 24)
                    
                    if sent {
                        VStack(spacing: 12) {
                            Text("Check your inbox and tap the link, then tap below")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                Task { await checkVerification() }
                            } label: {
                                HStack(spacing: 8) {
                                    if isChecking {
                                        ProgressView().tint(.urbanAccent).scaleEffect(0.8)
                                    }
                                    Text(isChecking ? "Checking..." : "I've Verified My Email")
                                        .font(.jakarta(.medium, size: 14))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.urbanSurface)
                                .foregroundColor(.urbanAccent)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.urbanAccent.opacity(0.3)))
                            }
                            .disabled(isChecking)
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                if let error = errorMessage {
                    Text(error)
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanCoral)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button { dismiss() } label: {
                    Text("Skip for now")
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextTertiary)
                }
                .padding(.bottom, 32)
            }
        }
    }
    
    private func sendVerification() async {
        isSending = true
        errorMessage = nil
        defer { isSending = false }
        
        do {
            try await Auth.auth().currentUser?.sendEmailVerification()
            sent = true
        } catch {
            errorMessage = "Failed to send: \(error.localizedDescription)"
        }
    }
    
    private func checkVerification() async {
        isChecking = true
        errorMessage = nil
        defer { isChecking = false }
        
        do {
            // Reload user to get fresh email_verified status
            try await Auth.auth().currentUser?.reload()
            
            if Auth.auth().currentUser?.isEmailVerified == true {
                // Sync to backend
                try? await APIClient.shared.postNoContent(
                    "/api/auth/sync-email-verification",
                    body: [:] as [String: String]
                )
                withAnimation { verified = true }
            } else {
                errorMessage = "Email not verified yet. Check your inbox and try again."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}