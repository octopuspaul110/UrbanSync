//
//  ConfettiView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//
import SwiftUI

struct ConfettiParticle: Identifiable {
    let id           = UUID()
    let color        : Color
    let size         : CGFloat
    let rotation     : Double
    let spread       : Double   // spread within the cone's opening
    let velocity     : CGFloat
    let drift        : CGFloat
    let rotationSpeed: Double
}

struct ConfettiView: View {
    @Binding var isShowing: Bool

    // Popper tip — where confetti shoots from
    // Adjust these to match where the popper nozzle actually sits on screen
    let popperTipX   : CGFloat = -80
    let popperTipY   : CGFloat = 60

    // Popper base rotation in degrees
    // -20 means it points up-right, so confetti fires in that direction
    let popperAngle  : Double  = -20

    @State private var particles: [ConfettiParticle] = (0..<200).map { _ in
        ConfettiParticle(
            color        : .white,
            size         : CGFloat.random(in: 5...10),
            rotation     : Double.random(in: 0...360),
            spread       : Double.random(in: -28...28),  // cone opening width
            velocity     : CGFloat.random(in: 180...420),
            drift        : CGFloat.random(in: -40...40),
            rotationSpeed: Double.random(in: 180...540)
        )
    }

    @State private var shooting      = false
    @State private var falling       = false
    @State private var fading        = false
    @State private var popperOffset  = CGSize(width: -180, height: 180)
    @State private var popperRotation: Double = -20

    var body: some View {
        if isShowing {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                ForEach(particles) { p in
                    // Fire direction = popper angle + individual spread
                    // Popper points at -20deg so we rotate the shoot vector accordingly
                    let fireAngle = (popperAngle - 90 + p.spread) * .pi / 1

                    let shootX = shooting ? cos(fireAngle) * p.velocity : 0
                    let shootY = shooting ? sin(fireAngle) * p.velocity : 0

                    // Gravity pulls straight down, drift adds sideways scatter
                    let finalX = shootX + (falling ? p.drift : 0)
                    let finalY = shootY + (falling ? 700 : 0)

                    Rectangle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size * 1.6)
                        .rotationEffect(.degrees(
                            shooting ? p.rotation + p.rotationSpeed : p.rotation
                        ))
                        .offset(
                            x: popperTipX + finalX,
                            y: popperTipY + finalY
                        )
                        .opacity(fading ? 0 : (shooting ? 1 : 0))
                }

                // Party popper
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 220))
                    .foregroundColor(.white)
                    .offset(popperOffset)
                    .rotationEffect(.degrees(popperRotation))
            }
            .allowsHitTesting(false)
            .onAppear {
                UINotificationFeedbackGenerator().notificationOccurred(.success)

                // Popper jolts forward along its angle
                withAnimation(.easeOut(duration: 0.15)) {
                    popperOffset   = CGSize(width: -165, height: 165)
                    popperRotation = -10
                }

                // Shoot confetti from tip
                withAnimation(.easeOut(duration: 0.5)) {
                    shooting = true
                }

                // Popper recoils
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(duration: 0.5, bounce: 0.6)) {
                        popperOffset   = CGSize(width: -180, height: 180)
                        popperRotation = -10
                    }
                }

                // Gravity
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.easeIn(duration: 1.8)) {
                        falling = true
                    }
                }

                // Fade
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        fading = true
                    }
                }

                // Hide
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    isShowing = false
                }
            }
        }
    }
}

#Preview {
    ConfettiView(isShowing: .constant(true))
}
