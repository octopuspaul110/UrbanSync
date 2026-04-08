//
//  UrbanSyncApp.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 08/04/2026.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct UrbanSyncApp: App {
    
    init() {
        FirebaseApp.configure()
        NotificationService.shared.requestPermission()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
