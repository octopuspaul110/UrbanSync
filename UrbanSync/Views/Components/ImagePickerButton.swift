//
//  ImagePickerButton.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 16/04/2026.
//

import SwiftUI
import PhotosUI

struct ImagePickerButton<Label : View>: View {
    @Binding var selectedImageData : Data?
    @ViewBuilder var label : () -> Label
    
    @State private var pickerItem : PhotosPickerItem?
    var body: some View {
        PhotosPicker(selection: $pickerItem, matching : .images) {
            label()
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
}
