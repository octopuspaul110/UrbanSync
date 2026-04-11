//
//  FeedViewModel.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth


@Observable
class FeedViewModel {
    var events : [Event] = []
    var isLoading: Bool = false
    var isRefreshing: Bool = false
    var errorMessage: String?
    var hasMore = true
    private var offset = 0
    private let limit = 20
    
    
//    Fetch personalized feed from the backend
    func fetchFeed(refresh : Bool = false) async {
        if refresh {
            offset = 0
            isRefreshing = true
        } else {
            if isLoading || !hasMore {return}
            isLoading = true
        }
        defer {
            isLoading = false
            isRefreshing = false
        }
        do {
            let response : PaginatedResponse<Event> = try await APIClient.shared.get("/api/events/feed?limit=\(limit)&offset=\(offset)")
            let newEvents = response.events ?? []
            if refresh {
                events = newEvents
            } else {
                events.append(contentsOf: newEvents)
            }
            hasMore = response.hasMore ?? false
            offset += newEvents.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
