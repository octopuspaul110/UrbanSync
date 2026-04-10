//
//  GlowingProgressBar.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI

struct GlowingProgressBar: View {
//    Progress from 0.0 to 1.0
    let progress : Double
//    The color of the glow and fill
    
    @State private var glowIntensity : Double = 0.3
    
    private var barColor : Color {
        if progress < 0.5 {return .urbanMint}
        if progress < 0.8 {return .urbanGold}
        return .urbanCoral
    }
//    Gradient from start color to current progress color.
    private var barGradient : LinearGradient {
        if progress < 0.5 {
            return LinearGradient(
                colors: [.urbanMint.opacity(0.6),.urbanMint],
                startPoint: .leading,
                endPoint: .trailing)
        } else if progress < 0.8{
            return LinearGradient(
                colors: [.urbanMint,.urbanGold],
                startPoint: .leading,
                endPoint: .trailing)
        } else {
            return LinearGradient(
                colors: [.urbanMint, .urbanGold, .urbanCoral],
                startPoint: .leading,
                endPoint: .trailing)
        }
    }
    var body: some View {
        GeometryReader{ geo in
            ZStack(alignment : .leading){
//                Background Track
                Capsule()
                    .fill(Color.urbanSurfaceLight)
                    .frame(height: 6)
                
//                Filled Progress
                Capsule()
                    .fill(barGradient)
                    .frame(
                        width: max(geo.size.width * progress,6),
                        height: 6
                    )
//                Glow effect on leading edge.
                    .shadow(color: barColor.opacity(glowIntensity),radius: progress > 0.8 ? 12 : 8)
                    .shadow(color: barColor.opacity(glowIntensity * 0.5),radius: progress > 0.8 ? 20 : 14)
            }
        }
        .frame(height : 6)
        .onAppear{
//            pulse speed increases with progress
            let pulseDuration:TimeInterval = progress > 0.8 ? 0.8 : (progress > 0.5 ? 1.5 : 2.5)
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses:true)){
                glowIntensity = progress > 0.8 ? 1.0 : 0.7
            }
        }
    }
}

//#Preview {
//    GlowingProgressBar()
//}
