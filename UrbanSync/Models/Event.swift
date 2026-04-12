//
//  Event.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import Foundation

struct Event: Codable, Identifiable, Hashable {
    let id                  : UUID
    let title               : String
    let slug                : String
    let description         : String?
    let category            : String?
    let status              : String?
    let visibility          : String?
    let venueName           : String?
    let venueAddress        : String?
    let city                : String?
    let state               : String?
    let latitude            : Double?
    let longitude           : Double?
    let startTime           : Date
    let endTime             : Date
    let coverImageUrl       : String?
    let dressCode           : String?
    let joinCode            : String
    let privateJoinCode     : String
    let giftingEnabled      : Bool
    let maxCapacity         : Int?
    let createdAt           : Date?
    let isPaid              : Bool
    let creatorName         : String?
    let metadata            : [String: String]?
    let recurrence          : String?
    let recurrenceDays      : [Int]?
    let recurrenceInterval  : Int?
    let recurrenceEndDate   : Date?
    let occurrenceNumber    : Int?
    let recurrenceParentId  : UUID?
 
    // Computed properties for UI display.
 
    // Is the event happening right now?
    var isLive: Bool {
        let now = Date()
        return now >= startTime && now <= endTime
    }
 
    // Is the event starting within the next 24 hours?
    var isUpcoming: Bool {
        let now = Date()
        let hoursUntil = startTime.timeIntervalSince(now) / 3600
        return hoursUntil > 0 && hoursUntil <= 24
    }
 
    // Has the event ended?
    var hasEnded: Bool {
        Date() > endTime
    }
 
    // Is this a free event (no paid tiers)?
    var isFree: Bool {
        // This gets set by the ViewModel after fetching tiers.
        // Default to false if unknown.
        return false
    }
 
    enum CodingKeys: String, CodingKey {
        case id, title, slug, description, category, status, visibility
        case latitude, longitude, city, state,metadata
        case venueName              = "venue_name"
        case venueAddress           = "venue_address"
        case startTime              = "start_time"
        case endTime                = "end_time"
        case coverImageUrl          = "cover_image_url"
        case dressCode              = "dress_code"
        case joinCode               = "join_code"
        case privateJoinCode        = "private_join_code"
        case giftingEnabled         = "gifting_enabled"
        case maxCapacity            = "max_capacity"
        case createdAt              = "created_at"
        case isPaid                 = "is_paid"
        case creatorName            = "creator_name"
        case recurrence             = "recurrence"
        case recurrenceDays         = "recurrence_days"
        case recurrenceInterval     = "recurrence_interval"
        case recurrenceEndDate      = "recurrence_end_date"
        case occurrenceNumber       = "occurrence_number"
        case recurrenceParentId     = "recurrence_parent_id"
    }
}
