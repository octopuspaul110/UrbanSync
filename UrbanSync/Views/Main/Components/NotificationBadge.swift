@Observable
class NotificationBadge {
    static let shared = NotificationBadge()
    var unreadCount = 0
    
    func refresh() async {
        do {
            struct R: Decodable { let count: Int }
            let r: R = try await APIClient.shared.get("/api/notifications/unread-count")
            unreadCount = r.count
        } catch {}
    }
}