//
//  HimmerView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 16/04/2026.
//

import SwiftUI

struct ShimmerView: View {
    @State private var shimmerOffset : CGFloat = -1.0
    var body: some View {
        GeometryReader {geo in
           Rectangle()
               .fill(Color.urbanSurface)
               .overlay (
                   LinearGradient(
                    colors: [
                        Color.urbanSurface,
                        Color.urbanSurfaceLight.opacity(0.6),
                        Color.urbanSurface
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                   )
                   .offset(x : shimmerOffset * geo.size.width)
               )
               .clipped()
        }
        .onAppear{
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 2.0
            }
        }
    }
}
//Skeleton Event Card
struct EventCardSkeleton: View {
    var body: some View{
        VStack(alignment : .leading,spacing : 0) {
//            Cover image placeholder
            ShimmerView()
                .frame(height : 180)
            
//            Text placeholders
            VStack(alignment : .leading,spacing : 8){
                ShimmerView().frame(width : 80,height : 12).cornerRadius(4)
                ShimmerView().frame(height: 16).cornerRadius(4)
                ShimmerView().frame(width : 200,height : 12).cornerRadius(4)
                ShimmerView().frame(width: 150,height: 12).cornerRadius(4)
            }
            .padding(12)
        }
        .background(Color.urbanSurface)
        .cornerRadius(16)
    }
}

#Preview {
    ShimmerView()
}
