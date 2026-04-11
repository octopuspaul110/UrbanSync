//
//  SearchViewModel.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import Foundation

@Observable
class SearchViewModel {
    var query = ""
    var results             : [Event] = []
    var isSearching         : Bool = false
    var selectedCategory    : String?
    var selectedCity        : String?
    var errorMessage        : String?
    
    private var searchTask : Task<Void,Never>?
    
    func search() {
//        Cancel any pending search
        searchTask?.cancel()
        searchTask = Task {
//            wait 800ms for users to initiate search
            try? await Task.sleep(for: .milliseconds(500))
            
            guard !Task.isCancelled else {return}
            
            await performSearch()
        }
    }
    
    private func performSearch() async {
        guard  !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            results = []
            return
        }
        
        isSearching = true
        
        defer { isSearching = false}
        
        do {
            var path = "/api/events/search?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
            if let cat = selectedCategory { path += "&category=\(cat)"}
            if let city = selectedCity {path += "&city=\(city)"}
            
            let response : PaginatedResponse<Event> = try await APIClient.shared.get(
                path,
                authenticated : false
            )
            self.results = response.events ?? []
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
}
