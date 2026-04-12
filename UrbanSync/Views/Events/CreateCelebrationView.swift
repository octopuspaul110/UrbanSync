//
//  CreateCelebrationView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//

import SwiftUI
import PhotosUI

enum CelebrationKind : String,CaseIterable {
    case wedding    = "Wedding"
    case birthday   = "Birthday"
    case owambe     = "Owambe"
}

struct CreateCelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CreateEventViewModel()
    @State private var kind: CelebrationKind = .wedding
    @State private var showImagePicker: Bool = false
    @State private var galleryImages: [UIImage] = []
    
//    Wedding metadata
    @State private var brideFamilyDress = ""
    @State private var groomFamilyDress = ""
    @State private var asoebiColors     = ""
    @State private var theme            = ""
    @State private var couplesStory     = ""
    
//    Birthday metadata
    @State private var birthdayTheme    : String = ""
    @State private var specialRequest   : String = ""
    
//    owambe metadata
    @State private var owambeTheme      : String = ""
    @State private var owambeAsoebi     : String = ""
    
    @State private var selectedCoverItem: PhotosPickerItem?
    @State private var coverImage: UIImage?
    @State private var selectedGalleryItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing : 20) {
//                        Kind picker
                        Picker("Celebration type",selection: $kind){
                            ForEach(CelebrationKind.allCases, id: \.self) {
                                k in
                                Text(k.rawValue).tag(k)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
//                        coverImageSection
                        coverImageSection
                        
//                        Gallery images (wedding pre-shoot etc.)
                        gallerySection
                        
//                        common fields
                        formField(title : "Event Title") {
                            TextField("e.g Mr & Mrs John Wedding",text : $vm.title)
                        }
                        
                        formField(title : "Venue Name"){
                            TextField("e.g Eko Hotel, Victoria Island",text : $vm.VenueName)
                        }
                        
                        formField(title : "City"){
                            TextField("Lagos",text : $vm.city)
                        }
                        
                        formField(title : "start Date & Time"){
                            DatePicker("",selection: $vm.startDate,in: Date()...)
                                .tint(.urbanAccent)
                        }
                        
                        formField(title : "End Date & Time"){
                            DatePicker("",selection: $vm.endDate,in: vm.startDate...)
                                .tint(.urbanAccent)
                        }
                        
                        formField(title : "Dress Code"){
                            TextField("e.g White shirt, Ankara",text : $vm.city)
                        }
                        
                        Toggle("Enable Gifting", isOn: $vm.giftingEnabled)
                            .tint(.urbanAccent)
                            .foregroundColor(.urbanTextPrimary)
                            .padding()
                            .background(Color.urbanSurface)
                            .cornerRadius(12)
                        
//                        Kind-specific metadata fields
                        switch kind {
                        case .wedding:
                            weddingMetadata
                        case .birthday:
                            birthdayMetadata
                        case .owambe:
                            owambeMetadata
                        }
                        
//                        Error
                        if let error = vm.errorMessage {
                            Text(error)
                                .foregroundColor(.urbanCoral)
                                .padding()
                        }
//                        Submit
                        Button{
                            Task {
                                buildMetadata()
                                vm.category = kind == .wedding ? "celebration" : kind == .owambe ? "celebration" : "celebration"
                                let success = await vm.createEvent()
                                if success { dismiss()}
                            }
                        } label :{
                            Text(vm.isSubmitting ? "Creating..." : "Create \(kind.rawValue)")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(vm.title.isEmpty ? Color.urbanSurfaceLight : Color.urbanAccent)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        .disabled(vm.title.isEmpty || vm.isSubmitting)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New \(kind.rawValue)")
            .toolbar {
                ToolbarItem(placement : .cancellationAction){
                    Button("cancel"){
                        dismiss()
                    }
                    .foregroundColor(.urbanTextPrimary)
                }
            }
        }
    }
    
    private var coverImageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cover Photo")
                .font(.caption)
                .foregroundColor(.urbanTextPrimary)

            PhotosPicker(selection: $selectedCoverItem, matching: .images) {
                if let coverImage {
                    Image(uiImage: coverImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.urbanSurface)
                            .frame(height: 180)
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.urbanTextTertiary)
                            Text("Add cover photo")
                                .font(.jakartaSubheadline)
                                .foregroundColor(.urbanTextTertiary)
                        }
                    }
                }
            }
            .onChange(of: selectedCoverItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        coverImage = uiImage
                        await vm.uploadCoverImage(uiImage)
                    }
                }
            }

            if vm.isUploadingImage {
                HStack(spacing: 8) {
                    ProgressView().tint(.urbanAccent)
                    Text("Uploading...").font(.caption).foregroundColor(.urbanTextSecondary)
                }
            }
        }
    }
    
