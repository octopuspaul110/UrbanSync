//
//  InterestPickerView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 09/04/2026.
//

import SwiftUI

struct InterestPickerView: View {
    var onComplete : () -> Void
    @State private var selected : Set<String> = []
    @State private var isSubmitting = false
    
    @State private var errorMessage: String?
    
//    The 10 categories matching backend event_category ENUM.
    let categories : [(id:String,name : String,icon : String)] = [
        ("celebration","Celebrations","party.popper.fill"),
        ("nightlife", "Nightlife", "moon.stars.fill"),
        ("tech", "Tech", "laptopcomputer"),
        ("heritage", "Heritage", "building.columns.fill"),
        ("religious", "Religious", "hands.and.sparkles.fill"),
        ("corporate", "Corporate", "briefcase.fill"),
        ("community", "Community", "person.3.fill"),
        ("public_square", "Public", "megaphone.fill"),
        ("concert", "Concerts", "music.mic"),
        ("sports", "Sports", "sportscourt.fill"),
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing : 24){
            Text("What are you into?")
                .font(.jakartaTitle)
                .foregroundColor(.urbanTextPrimary)
            Text("Pick at least 3 to personalize your feed")
                .foregroundColor(.urbanTextSecondary)
            
//            Category Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16){
                    ForEach(categories,id : \.id) {
                        cat in
                        categoryCard(cat)
                    }
                }
                .padding(.horizontal,24)
            }
            
//            Continue Button
            if let error = errorMessage {
                Text(error)
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanCoral)
                    .transition(.opacity) // Smooth appearance
            }
            
            Button {
                Task{await submitInterests()}
            } label : {
                Text("Continue (\(selected.count) selected)")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selected.count >= 3 ? Color.urbanAccent : Color.urbanSurfaceLight)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(selected.count < 3 || isSubmitting)
            .padding(.horizontal,24)
            .padding(.bottom,32)
        }
    }
//    Category Card Component
    @ViewBuilder
    private func categoryCard(_ cat : (id:String, name: String,icon:String)) -> some View {
        
        let isSelected = selected.contains(cat.id)
        let catColor = Color.categoryColor(for: cat.id)
        
        Button {
            withAnimation(.spring(duration : 0.3)) {
                if isSelected {selected.remove(cat.id)}
                else {selected.insert(cat.id)}
            }
//            Light haptic tap
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label : {
            VStack(spacing : 12) {
                Image(systemName: cat.icon)
                    .font(.system(size : 28))
                    .foregroundColor(isSelected ? catColor : .urbanTextSecondary)
                Text(cat.name)
                    .font(.jakartaSubheadline.weight(.medium))
                    .foregroundColor(isSelected ? .urbanTextPrimary : .urbanTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical,20)
            .background(isSelected ? catColor.opacity(0.15) : Color.urbanSurface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? catColor : Color.clear,lineWidth: 2)
            )
        }
    }
    

//    Submit to backend
    private func submitInterests() async {
        isSubmitting = true
        errorMessage = nil
        defer {isSubmitting = false}
        do {
            let body = ["categories" : Array(selected)]
            let _ : [String : String] = try await APIClient.shared.post("/api/onboarding/interests", body: body)
            onComplete()
        }catch {
            errorMessage = error.localizedDescription
        }
    }
}

//#Preview {
//    InterestPickerView()
//}
