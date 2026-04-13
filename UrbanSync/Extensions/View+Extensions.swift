//
//  View+Extensions.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//

import SwiftUI
 
extension View {
 
    // \u2500\u2500 Card Style \u2500\u2500
    // Applies the standard UrbanSync card look: dark surface, rounded corners, shadow.
    // Usage: SomeView().urbanCard()
    func urbanCard() -> some View {
        self
            .background(Color.urbanSurface)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }
 
    // \u2500\u2500 Form Field Style \u2500\u2500
    // Standard styling for text inputs across the app.
    // Usage: TextField("...", text: $value).urbanField()
    func urbanField() -> some View {
        self
            .font(.jakartaBody)
            .padding()
            .background(Color.urbanSurface)
            .cornerRadius(12)
            .foregroundColor(.urbanTextPrimary)
    }
 
    // \u2500\u2500 Primary Button Style \u2500\u2500
    // Usage: Button("Buy") { }.urbanPrimaryButton()
    func urbanPrimaryButton(disabled: Bool = false) -> some View {
        self
            .font(.jakarta(.semiBold, size: 17))
            .frame(maxWidth: .infinity)
            .padding()
            .background(disabled ? Color.urbanSurfaceLight : Color.urbanAccent)
            .foregroundColor(.white)
            .cornerRadius(14)
    }
 
    // \u2500\u2500 Secondary Button Style \u2500\u2500
    // Outline button with border, no fill.
    func urbanSecondaryButton() -> some View {
        self
            .font(.jakarta(.medium, size: 15))
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.clear)
            .foregroundColor(.urbanTextPrimary)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.urbanSurfaceLight, lineWidth: 1))
    }
 
    // \u2500\u2500 Conditional Modifier \u2500\u2500
    // Apply a modifier only when a condition is true.
    // Usage: Text("...").if(isHighlighted) { $0.foregroundColor(.red) }
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) }
        else { self }
    }
}
