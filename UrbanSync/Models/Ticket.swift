//
//  Ticket.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import Foundation

struct TicketTier : Codable, Identifiable {
    let id                : UUID
    let name              : String
    let description       : String?
    let priceKobo         : Int64
    let quantityTotal     : Int
    let quantitySold      : Int
    let available         : Int?
    
//    format price for display : 500000 kobo -> "\u20a65,000"
    var formattedPrice: String {
        if priceKobo == 0 {return "Free"}
        let naira                       = Double(priceKobo) / 100.0
        let formatter                   = NumberFormatter()
        formatter.numberStyle           = .currency
        formatter.currencyCode          = "NGN"
        formatter.currencySymbol        = "\u{20A6}"
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: naira)) ?? "\u{20a6}\(Int(naira))"
    }
    
    var isSoldOut : Bool {
        quantitySold >= quantityTotal
    }
    
    enum CodingKeys : String, CodingKey {
        case id, name, description, available
        case priceKobo      = "price_kobo"
        case quantityTotal  = "quantity_total"
        case quantitySold   = "quantity_sold"
    }
}

struct Ticket: Codable, Identifiable {
    let id: UUID
    let status: String
    let qrCode: String
    let createdAt: Date?
    // Joined from events table
    let eventId: UUID?
    let title: String?
    let startTime: Date?
    let endTime: Date?
    let venueName: String?
    let city: String?
    let coverImageUrl: String?
    let slug: String?
    let tierName: String?
    let priceKobo: Int64?
 
    enum CodingKeys: String, CodingKey {
        case id, status, title, city, slug
        case qrCode = "qr_code"
        case createdAt = "created_at"
        case eventId = "event_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case venueName = "venue_name"
        case coverImageUrl = "cover_image_url"
        case tierName = "tier_name"
        case priceKobo = "price_kobo"
    }
}

