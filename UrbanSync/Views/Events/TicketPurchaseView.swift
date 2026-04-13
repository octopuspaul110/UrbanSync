//
//  TicketPurchaseView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//

import SwiftUI
import WebKit
import AVFoundation

struct TicketPurchaseView: View {
    let event   : Event
    let tiers   : [TicketTier]
    
    @State private var selectedTier         : TicketTier?
    @State private var paymentURL           : String?
    @State private var isPurchasing         : Bool = false
    @State private var purchaseCompleted    : Bool = false
    @State private var errorMessage         : String?
    @State private var audioPlayer          : AVAudioPlayer?
    @State private var webViewLoading              = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                if let url = paymentURL {
                    ZStack{
//                        Paystack WebView
                        PaystackWebView(urlString : url,onComplete: {
                            purchaseCompleted = true
                            paymentURL        = nil
                        }, isLoading: $webViewLoading)
                    }
                    if webViewLoading {
                        ZStack {
                            Color.urbanBackground.opacity(0.8)
                            VStack(spacing: 12) {
                                ProgressView().tint(.urbanAccent)
                                Text("Loading payment...")
                                    .font(.jakartaCaption)
                                    .foregroundColor(.urbanTextSecondary)
                            }
                        }
                    }
                } else if purchaseCompleted{
//                    Success State
                    successView
                } else {
//                    Tier selection
                    tierSelectionView
                }
            }
            .navigationTitle(event.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    private var tierSelectionView: some View {
        VStack(spacing: 16) {
            Text("Select a ticket")
                .font(.title3.weight(.bold))
                .foregroundColor(.urbanTextPrimary)

            ForEach(tiers) { tier in
                Button {
                    selectedTier = tier
                    errorMessage = nil
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tier.name)
                                .font(.headline)
                                .foregroundColor(.urbanTextPrimary)
                            Text("\(tier.quantityTotal - tier.quantitySold) remaining")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                        }
                        Spacer()
                        Text(tier.formattedPrice)
                            .font(.jakartaHeadline.weight(.bold))
                            .foregroundColor(tier.priceKobo == 0 ? .urbanMint : .urbanGold)
                        Image(systemName: selectedTier?.id == tier.id ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(.urbanAccent)
                    }
                    .padding()
                    .background(selectedTier?.id == tier.id ? Color.urbanAccent.opacity(0.1) : Color.urbanSurface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedTier?.id == tier.id ? Color.urbanAccent : Color.clear, lineWidth: 2)
                    )
                    .opacity(tier.isSoldOut ? 0.5 : 1)
                }
                .disabled(tier.isSoldOut)
            }

            // Error banner
            if let error = errorMessage {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.urbanCoral)
                        .font(.system(size: 14))
                    Text(error)
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanCoral)
                    Spacer()
                    Button {
                        withAnimation { errorMessage = nil }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12))
                            .foregroundColor(.urbanCoral)
                    }
                }
                .padding(12)
                .background(Color.urbanCoral.opacity(0.1))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.urbanCoral.opacity(0.3), lineWidth: 0.5)
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()

            Button {
                Task { await purchaseTicket() }
            } label: {
                HStack(spacing: 8) {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    }
                    Text(isPurchasing ? "Processing..." : selectedTier?.priceKobo == 0 ? "Get Free Ticket" : "Buy Ticket")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(selectedTier == nil ? Color.urbanSurfaceLight : Color.urbanAccent)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(selectedTier == nil || isPurchasing)
        }
        .padding(16)
        .animation(.easeInOut(duration: 0.3), value: errorMessage)
    }
    
    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.urbanMint)

            Text("Ticket Confirmed!")
                .font(.title2.weight(.bold))
                .foregroundColor(.urbanTextPrimary)

            Text("Check your tickets tab for your QR code.")
                .font(.jakartaCaption)
                .foregroundColor(.urbanTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Done") { dismiss() }
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.urbanAccent)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
    
    private func purchaseTicket() async {
        guard let tier = selectedTier else { return }

        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            struct PurchaseBody: Encodable { let tier_id: String }
            let body = PurchaseBody(tier_id: tier.id.uuidString)
            let response: PurchaseResponse = try await APIClient.shared.post(
                "/api/tickets/purchase",
                body: body
            )

            if let url = response.paymentUrl {
                paymentURL = url
            } else {
                // Free ticket — confirmed immediately
                purchaseCompleted = true
                playSuccessSound()
            }
        } catch let apiError as APIError {
            switch apiError {
            case .serverError(let code, let message):
                switch code {
                case 400: errorMessage = "Invalid request — \(message)"
                case 401: errorMessage = "You need to be logged in to purchase tickets"
                case 403: errorMessage = "You don't have access to this ticket"
                case 404: errorMessage = "This ticket tier no longer exists"
                case 409: errorMessage = "Sorry, this ticket just sold out"
                case 422: errorMessage = message
                case 500: errorMessage = "Something went wrong on our end. Please try again"
                default:  errorMessage = message
                }
            case .networkError:
                errorMessage = "No internet connection. Please check your network and try again"
            case .decodingError:
                errorMessage = "Something went wrong. Please try again"
            default:
                errorMessage = "An unexpected error occurred. Please try again"
            }
        } catch {
            errorMessage = "An unexpected error occurred. Please try again"
        }
    }
    private func playSuccessSound() {
            // use a system sound (no asset needed)
            AudioServicesPlaySystemSound(1325) // iOS "payment" chime

            // to use sound file
            // Drop a "success.mp3" into your Xcode project then:
            // guard let url = Bundle.main.url(forResource: "success", withExtension: "mp3") else { return }
            // audioPlayer = try? AVAudioPlayer(contentsOf: url)
            // audioPlayer?.play()

            // Haptic alongside the sound
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
}

//#Preview {
//    TicketPurchaseView()
//}
