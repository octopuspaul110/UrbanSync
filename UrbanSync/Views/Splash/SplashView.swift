//
//  SplashView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//
import SwiftUI

struct SplashView: View {
    @State private var opacity      : Double  = 0
    @State private var scale        : CGFloat = 0.85
    @State private var glowOpacity  : Double  = 0
    @State private var isFinished   : Bool    = false
    
    @State private var glowScale    : CGFloat = 1
    @State private var glowBlur     : CGFloat = 60
    @State private var isBreathing  : Bool    = false
    @State private var ringScale1   : CGFloat = 0.2
    @State private var ringScale2   : CGFloat = 0.2
    @State private var ringOpacity1 : Double  = 0
    @State private var ringOpacity2 : Double  = 0

    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()

            // Outer ripple ring 1
            Circle()
                .stroke(Color.urbanAccent.opacity(0.15), lineWidth: 1)
                .frame(width: 320, height: 320)
                .scaleEffect(ringScale1)
                .opacity(ringOpacity1)

            // Outer ripple ring 2 — offset phase
            Circle()
                .stroke(Color.urbanAccentEnd.opacity(0.1), lineWidth: 1)
                .frame(width: 260, height: 260)
                .scaleEffect(ringScale2)
                .opacity(ringOpacity2)

            // Core glow blob
            ZStack {
                // Outer soft bloom
                Circle()
                    .fill(
                        RadialGradient(
                            colors     : [
                                Color.urbanAccent.opacity(0.34),
                                Color.urbanAccentEnd.opacity(0.15),
                                .clear
                            ],
                            center     : .center,
                            startRadius: 0,
                            endRadius  : 160
                        )
                    )
                    .frame(width: 320, height: 320)
                    .scaleEffect(glowScale)
                    .blur(radius: glowBlur)
                    .opacity(glowOpacity)

                // Inner bright core
                Circle()
                    .fill(
                        RadialGradient(
                            colors     : [
                                Color.urbanAccent.opacity(0.6),
                                Color.urbanAccent.opacity(0.1),
                                .clear
                            ],
                            center     : .center,
                            startRadius: 0,
                            endRadius  : 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isBreathing ? 1.15 : 0.9)
                    .blur(radius: isBreathing ? 18 : 28)
                    .opacity(glowOpacity * 0.8)
            }

            VStack(spacing: 0) {
                Spacer()
                // Netflix-style overlaid wordmark
                ZStack {
                    // Back copy — outlined, offset, dimmer
                    Text("UrbanSync")
                        .font(.custom("PlusJakartaSans-Bold", size: 55))
                        .foregroundColor(.clear)
                        .overlay(
                            Text("UrbanSync")
                                .font(.custom("PlusJakartaSans-Bold", size: 55))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors    : [.entryColor, Color.urbanAccentEnd.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint  : .bottomTrailing
                                    )
                                )
                        )
                        .offset(x: 3, y: 3.5)

                    // Front copy — full gradient
                    Text("UrbanSync")
                        .font(.custom("PlusJakartaSans-Bold", size: 55))
                        .foregroundStyle(
                            LinearGradient(
                                colors    : [.entryColor, Color(hex: "f0a050"), Color.urbanAccentEnd],
                                startPoint: .topLeading,
                                endPoint  : .bottomTrailing
                            )
                        )
                }
                
                Spacer()
                // Tagline
                HStack(spacing: 8) {
                    Text("EVENTS")
                    Circle()
                        .fill(Color.urbanCoral.opacity(0.6))
                        .frame(width: 4, height: 4)
                    Text("CULTURE")
                    Circle()
                        .fill(Color.urbanCoral.opacity(0.6))
                        .frame(width: 4, height: 4)
                    Text("COMMUNITY")
                }
                .font(.custom("PlusJakartaSans-Bold", size: 8.7))
                .foregroundColor(.white)
                .kerning(2.5)
                .padding(.top, 12)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.3)) {
                opacity = 1
                scale   = 1
            }
            withAnimation(.easeOut(duration: 1.2)) {
                glowOpacity = 1
                glowScale   = 3.0
                glowBlur    = 50
            }
            // Breathing pulse — continuous
            withAnimation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
            ) {
                isBreathing = true
                glowScale   = 1.3
            }
            // Ring 1 — expands and fades out, repeats
            startRing1()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startRing2()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeIn(duration: 0.4)) {
                opacity     = 0
                glowOpacity = 0
            }
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFinished = true
            }
            }
        }
    }
    
    private func startRing1() {
        ringScale1   = 0.6
        ringOpacity1 = 0.6
        withAnimation(.easeOut(duration: 1.8)) {
            ringScale1   = 1.4
            ringOpacity1 = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            startRing1()
        }
    }

    private func startRing2() {
        ringScale2   = 0.6
        ringOpacity2 = 0.5
        withAnimation(.easeOut(duration: 1.8)) {
            ringScale2   = 1.4
            ringOpacity2 = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            startRing2()
        }
    }
}

#Preview {
    SplashView()
}
