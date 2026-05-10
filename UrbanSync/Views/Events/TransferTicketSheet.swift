struct TransferTicketSheet: View {
    let ticket: Ticket
    @Environment(\.dismiss) private var dismiss
    @State private var recipientEmail = ""
    @State private var isTransferring = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.urbanAccent)
                        Text("Send Ticket as Gift")
                            .font(.jakarta(.bold, size: 20))
                            .foregroundColor(.urbanTextPrimary)
                        Text("Transfer this ticket to another UrbanSync user. Once sent, you can't get it back.")
                            .font(.jakartaCaption)
                            .foregroundColor(.urbanTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 32)
                    
                    // Ticket summary
                    VStack(alignment: .leading, spacing: 6) {
                        Text(ticket.title ?? "Event")
                            .font(.jakarta(.semiBold, size: 15))
                            .foregroundColor(.urbanTextPrimary)
                        if let time = ticket.startTime {
                            Text(time.formatted(.dateTime.weekday(.wide).day().month().hour().minute()))
                                .font(.jakartaCaption)
                                .foregroundColor(.urbanTextSecondary)
                        }
                        if let tier = ticket.tierName {
                            Text(tier)
                                .font(.jakarta(.medium, size: 11))
                                .foregroundColor(.urbanAccent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.urbanAccent.opacity(0.12))
                                .cornerRadius(4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.urbanSurface)
                    .cornerRadius(12)
                    
                    // Email input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Recipient's Email")
                            .font(.jakartaCaption)
                            .foregroundColor(.urbanTextSecondary)
                        TextField("friend@example.com", text: $recipientEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(14)
                            .background(Color.urbanSurface)
                            .cornerRadius(12)
                            .foregroundColor(.urbanTextPrimary)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.jakartaCaption)
                            .foregroundColor(.urbanCoral)
                    }
                    
                    if let success = successMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.urbanMint)
                            Text(success)
                                .font(.jakartaSubheadline)
                                .foregroundColor(.urbanMint)
                        }
                    }
                    
                    Spacer()
                    
                    // Send button
                    Button {
                        Task { await transferTicket() }
                    } label: {
                        Text(isTransferring ? "Sending..." : "Send Ticket")
                            .font(.jakarta(.semiBold, size: 15))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(recipientEmail.isEmpty || isTransferring ? Color.urbanTextTertiary : Color.urbanAccent)
                            .cornerRadius(12)
                    }
                    .disabled(recipientEmail.isEmpty || isTransferring || successMessage != nil)
                }
                .padding(20)
            }
            .navigationTitle("Send Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.urbanTextSecondary)
                }
            }
        }
    }
    
    private func transferTicket() async {
        let email = recipientEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return }
        
        isTransferring = true
        defer { isTransferring = false }
        errorMessage = nil
        
        struct TransferBody: Encodable { let recipient_email: String }
        struct TransferResponse: Decodable {
            let transferred: Bool
            let recipient_name: String
        }
        
        do {
            let response: TransferResponse = try await APIClient.shared.post(
                "/api/tickets/\(ticket.id)/transfer",
                body: TransferBody(recipient_email: email)
            )
            successMessage = "Ticket sent to \(response.recipient_name)!"
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            // Auto-dismiss after 2s
            try? await Task.sleep(for: .seconds(2))
            dismiss()
        } catch {
            errorMessage = "Could not send ticket. Make sure the email is correct and the user has signed up."
        }
    }
}