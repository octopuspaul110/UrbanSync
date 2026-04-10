//
//  OnboardingContainerView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    var authVM: AuthViewModel
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            VStack(spacing : 0) {
//                Progress Bar
//                shows which step the user is on
                HStack(spacing : 8){
                    ForEach(0..<2){step in
                        Capsule()
                            .fill(step <= currentStep ? Color.urbanAccent : Color.urbanSurfaceLight)
                            .frame(height : 4)
                    }
                }
                .padding(.horizontal,24)
                .padding(.top,16)
                
//                Step Content
                TabView(selection : $currentStep){
                    InterestPickerView(onComplete : {currentStep = 1})
                        .tag(0)
                    ProfileSetupView(authVM : authVM)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut,value: currentStep)
            }
        }
    }
}

//#Preview {
//    OnboardingContainerView()
//}
