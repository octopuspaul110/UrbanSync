//
//  USer.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import Foundation

struct User : Codable,Identifiable {
    let id                  : UUID
    let name                : String
    let email               : String
    let phone               : String?
    let bio                 : String?
    let profileImageUrl     : String?
    let city                : String?
    let state               : String?
    let emailVerified       : Bool
    let onBoardingCompleted : Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, bio, city, state
        case profileImageUrl     = "profile_image_url"
        case emailVerified       = "email_verified"
        case onBoardingCompleted = "Onboarding_completed"
    }
}


