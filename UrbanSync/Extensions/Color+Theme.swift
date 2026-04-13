//
//  Color+Theme.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI

//Extension on Color adds brand colors as static properties.
extension Color {
//    Backgrounds, darkest color. for main app background.
    static let urbanBackground = Color(hex : "000000")
    
//    Slightly lighter surface cards, sheets and elevated content.
    static let urbanSurface = Color(hex : "1A1A2E")
    
//    lighter surface for nested elements
    static let urbanSurfaceLight = Color(hex : "252542")
    static let urbanAccentEnd    = Color(hex: "e63264")
    static let entryColor        = Color(hex: "CCCCFF")
    
//    Accent Colors, Primary accent- electric purple. Used for primary buttons,selected tab icons and active states
    static let urbanAccent = Color(hex : "4f0c28")
    
//    Secondary accent - warm coral/orange for badges, notifications count and live indicator
    static let urbanCoral = Color(hex : "FF6B6B")
    
//    Tertiary accent - teal/mint
    static let urbanMint = Color(hex : "00D4AA")
    
//    Gold/amber - used for glowing progress bar and upcoming badge to create urgency.
    static let urbanGold = Color(hex : "FFB800")
    
//    Text Colors
//    Primary text, bright white for headings and important text.
    static let urbanTextPrimary = Color(hex : "F5F5F5")
    
//    Secondary text, muted gray for descriptions,timestamps, metadata.
    static let urbanTextSecondary = Color(hex : "9A9AB0")
    
//    Tertiary text - dimmer gray for placeholders and disabled states.
    static let urbanTextTertiary = Color(hex : "5A5A7A")
    
//    Category Colors, different event category gets a distinct color for visual scanning.
    static func categoryColor(for category : String) -> Color {
        switch category {
        case "celebration"  : return Color(hex: "FF6B9D")
        case "nightlife"    : return Color(hex: "A855F7")
        case "tech"         : return Color(hex: "3B82F6")
        case "heritage"     : return Color(hex: "F59E0B")
        case "religious"    : return Color(hex: "10B981")
        case "corporate"    : return Color(hex: "6366F1")
        case "community"    : return Color(hex: "EC4899")
        case "public_square": return Color(hex: "EF4444")
        case "concert"      : return Color(hex: "8B5CF6")
        case "sports"       : return Color(hex: "22C55E")
        default             : return Color(hex: "C5D2F8")
        }
    }
    
//    hex initializer, to convert hex to swift code
    init (hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var int: UInt64 = 0
        scanner.scanHexInt64(&int)
        
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 08) & 0xFF) / 255.0
        let b = Double( int        & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
