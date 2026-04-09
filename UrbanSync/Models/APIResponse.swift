//
//  APIResponse.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import Foundation

// Generic wrapper for paginated list response.
// The backend returns: { "events": [...], "total": 20, "has_more": true }
struct PaginatedResponse<T: Decodable> : Decodable {
    let events          :[T]?
    let tickets         :[T]?
    let notifications   :[T]?
    let total           :Int?
    let hasMore         :Bool?
    
    enum CodingKeys : String, CodingKey {
        case events, tickets, notifications, total
        case hasMore = "has_more"
    }
}

// Login/Register response.
struct AuthResponse : Decodable {
    let userId              : UUID?
    let action              : String?
    let name                : String?
    let onboardingCompleted : Bool?
    let emailVerified       : Bool?
    let message             : String?
    
    
    enum CodingKeys : String, CodingKey {
        case action, name, message
        case userId              = "user_id"
        case onboardingCompleted = "onboarding_completed"
        case emailVerified       = "email_verified"
    }
}

// Event creation response
struct CreateEventResponse : Decodable {
    let id              : UUID
    let slug            : String
    let joinCode        : String
    let privateJoinCode : String
    let recurrence      : String?
    
    enum CodingKeys : String, CodingKey {
        case id, slug, recurrence
        case joinCode        = "join_code"
        case privateJoinCode = "private_join_code"
    }
}

// Ticket purchase response.
struct PurchaseResponse : Decodable {
    let ticketId        : UUID
    let status          : String
    let paymentUrl      : String?
    let qrCode          : String?
    
    enum CodingKeys : String, CodingKey {
        case status
        case ticketId        = "ticket_id"
        case paymentUrl      = "payment_url"
        case qrCode          = "qr_code"
    }
}

