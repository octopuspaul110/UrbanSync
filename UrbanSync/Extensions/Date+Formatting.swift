//
//  Date+Formatting.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import Foundation

extension Date {
//    "Sat, Jun 21"
    var shortFormatted : String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM dd"
        return f.string(from: self)
    }
//    "Saturday, June 21, 2025 at 10:00 PM"
    var fullFormatted : String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy 'at' h:mm a"
        return f.string(from: self)
    }
//    "10:00 PM" used for start/end times.
    var timeOnly : String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: self)
    }
//    "in 3 days" / "in 2 hours" / "happening now" - used for countdown.
    var relativeFormatted : String {
        let now = Date()
        let interval = self.timeIntervalSince(now)
        
        if interval < 0 { return "ended" }
        if interval < 3600 { return "in \(Int(interval / 60)) min" }
        if interval < 86400 { return "in \(Int(interval / 3600)) hours" }
        return "in \(Int(interval / 86400)) days"
    }
    
//    Progress from creation to start (0.0 to 1.0)
//    Used by GlowingProgressBar component.
    func progressUntilStart(createdAt : Date) -> Double {
        let total = self.timeIntervalSince(createdAt)
        let elapsed = Date().timeIntervalSince(createdAt)
        guard total > 0 else {return 1.0}
        return min(max(elapsed / total,0),1.0)
    }
}
