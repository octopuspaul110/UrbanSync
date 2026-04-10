//
//  EventCard.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI
import Kingfisher

struct EventCardView: View {
    let event : Event
    
    var body: some View {
        VStack(alignment : .leading,spacing: 0) {
            //            Cover Image
            ZStack(alignment: .topTrailing) {
                //                KFImage is kingfishers cached image loader.it downloads the image once and cached it on disk.
                if let url = event.coverImageUrl.flatMap({URL(string : $0)}) {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(16/9,contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.categoryColor(for: event.category ?? ""), .urbanSurface],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height : 180)
                }
                //                Status Badges
                //                Stacked in the top-right corner.
                VStack(spacing : 6){
                    if event.isLive {
                        EventBadge(text : "LIVE",color : .urbanCoral,icon : "antenna.radiowaves.left.and.right")
                    } else if event.isUpcoming {
                        EventBadge(text : "UPCOMING",color : .urbanGold,icon : "clock.fill")
                    }
                    
                    if event.visibility == "private" {
                        EventBadge(text : "PRIVATE",color : .urbanAccent,icon: "lock.fill")
                    }
                }
                .padding(8)
            }
            //            Event info
            VStack(alignment: .leading,spacing : 8) {
                //                Category chip
                if let cat = event.category {
                    Text(cat.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.jakartaCaption.weight(.semibold))
                        .foregroundColor(Color.categoryColor(for: cat))
                }
                
                //                Title
                Text(event.title)
                    .font(.jakartaHeadline)
                    .foregroundColor(.urbanTextPrimary)
                    .lineLimit(2)
                
                //                Date + Time
                HStack(spacing : 4){
                    Image(systemName: "calendar")
                    Text(event.startTime.shortFormatted)
                    Text("\u{2022}")
                    Text(event.startTime.timeOnly)
                }
                .font(.jakartaCaption)
                .foregroundColor(.urbanTextPrimary)
                
                //                Venue
                if let venue = event.venueName{
                    HStack(spacing : 4){
                        Image(systemName: "mappin.and.ellipse")
                        Text(venue)
                        if let city = event.city {
                            Text("\u{2022} \(city)")
                        }
                    }
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanTextSecondary)
                    .lineLimit(1)
                }
            }
            .padding(12)
        }
        .background(Color.urbanSurface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }
}

//#Preview {
//    EventCardView()
//}
