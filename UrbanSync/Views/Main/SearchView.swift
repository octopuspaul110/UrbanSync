//
//  SearchView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//

import SwiftUI

struct SearchView: View {
    @State private var searchVM = SearchViewModel()
    var body: some View {
        NavigationStack{
            Color.urbanBackground.ignoresSafeArea()
            VStack(spacing : 0) {
//                Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.urbanTextTertiary)
                    TextField("Search events or paste join code",text : $searchVM.query)
                        .foregroundColor(.urbanTextPrimary)
                        .autocapitalization(.none)
                        .onChange(of: searchVM.query) { oldValue, newValue in
                            searchVM.search()
                        }
                    if !searchVM.query.isEmpty {
                        Button {
                            searchVM.query = ""
                            searchVM.results = []
                        } label : {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.urbanTextTertiary)
                        }
                    }
                }
                .padding(12)
                .background(Color.urbanSurface)
                .cornerRadius(12)
                .padding(.horizontal,16)
                .padding(.top,8)
                
//                Results
                if searchVM.isSearching {
                    Spacer()
                    ProgressView().tint(.urbanAccent)
                    Spacer()
                } else if searchVM.results.isEmpty && !searchVM.query.isEmpty{
                    Spacer()
                    VStack(spacing : 12){
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.urbanTextTertiary)
                        Text("No events found")
                            .foregroundColor(.urbanTextSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing : 12) {
                            ForEach(searchVM.results) { event in
                                NavigationLink(value : event.id) {
                                    EventCardView(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .navigationTitle(Text("Look for Events").font(.jakartaTitle2).foregroundColor(.urbanTextSecondary))
        .navigationDestination(for: UUID.self) { eventId in
            EventDetailView(eventId: <#T##UUID#>)
        }
    }
}

#Preview {
    SearchView()
}
