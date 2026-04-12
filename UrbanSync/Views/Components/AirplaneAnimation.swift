//
//  AirplaneAnimation.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//

import SwiftUI

struct AirplaneAnimation: View {
    @Binding var isShowing      : Bool
    @Binding var eventName      : String
    @Binding var joinCode       : String
    @Binding var privateJoinCode: String
    @Binding var slug           : String
    var onComplete              : () -> Void

    @State private var planeOffset   : CGSize = .zero
    @State private var planeOpacity  : Double = 1.0
    @State private var planeScale    : CGFloat = 0.5
    @State private var planeRotation : Double = 0.0
    @State private var showCheckmark : Bool = false
    @State private var trailOpacity  : Double = 0.6
    @State private var checkRotation : Double = -180
    @State private var checkOpacity  : Double = 0
    @State private var checkScale    : CGFloat = 0.3
    @State private var copiedJoin    : Bool = false
    @State private var copiedPrivate : Bool = false

    var body: some View {
        if isShowing {
            ZStack {
                Color.urbanBackground.opacity(0.92).ignoresSafeArea()

                // Trail
                ForEach(0..<8, id: \.self) { i in
                    let trailAlpha = trailOpacity * Double(8 - i) / 8.0
                    let size = CGFloat(6 - i / 2)
                    Circle()
                        .fill(Color.urbanAccent.opacity(trailAlpha))
                        .frame(width: size, height: size)
                        .offset(
                            x: planeOffset.width * CGFloat(i) / 10.0,
                            y: planeOffset.height * CGFloat(i) / 10.0
                        )
                }

                // Airplane
                Text("\u{2708}\u{FE0F}")
                    .font(.system(size: 100))
                    .scaleEffect(planeScale)
                    .rotationEffect(.degrees(planeRotation))
                    .offset(planeOffset)
                    .opacity(planeOpacity)

                // Success content
                if showCheckmark {
                    VStack(spacing: 20) {

                        // Checkmark — rotates into position
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(.urbanMint)
                            .rotationEffect(.degrees(checkRotation))
                            .scaleEffect(checkScale)
                            .opacity(checkOpacity)

                        Text("Event Created!")
                            .font(.jakartaTitle2)
                            .foregroundColor(.white)

                        // Event name with gradient
                        HStack(spacing: 6) {
                            Text(eventName)
                                .font(.title2.weight(.bold))
                                .overlay(
                                    LinearGradient(
                                        colors: [.green, .blue, .purple, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .mask(
                                        Text(eventName)
                                            .font(.title2.weight(.bold))
                                    )
                                )
                            Text("is now live 🎉")
                                .font(.jakartaBody)
                                .foregroundColor(.urbanTextSecondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                        // Join codes
                        VStack(spacing: 10) {
                            copyCodeButton(
                                label   : "Join Code",
                                code    : joinCode,
                                icon    : "person.badge.key.fill",
                                copied  : $copiedJoin
                            )
                            copyCodeButton(
                                label   : "Private Join Code",
                                code    : privateJoinCode,
                                icon    : "lock.fill",
                                copied  : $copiedPrivate
                            )
                        }
                        .padding(.horizontal, 24)

                        // Share button
                        ShareLink(item: URL(string: slug)!) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Event")
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                // Plane flies up
                withAnimation(.easeInOut(duration: 1.0)) {
                    planeOffset   = CGSize(width: 250, height: -420)
                    planeRotation = -30
                    planeScale    = 1
                }

                // Plane fades out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        planeOpacity = 0
                        trailOpacity = 0
                    }
                }

                // Show checkmark container
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    showCheckmark = true

                    // Checkmark rotates and scales into position
                    withAnimation(.spring(duration: 0.6, bounce: 0.4)) {
                        checkRotation = 0
                        checkScale    = 1
                        checkOpacity  = 1
                    }
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
        }
    }

    @ViewBuilder
    private func copyCodeButton(
        label  : String,
        code   : String,
        icon   : String,
        copied : Binding<Bool>
    ) -> some View {
        Button {
            UIPasteboard.general.string = code
            withAnimation(.spring(duration: 0.2)) {
                copied.wrappedValue = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { copied.wrappedValue = false }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: copied.wrappedValue ? "checkmark" : icon)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.urbanTextSecondary.opacity(0.5))
                    Text(copied.wrappedValue ? "Copied!" : code)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.urbanTextSecondary)
                }

                Spacer()

                Image(systemName: "doc.on.doc")
                    .font(.system(size: 13))
                    .foregroundColor(.urbanTextSecondary.opacity(0.4))
            }
            .padding(12)
            .background(Color.urbanTextSecondary.opacity(0.08))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        copied.wrappedValue ? Color.urbanCoral.opacity(0.6) : Color.urbanTextSecondary.opacity(0.1),
                        lineWidth: 0.5
                    )
            )
        }
    }
}

//#Preview {
//    AirplaneAnimation(
//        isShowing       : .constant(true),
//        eventName       : .constant("Lagos Dev Summit 2026"),
//        joinCode        : .constant("ABC123"),
//        privateJoinCode : .constant("XYZ784"),
//        onComplete      : {}
//    )
//}

