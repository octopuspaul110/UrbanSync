import SwiftUI
import WebKit

struct GiftingView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedAmount: Int64 = 0
    @State private var customAmount = ""
    @State private var message = ""
    @State private var isProcessing = false
    @State private var errorMessage: String?
    @State private var paymentURL: String?
    @State private var showWebView = false
    @State private var gifts: [Gift] = []
    @State private var totalGifted = ""
    
    let presetAmounts: [(String, Int64)] = [
        ("₦1,000", 100_000),
        ("₦2,000", 200_000),
        ("₦5,000", 500_000),
        ("₦10,000", 1_000_000),
        ("₦20,000", 2_000_000),
        ("₦50,000", 5_000_000),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Event info
                        HStack(spacing: 12) {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.urbanGold)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gift for")
                                    .font(.jakartaCaption)
                                    .foregroundColor(.urbanTextTertiary)
                                Text(event.title)
                                    .font(.jakarta(.semiBold, size: 16))
                                    .foregroundColor(.urbanTextPrimary)
                                    .lineLimit(1)
                                if let creator = event.creatorName {
                                    Text("by \(creator)")
                                        .font(.jakartaCaption2)
                                        .foregroundColor(.urbanTextSecondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.urbanSurface)
                        .cornerRadius(12)
                        
                        // Total gifted so far
                        if !totalGifted.isEmpty {
                            HStack {
                                Text("Total gifted so far:")
                                    .font(.jakartaCaption)
                                    .foregroundColor(.urbanTextSecondary)
                                Text(totalGifted)
                                    .font(.jakarta(.bold, size: 14))
                                    .foregroundColor(.urbanGold)
                            }
                        }
                        
                        // Preset amounts
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Choose amount")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 10) {
                                ForEach(presetAmounts, id: \.1) { label, amount in
                                    Button {
                                        selectedAmount = amount
                                        customAmount = ""
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    } label: {
                                        Text(label)
                                            .font(.jakarta(.semiBold, size: 14))
                                            .foregroundColor(selectedAmount == amount ? .white : .urbanTextPrimary)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(selectedAmount == amount ? Color.urbanGold : Color.urbanSurface)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Custom amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Or enter custom amount")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                            HStack {
                                Text("₦")
                                    .font(.jakarta(.bold, size: 18))
                                    .foregroundColor(.urbanTextSecondary)
                                TextField("0", text: $customAmount)
                                    .keyboardType(.numberPad)
                                    .font(.jakarta(.bold, size: 18))
                                    .foregroundColor(.urbanTextPrimary)
                                    .onChange(of: customAmount) { _, val in
                                        if let naira = Int64(val), naira > 0 {
                                            selectedAmount = naira * 100
                                        }
                                    }
                            }
                            .padding(14)
                            .background(Color.urbanSurface)
                            .cornerRadius(12)
                        }
                        
                        // Message
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Add a message (optional)")
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                            TextField("Congratulations! 🎉", text: $message)
                                .font(.jakartaBody)
                                .foregroundColor(.urbanTextPrimary)
                                .padding(14)
                                .background(Color.urbanSurface)
                                .cornerRadius(12)
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanCoral)
                        }
                        
                        // Recent gifts
                        if !gifts.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent gifts")
                                    .font(.jakarta(.semiBold, size: 14))
                                    .foregroundColor(.urbanTextPrimary)
                                ForEach(gifts.prefix(5)) { gift in
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(Color.urbanGold.opacity(0.2))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text(gift.senderName.prefix(1).uppercased())
                                                    .font(.jakarta(.bold, size: 12))
                                                    .foregroundColor(.urbanGold)
                                            )
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(gift.senderName)
                                                .font(.jakartaCaption)
                                                .foregroundColor(.urbanTextPrimary)
                                            if let msg = gift.message, !msg.isEmpty {
                                                Text(msg)
                                                    .font(.jakartaCaption2)
                                                    .foregroundColor(.urbanTextTertiary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Text(gift.formattedAmount)
                                            .font(.jakarta(.bold, size: 13))
                                            .foregroundColor(.urbanGold)
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color.urbanSurface)
                            .cornerRadius(12)
                        }
                        
                        // Send button
                        Button {
                            Task { await sendGift() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill")
                                Text(isProcessing ? "Processing..." :
                                     selectedAmount > 0 ? "Send ₦\(selectedAmount / 100)" : "Select an amount")
                            }
                            .font(.jakarta(.semiBold, size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedAmount > 0 ? Color.urbanGold : Color.urbanSurfaceLight)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(selectedAmount <= 0 || isProcessing)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Send a Gift")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.urbanTextPrimary)
                    }
                }
            }
            .task { await fetchGifts() }
            .sheet(isPresented: $showWebView) {
                if let url = paymentURL {
                    PaystackWebView(url: url) {
                        showWebView = false
                        Task { await fetchGifts() }
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendGift() async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }
        
        do {
            struct GiftBody: Encodable {
                let amount_kobo: Int64
                let message: String?
            }
            struct GiftResponse: Decodable {
                let gift_id: UUID
                let payment_url: String
                let reference: String
            }
            let response: GiftResponse = try await APIClient.shared.post(
                "/api/events/\(event.id)/gifts",
                body: GiftBody(
                    amount_kobo: selectedAmount,
                    message: message.isEmpty ? nil : message
                )
            )
            paymentURL = response.payment_url
            showWebView = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchGifts() async {
        do {
            struct R: Decodable {
                let gifts: [Gift]
                let total_kobo: Int64
                let total_formatted: String
            }
            let r: R = try await APIClient.shared.get("/api/events/\(event.id)/gifts", authenticated: false)
            gifts = r.gifts
            totalGifted = r.total_formatted
        } catch {}
    }
}

struct Gift: Codable, Identifiable {
    let id: UUID
    let amountKobo: Int64
    let message: String?
    let senderName: String
    let senderImage: String?
    let createdAt: Date?
    
    var formattedAmount: String {
        "₦\(amountKobo / 100)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, message
        case amountKobo = "amount_kobo"
        case senderName = "sender_name"
        case senderImage = "sender_image"
        case createdAt = "created_at"
    }
}

// Simple Paystack WebView
struct PaystackWebView: UIViewRepresentable {
    let url: String
    let onComplete: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let onComplete: () -> Void
        init(onComplete: @escaping () -> Void) { self.onComplete = onComplete }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url?.absoluteString,
               url.contains("payment/callback") {
                onComplete()
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}