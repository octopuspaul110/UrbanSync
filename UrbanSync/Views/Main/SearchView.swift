//
//  SearchView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//
import SwiftUI
import Combine

struct SearchView: View {
    @State private var searchVM = SearchViewModel()

    let categories: [(String, String, String, Color)] = [
        ("sports",       "Sports",       "sportscourt.fill",      .green),
        ("concert",      "Concerts",     "music.mic",             .orange),
        ("tech",         "Tech",         "laptopcomputer",        .blue),
        ("celebration",  "Celebrations", "party.popper.fill",     .pink),
        ("nightlife",    "Nightlife",    "moon.stars.fill",       .purple),
        ("heritage",     "Heritage",     "building.columns.fill", .brown),
        ("conference",   "Conference",   "person.3.fill",         .teal),
        ("corporate",    "Corporate",    "briefcase.fill",        .yellow),
        ("art",          "Art",          "paintpalette.fill",     .indigo),
        ("public_square","Public Square","globe",                 .cyan),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.urbanTextTertiary)
                        TextField("Search events or paste join code", text: $searchVM.query)
                            .foregroundColor(.urbanTextPrimary)
                            .autocapitalization(.none)
                            .onChange(of: searchVM.query) { _, _ in searchVM.search() }
                        if !searchVM.query.isEmpty {
                            Button {
                                searchVM.query = ""
                                searchVM.results = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.urbanTextTertiary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.urbanSurface)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // State: searching
                    if searchVM.isSearching {
                        Spacer()
                        ProgressView().tint(.urbanAccent)
                        Spacer()

                    // State: no results
                    } else if searchVM.results.isEmpty && !searchVM.query.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 48))
                                .foregroundColor(.urbanTextTertiary)
                            Text("No events found")
                                .foregroundColor(.urbanTextSecondary)
                        }
                        Spacer()

                    // State: has results
                    } else if !searchVM.results.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(searchVM.results) { event in
                                    NavigationLink(value: event.id) {
                                        EventCardView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                        }

                    // State: idle — show category grid
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Browse categories")
                                    .font(.jakartaHeadline.weight(.medium))
                                    .foregroundColor(.urbanTextPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    .padding(.bottom, 12)

                                LazyVGrid(
                                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                                    spacing: 10
                                ) {
                                    ForEach(categories, id: \.0) { cat in
                                        CategoryTile(
                                            slug: cat.0,
                                            label: cat.1,
                                            icon: cat.2,
                                            color: cat.3
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search events")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: UUID.self) { eventId in
                EventDetailView(eventId: eventId)
            }
        }
    }
}

struct CategoryTile: View {
    let slug: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background color
            color.opacity(0.85)

            // Rotated icon — bottom right
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.white.opacity(0.25))
                .rotationEffect(.degrees(-20))
                .offset(x: 18, y: 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)

            // Label
            Text(label)
                .font(.jakartaSubheadline.weight(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .frame(height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
