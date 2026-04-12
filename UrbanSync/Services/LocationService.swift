//
//  LocationService.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//

import Foundation
import CoreLocation
import SwiftUI


@Observable
class LocationService : NSObject,CLLocationManagerDelegate {
    
    private let manager     = CLLocationManager()
    var currentLocation     : CLLocationCoordinate2D?
    var authorizationStatus : CLAuthorizationStatus? = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last?.coordinate
        manager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse {
            startUpdating()
        }
    }
}

