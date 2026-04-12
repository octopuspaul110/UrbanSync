//
//  CreateEventViewModel.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//

import Foundation
import PhotosUI

struct CreateEventPayload: Encodable {
    let title                   : String
    let description             : String
    let category                : String
    let visibility              : String
    let venue_name              : String
    let address                 : String
    let city                    : String
    let state                   : String
    let start_time              : String
    let end_time                : String
    let dress_code              : String
    let gifting_enabled         : Bool
    let max_capacity            : Int?
    let is_paid                 : Bool?
    let cover_image_url         : String?
    let metadata                : [String: String]?
    let creator_name            : String?
    let recurrence              : String
    let recurrence_days         : [Int]?
    let recurrence_interval     : Int?
    let recurrence_end_date     : String?
    
}

@Observable
class CreateEventViewModel {
//    For fields
    var title                   = ""
    var description             = ""
    var category                = "celebration"
    var visibility              = "public"
    var VenueName               = ""
    var address                 = ""
    var city                    = ""
    var state                   = ""
    var startDate               = Date().addingTimeInterval(86400) // Default : tomorrow
    var endDate                 = Date().addingTimeInterval(86400 + 3600 * 4) // 4 hours after start
    var dressCode               = ""
    var giftingEnabled          = false
    var maxCapacity             : Int?
    var isPaid                  = false
    var coverImageUrl           : String?           // set after Cloudinary upload
    var metadata                : [String: String]?
    var selectedImage           : UIImage?
    var isUploadingImage        = false
    var creatorName             : String?
    var recurrence              = "none"
    var recurrenceDays          : [Int] = []
    var recurrenceInterval      = 1
    var recurrenceEndDate       : Date? = nil
    
    var createdJoinCode         : String?
    var createdPrivateJoinCode  : String?
    var createdSlug             : String?
    
    
//    State
    var isSubmitting    : Bool = false
    var errorMessage    : String?
    var createdEventId  : UUID?
    
    func createEvent() async -> Bool {
        isSubmitting = true
        errorMessage = nil
        
        defer{ isSubmitting = false }
        
        do {
            let payload = CreateEventPayload(
                title               : title,
                description         : description,
                category            : category,
                visibility          : visibility,
                venue_name          : VenueName,
                address             : address,
                city                : city,
                state               : state,
                start_time          : ISO8601DateFormatter().string(from: startDate),
                end_time            : ISO8601DateFormatter().string(from: endDate),
                dress_code          : dressCode,
                gifting_enabled     : giftingEnabled,
                max_capacity        : maxCapacity,
                is_paid             : isPaid,
                cover_image_url     : coverImageUrl,
                metadata            : metadata!.isEmpty ? nil : metadata,
                creator_name        : creatorName,
                recurrence          : recurrence,
                recurrence_days     : recurrence == "none" ? nil : recurrenceDays.isEmpty ? nil : recurrenceDays,
                recurrence_interval : recurrence == "none" ? nil : recurrenceInterval,
                recurrence_end_date : recurrence == "none" ? nil : recurrenceEndDate.map { ISO8601DateFormatter().string(from: $0) }
            )
            
            let response : CreateEventResponse = try await APIClient.shared.post(
                "/api/events",
                body: payload
            )
            createdEventId          = response.id
            createdJoinCode         = response.joinCode
            createdPrivateJoinCode  = response.privateJoinCode
            createdSlug             = response.slug
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func uploadCoverImage(_ image: UIImage) async {
        isUploadingImage = true
        defer { isUploadingImage = false }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let cloudName  = "YOUR_CLOUD_NAME"
        let uploadPreset = "YOUR_UNSIGNED_PRESET"
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"cover.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONDecoder().decode(CloudinaryResponse.self, from: data)
            coverImageUrl = json.secure_url
        } catch {
            errorMessage = "Image upload failed"
        }
    }

    struct CloudinaryResponse: Decodable {
        let secure_url: String
    }
}