//    Gallery
    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kind == .wedding ? "Pre-wedding Photos" : "Gallery")
                .font(.caption)
                .foregroundColor(.urbanTextPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(galleryImages, id: \.self) { img in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    PhotosPicker(
                        selection: $selectedGalleryItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.urbanSurface)
                                .frame(width: 100, height: 100)
                            Image(systemName: "plus")
                                .foregroundColor(.urbanTextTertiary)
                                .font(.system(size: 24))
                        }
                    }
                    .onChange(of: selectedGalleryItems) { _, newItems in
                        Task {
                            var images: [UIImage] = []
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    images.append(uiImage)
                                }
                            }
                            galleryImages = images
                        }
                    }
                }
            }
        }
    }
//    Wedding metadata fields
    private var weddingMetadata : some View {
        VStack(spacing : 16) {
            Text("Wedding Details")
                .font(.jakartaSubheadline.weight(.medium))
                .foregroundColor(.urbanTextSecondary)
                .frame(maxWidth: .infinity,alignment : .leading)
            formField(title : "Our Story") {
                TextField("A story about how you met...",text: $couplesStory)
            }
            formField(title : "Theme") {
                TextField("e.g Royal Garden, Dark Plum",text: $theme)
            }
            formField(title: "Bride's Family Dress") {
                TextField("e.g Coral Ankara", text: $brideFamilyDress)
            }
            formField(title: "Groom's Family Dress") {
                TextField("e.g Navy Blue Agbada", text: $groomFamilyDress)
            }
            formField(title: "Aso-Ebi Colors") {
                TextField("e.g #C41E3A, #FFD166", text: $asoebiColors)
            }
        }
    }
//    Birthday metadata fields
    private var birthdayMetadata : some View {
        VStack(spacing: 16) {
            Text("Birthday Details")
                .font(.jakartaSubheadline.weight(.medium))
                .foregroundColor(.urbanTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            formField(title: "Party Theme") {
                TextField("e.g Neon Glow, Black & Gold", text: $birthdayTheme)
            }
            formField(title: "Special Requests") {
                TextField("Anything guests should know", text: $specialRequest, axis: .vertical)
                    .lineLimit(3...5)
            }
        }
    }
//    Owambe metadata fields
    private var owambeMetadata: some View {
        VStack(spacing: 16) {
            Text("Owambe Details")
                .font(.jakartaSubheadline.weight(.medium))
                .foregroundColor(.urbanTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            formField(title: "Theme") {
                TextField("e.g All White, Ankara Glam", text: $owambeTheme)
            }
            formField(title: "Aso-Ebi") {
                TextField("e.g Gold and Green", text: $owambeAsoebi)
            }
        }
    }
    // MARK: - Build metadata dict before submitting
        private func buildMetadata() {
            switch kind {
            case .wedding:
                vm.metadata = [
                    "Our Story"          : couplesStory,
                    "theme"              : theme,
                    "bride_family_dress" : brideFamilyDress,
                    "groom_family_dress" : groomFamilyDress,
                    "aso_ebi_colors"     : asoebiColors
                ].filter { !$0.value.isEmpty }

            case .birthday:
                vm.metadata = [
                    "theme"           : birthdayTheme,
                    "special_requests": specialRequest
                ].filter { !$0.value.isEmpty }

            case .owambe:
                vm.metadata = [
                    "theme"  : owambeTheme,
                    "aso_ebi": owambeAsoebi
                ].filter { !$0.value.isEmpty }
            }
        }
    @ViewBuilder
    private func formField<Content : View>(title : String, @ViewBuilder content : () -> Content) -> some View {
        Text(title)
            .font(.caption)
            .foregroundColor(.urbanTextPrimary)
        content()
            .padding()
            .background(Color.urbanSurface)
            .cornerRadius(12)
            .foregroundColor(.urbanTextPrimary)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onPick: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
                parent.onPick(img)
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    CreateCelebrationView()
}
