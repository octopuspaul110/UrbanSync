//
//  SplashView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI

struct SplashView: View {
//    fade in animation of the logo
    @State private var opacity : Double = 0
//    Controls the scale animation (starts small,grows to full size)
    @State private var scale : Double = 0.8
//    navigation happens when true
    @State private var isFinished = false
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            VStack(spacing : 16) {
//                App icon/logo
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors      : [.urbanAccent,.urbanCoral],
                            startPoint  : .topLeading,
                            endPoint    : .bottomTrailing
                        )
                    )
                Text("UrbanSync")
                    .font(.system(size: 36,weight : .bold,design: .rounded))
                    .foregroundColor(.urbanTextPrimary)
                
                Text("Events. Culture. Community.")
                    .font(.subheadline)
                    .foregroundColor(.urbanTextSecondary)
            }
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear{
            withAnimation(.spring(duration: 0.8)){
                opacity    = 1
                scale      = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                withAnimation{
                    isFinished = true
                }
            }
            
        }
    }
}

//#Preview {
//    SplashView()
//}
