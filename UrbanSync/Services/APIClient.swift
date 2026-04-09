//
//  APIClient.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import Foundation
import FirebaseAuth

enum APIError : LocalizedError {
    case invalidURL
    case noToken           // user not logged in
    case serverError(Int,String)       // HTTP status code and message
    case decodingError(Error)           // JSON response did not match expected format
    case networkError(Error)
    
//    Human readable error message shown in alerts.
    var errorDescription : String? {
        switch self {
        case .invalidURL                        : return "Invalid URL"
        case .noToken                           : return "Please login to continue"
        case .serverError(let code, let msg)    : return "Error \(code) : \(msg)"
        case .decodingError                     : return "Unexpected server response"
        case .networkError                      : return "No internet connection"
        }
    }
    
}

class APIClient {
    
    static let shared = APIClient()
    
//    Base url for all API calls.
    #if targetEnvironment(simulator)
    private let baseURL = "http://localhost:8080"
    #else
//    this becomes railway url later in production
    private let baseURL = "http://192.168.1.255:8080"  //this should be dead code for now until i run on phone
    #endif
    
//    shared URLSession with custom config
    private let session : URLSession
    
//    JSON decoder configured for backend's date format
    private let decoder : JSONDecoder = {
        let d = JSONDecoder()
//        rust backend sends date as ISO 8601 strings.
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    private let encoder : JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private init() {
        let config = URLSessionConfiguration.default
//        matches backend timeout
        config.timeoutIntervalForRequest = 30
//        cached policy when offline, refresh when online
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }
    
//    Get current firebase jwt token, called before every api request, expires every hour. sdk automatically refreshes them.
    private func getToken() async throws -> String {
        guard let user = Auth.auth().currentUser else {
            throw APIError.noToken
        }
//        use cached token if not expired
        return try await user.getIDToken(forcingRefresh: false)
    }
    
//    Core request method
//    Every public method (get, post,put, delete) calls this,builds urlrequest, adds headers, sends it and decode response.
    private func request<T : Decodable>(
        method          : String,
        path            : String,
        body            : (any Encodable)? = nil,
        authenticated   : Bool = true
    ) async throws -> T {
//        build full URL from base + path.
        guard let url = URL(string : baseURL + path) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url : url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
//        Add Firebase JWT token for authenticated endpoints.
        if authenticated {
            let token = try await getToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
//        Encode request body as JSon if provided
        if let body = body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        
//        Send the request and await response.
        let (data, response) : (Data, URLResponse)
        do {
            (data,response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        
//        check HTTP status code
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError(0,"Invalid response")
        }
        
//        200 success, everything else is error.
        guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to extract the error message from the JSON body.
            let errorMsg = (try? JSONSerialization.jsonObject(with: data) as? [String: Any])?["error"]
                .flatMap { ($0 as? [String: Any])?["message"] as? String }
                ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMsg)
        }
        
//        decode into existed Swift type.
        do {
            return try decoder.decode(T.self,from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
//    public convenience methods
    func get<T:Decodable>(
        _ path          : String,
        authenticated   : Bool = true
    ) async throws -> T {
        try await request(
            method          : "GET",
            path            : path,
            authenticated   : authenticated
        )
    }
    
    func post<T:Decodable>(
        _ path          : String,
        body            : any Encodable,
        authenticated   : Bool = true
    ) async throws -> T {
        try await request(
            method          : "POST",
            path            : path,
            body            : body,
            authenticated   : authenticated
        )
    }
    
    func put<T : Decodable>(
        _ path          : String,
        body            : any Encodable
    ) async throws -> T {
        try await request(
            method: "PUT",
            path: path,
            body: body
        )
    }
    
    func patch<T : Decodable>(
        _ path          : String,
        body            : any Encodable
    ) async throws -> T {
        try await request(
            method          : "PATCH",
            path            : path,
            body            : body
        )
    }
    
    func delete(
        _ path : String
    ) async throws {
        let _: EmptyResponse = try await request(
            method      : "DELETE",
            path        : path
        )
    }
}

struct AnyEncodable : Encodable {
    private let _encode : (Encoder) throws -> Void
    init(_ wrapped : any Encodable) {
        _encode = wrapped.encode
    }
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

struct EmptyResponse : Decodable {
    
}

