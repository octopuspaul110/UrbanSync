//
//  ProfileSetupView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI
import CoreLocation

struct ProfileSetupView: View {
    var authVM   : AuthViewModel
    @State private var city = ""
    @State private var bio = ""
    @State private var state = ""
    @State private var isSubmitting = false
    @State private var errorMessage : String?
    @State private var isDetectingLocation : Bool = false
    @State private var locationDetected = false
    @State private var locationService = LocationService()
    
    
//    Nigerian cities for quick selection
    let popularCities = [
        ("Lagos", "Lagos"), ("Abuja", "FCT"), ("Port Harcourt", "Rivers"),
        ("Ibadan", "Oyo"), ("Kano", "Kano"), ("Enugu", "Enugu"),
        ("Benin City", "Edo"), ("Calabar", "Cross River"),
        ("Kaduna", "Kaduna"), ("Abeokuta", "Ogun")
    ]
    var body: some View {
        VStack(spacing : 24) {
            Text("Where are you?")
                .font(.jakartaTitle)
                .foregroundColor(.urbanTextPrimary)
            Text("So we can show events near you")
                .font(.jakartaBody)
                .foregroundColor(.urbanTextSecondary)
            
//            auto detect Button
            Button{
                Task {await detectCity()}
            } label : {
                HStack(spacing : 10) {
                    if isDetectingLocation {
                        ProgressView()
                            .tint(.urbanAccent)
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: locationDetected ? "checkmark.circle.fill" : "location.fill")
                            .foregroundColor(locationDetected ? .urbanMint : .urbanAccent)
                    }
                    
                    if locationDetected {
                        Text("\(city), \(state)")
                            .font(.jakartaSubheadline)
                            .foregroundColor(.urbanTextPrimary)
                    } else {
                        Text("Detect my location")
                            .font(.jakartaSubheadline)
                            .foregroundColor(.urbanAccent)
                    }
                    Spacer()
                    
                    if locationDetected {
                        Button("Change") {
                            locationDetected = false
                            city = ""
                            state = ""
                        }
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextTertiary)
                    }
                }
                .padding()
                .background(locationDetected ? Color.urbanMint.opacity(0.1) : Color.urbanSurface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(locationDetected ? Color.urbanMint.opacity(0.3) : Color.clear, lineWidth: 1)
                )
            }
            .disabled(isDetectingLocation)
            .padding(.horizontal,24)
            
//            Manual City Picker
            if !locationDetected {
                VStack(alignment: .leading){
                    Text("Or pick your city")
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextTertiary)
                        .padding(.horizontal,24)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing : 10) {
                            ForEach(popularCities,id : \.0) { c in
                                Button {
                                    city  = c.0
                                    state = c.1
                                    UIImpactFeedbackGenerator(style : .light).impactOccurred()
                                } label : {
                                    Text(c.0)
                                        .font(.jakartaSubheadline)
                                        .padding(.horizontal,16)
                                        .padding(.vertical,10)
                                        .background(city == c.0 ? .white : .urbanTextSecondary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal,24)
                    }
                }
            }
            
            VStack(alignment : .leading,spacing : 8){
                Text("Bio (optional)")
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanTextSecondary)
                
                TextField("Tell people about yourself", text : $bio, axis : .vertical)
                    .lineLimit(3...5)
                    .font(.jakartaBody)
                    .urbanField()
                    .onChange(of : bio){
                        _,newValue in
                        if newValue.count > 150 {
                            bio = String(newValue.prefix(150))}
                    }
                Text("\(bio.count)/150")
                    .font(.jakartaCaption2)
                    .foregroundColor(.urbanTextTertiary)
                    .frame(maxWidth: .infinity,alignment: .trailing)
            }
            .padding(.horizontal,24)
            
//            Error Message
            if let error = errorMessage {
                Text(error)
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanCoral)
                    .padding(.horizontal,24)
            }
            Spacer()
            
//            Complete Onboarding
            Button{
                Task {await completeOnboarding()}
            }label : {
                Text(isSubmitting ? "Setting up..." : "Start Exploring")
                    .urbanPrimaryButton(disabled : city.isEmpty)
            }
            .disabled(city.isEmpty || isSubmitting)
            .padding(.horizontal,24)
            .padding(.bottom,32)
        }
        .task {
            locationService.requestPermission()
            try? await Task.sleep(for: .milliseconds(1500))
            if locationService.currentLocation != nil {
                await detectCity()
            }
        }
    }
    private func detectCity() async {
        isDetectingLocation = true
        defer {isDetectingLocation.toggle()}
        
        if locationService.currentLocation != nil {
            locationService.requestPermission()
            locationService.startUpdating()
            
            for _ in 0..<10 {
                try? await Task.sleep(for: .milliseconds(500))
                if locationService.currentLocation != nil {
                    break
                }
            }
        }
        
        guard let coord = locationService.currentLocation else {
            errorMessage = "Could not detect location. Please select your city manually."
            return
        }
        
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        do{
            let placemarks = try await geocoder.reverseGeocodeLocation(clLocation)
            if let place = placemarks.first {
                city = place.locality ?? place.subAdministrativeArea ?? ""
                state = place.administrativeArea ?? ""
                
                if !city.isEmpty {
                    locationDetected = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } else {
                    errorMessage = "Could not determine city. please select manually."
                }
            }
        } catch {
            errorMessage = "Location detection failed. Please select manually"
        }
    }
//    Submit to backend
    private func completeOnboarding() async {
        isSubmitting = true
        errorMessage = nil
        
        defer {
            isSubmitting.toggle()
        }
        do{
            let profileBody: [String : String] = [
                "city"  : city,
                "state" : state,
                "bio"   : bio
            ]
            let _:[String:String] = try await APIClient.shared.post("/api/onboarding/profile", body: profileBody)
            let _:[String:Bool] = try await APIClient.shared.post("/api/onboarding/complete", body: [:] as [String : String])
            authVM.onboardingCompleted.toggle()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

//#Preview {
//    ProfileSetupView()
//}
