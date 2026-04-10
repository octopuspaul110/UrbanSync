//
//  EventBadge.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 10/04/2026.
//

import SwiftUI

struct EventBadge: View {
    let text    : String
    let color   : Color
    let icon    : String
    var body: some View {
        HStack(spacing : 4){
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.jakartaTitle.weight(.bold))
        }
        .padding(.horizontal,8)
        .padding(.vertical,4)
        .background(color.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(6)
    }
}

//#Preview {
//    EventBadge()
//}
