struct NotificationDetailSheet: View {
    let notification: AppNotification
    @Environment(\.dismiss) private var dismiss
    @State private var showEventDetail = false
    @State private var showTicketDetail = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Icon + type
                    HStack(spacing: 12) {
                        Image(systemName: notificationIcon(notification.notificationType))
                            .font(.system(size: 24))
                            .foregroundColor(notificationColor(notification.notificationType))
                            .frame(width: 56, height: 56)
                            .background(notificationColor(notification.notificationType).opacity(0.15))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(notification.notificationType.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(.jakartaCaption.weight(.semibold))
                                .foregroundColor(notificationColor(notification.notificationType))
                            if let createdAt = notification.createdAt {
                                Text(createdAt.formatted(.dateTime.day().month(.wide).year().hour().minute()))
                                    .font(.jakartaCaption2)
                                    .foregroundColor(.urbanTextTertiary)
                            }
                        }
                        Spacer()
                    }
                    
                    // Title
                    Text(notification.title)
                        .font(.jakarta(.bold, size: 22))
                        .foregroundColor(.urbanTextPrimary)
                    
                    // Body
                    Text(notification.body)
                        .font(.jakartaBody)
                        .foregroundColor(.urbanTextSecondary)
                        .lineSpacing(4)
                    
                    Spacer(minLength: 40)
                    
                    // Action button — depends on type
                    if let referenceId = notification.referenceId {
                        actionButton(referenceId: referenceId)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Notification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.urbanTextPrimary)
                    }
                }
            }
            .sheet(isPresented: $showEventDetail) {
                if let referenceId = notification.referenceId {
                    NavigationStack {
                        EventDetailView(eventId: referenceId)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func actionButton(referenceId: UUID) -> some View {
        switch notification.notificationType {
        case "ticket", "ticket_confirmed":
            Button {
                showEventDetail = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "ticket.fill")
                    Text("View Event")
                }
                .font(.jakarta(.semiBold, size: 15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.urbanGold)
                .cornerRadius(12)
            }
        case "event", "reminder":
            Button {
                showEventDetail = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Open Event")
                }
                .font(.jakarta(.semiBold, size: 15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.urbanAccent)
                .cornerRadius(12)
            }
        case "follow":
            Button {
                // Navigate to YourPeopleView or user profile
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                    Text("View Profile")
                }
                .font(.jakarta(.semiBold, size: 15))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.urbanCoral)
                .cornerRadius(12)
            }
        default:
            EmptyView()
        }
    }
    
    private func notificationIcon(_ type: String) -> String {
        switch type {
        case "ticket", "ticket_confirmed": return "ticket.fill"
        case "rsvp":     return "person.badge.plus"
        case "event":    return "calendar.badge.plus"
        case "follow":   return "person.2.fill"
        case "refund":   return "arrow.uturn.backward.circle.fill"
        case "reminder": return "bell.fill"
        default:         return "bell.fill"
        }
    }
    
    private func notificationColor(_ type: String) -> Color {
        switch type {
        case "ticket", "ticket_confirmed": return .urbanGold
        case "rsvp":     return .urbanMint
        case "event":    return .urbanAccent
        case "follow":   return .urbanCoral
        case "refund":   return .urbanGold
        case "reminder": return .urbanAccent
        default:         return .urbanTextSecondary
        }
    }
}