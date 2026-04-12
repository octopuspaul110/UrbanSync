//
//  AirplaneAnimation.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//

import SwiftUI

struct AirplaneAnimation: View {
    @Binding var isShowing : Bool
    @Binding var eventName : String
    var onComplete : () -> Void
    
    @State private var planeOffset  : CGSize = .zero
    @State private var planeOpacity : Double = 1.0
    @State private var planeScale   : CGFloat = 1.0
    @State private var planeRotation: Double = 0.0
    @State private var showCheckmark: Bool   = false
    @State private var trailOpacity : Double = 0.6
    var body: some View {
        if isShowing {
            ZStack {
                Color.urbanBackground.opacity(0.9).ignoresSafeArea()
                ForEach(0..<8,id: \.self) { i in
                        Circle()
                        .fill(Color.urbanAccent.opacity(trailOpacity * Double(8 - i) / 8.0))
                        .frame(width: CGFloat(6 - i / 2), height: CGFloat(6 - i / 2))
                        .offset(
                            x: planeOffset.width * CGFloat(i) / 10.0,
                            y: planeOffset.height * CGFloat(i) / 10.0
                        )
                }
//                Airplane
                Text("\u{2708}\u{FE0F}")
                    .font(.system(size: 60))
                    .scaleEffect(planeScale)
                    .rotationEffect(.degrees(planeRotation))
                    .offset(planeOffset)
                    .opacity(planeOpacity)
//                Success checkmark (appears after plane lands)
                if showCheckmark {
                    VStack(spacing : 16){
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.urbanMint)
                        Text("Event Created!")
                            .font(.jakartaTitle2)
                            .foregroundColor(.urbanTextPrimary)
                        Text("Yay!!! ")
                            .font(.jakartaBody)
                            .foregroundColor(.urbanTextPrimary)
                        +
                        Text("\(eventName)")
                            .font(.jakartaTitle.weight(.bold))
                            .foregroundColor(.urbanAccent)
                        +
                        Text(" is now live 🎉")
                            .font(.jakartaBody)
                            .foregroundColor(.urbanTextPrimary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .onAppear {
//              Airplane flies to top-right corner
                withAnimation(.easeInOut(duration: 1.0)){
                    planeOffset     = CGSize(width: 150, height: -300)
                    planeRotation   = -30
                    planeScale      = 0.5
                }
                
//              Airplane fades out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.3)){
                        planeOpacity = 0
                        trailOpacity = 0
                    }
                }
                    
//              success checkmark
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2){
                    withAnimation(.spring(duration : 0.5)){
                        showCheckmark = true
                    }
//                    haptic for success notifs
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                
//              Auto-dismiss after 2.5 seconds total.
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5){
                    withAnimation{ isShowing = false}
                    onComplete()
                }
            }
        }
    }
}

//#Preview {
//    AirplaneAnimation()
//}
