import SwiftUI
import PhotosUI
import Kingfisher

struct LiveEventGalleryView: View {
    let event: Event
    let isAttending: Bool
    
    @State private var images: [GalleryImage] = []
    @State private var isLoading = true
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var expandedImage: GalleryImage?
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        ZStack {
            Color.urbanBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Event info bar
                eventInfoBar
                
                if isLoading {
                    Spacer()
                    ProgressView().tint(.urbanAccent)
                    Spacer()
                } else if images.isEmpty {
                    emptyGallery
                } else {
                    galleryGrid
                }
            }
            
            // Expanded image overlay
            if let img = expandedImage {
                expandedOverlay(img)
            }
        }
        .task { await fetchGallery() }
        .onChange(of: selectedPhotoItem) { _, item in
            if let item { Task { await uploadImage(item) } }
        }
    }
    
    // ── Header ──
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.urbanTextPrimary)
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    LiveBadge()
                    Text("Live Gallery")
                        .font(.jakarta(.semiBold, size: 16))
                        .foregroundColor(.urbanTextPrimary)
                }
                Text("\(images.count)/20 photos")
                    .font(.jakartaCaption2)
                    .foregroundColor(.urbanTextTertiary)
            }
            
            Spacer()
            
            // Upload button (only for attendees)
            if isAttending && images.count < 20 {
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.urbanAccent)
                        .clipShape(Circle())
                }
            } else {
                Color.clear.frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
    
    // ── Event info ──
    private var eventInfoBar: some View {
        HStack(spacing: 12) {
            if let urlStr = event.coverImageUrl, let url = URL(string: urlStr) {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.jakarta(.semiBold, size: 14))
                    .foregroundColor(.urbanTextPrimary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    if let venue = event.venueName {
                        Text(venue)
                            .font(.jakartaCaption2)
                            .foregroundColor(.urbanTextSecondary)
                    }
                }
            }
            Spacer()
            
            if !isAttending {
                Text("View Only")
                    .font(.jakarta(.medium, size: 10))
                    .foregroundColor(.urbanTextTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.urbanSurface)
                    .cornerRadius(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.urbanSurface.opacity(0.5))
    }
    
    // ── Empty state ──
    private var emptyGallery: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundColor(.urbanTextTertiary)
            Text("No photos yet")
                .font(.jakartaSubheadline)
                .foregroundColor(.urbanTextPrimary)
            if isAttending {
                Text("Be the first to share a moment!")
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanTextSecondary)
            } else {
                Text("Photos from attendees will appear here")
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanTextSecondary)
            }
            Spacer()
        }
    }
    
    // ── Photo grid ──
    private var galleryGrid: some View {
        ScrollView {
            if isUploading {
                HStack(spacing: 8) {
                    ProgressView().tint(.urbanAccent).scaleEffect(0.8)
                    Text("Uploading...")
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanTextSecondary)
                }
                .padding(.top, 8)
            }
            
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(images) { image in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            expandedImage = image
                        }
                    } label: {
                        KFImage(URL(string: image.url))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minHeight: 120)
                            .clipped()
                    }
                }
            }
            .padding(.bottom, 80)
        }
    }
    
    // ── Expanded image overlay ──
    @ViewBuilder
    private func expandedOverlay(_ image: GalleryImage) -> some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
                .onTapGesture {
                    withAnimation { expandedImage = nil }
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation { expandedImage = nil }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                }
                
                Spacer()
                
                KFImage(URL(string: image.url))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                
                Text("by \(image.uploaderName)")
                    .font(.jakartaCaption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .transition(.opacity)
        .zIndex(200)
    }
    
    // ── Network ──
    
    private func fetchGallery() async {
        do {
            struct R: Decodable { let images: [GalleryImage] }
            let r: R = try await APIClient.shared.get("/api/events/\(event.id)/live-gallery")
            images = r.images
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    private func uploadImage(_ item: PhotosPickerItem) async {
        isUploading = true
        defer { isUploading = false }
        
        guard let data = try? await item.loadTransferable(type: Data.self),
              let _ = UIImage(data: data) else {
            errorMessage = "Could not load image"
            return
        }
        
        // Upload to Cloudinary
        let cloudName = "dupvezbbt"
        let uploadPreset = "urbanSyncImgUpload"
        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n\(uploadPreset)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"live.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (responseData, _) = try await URLSession.shared.data(for: request)
            struct CloudinaryResponse: Decodable { let secure_url: String; let public_id: String }
            let cloudinary = try JSONDecoder().decode(CloudinaryResponse.self, from: responseData)
            
            // Register with backend
            struct UploadBody: Encodable {
                let url: String
                let public_id: String
            }
            try await APIClient.shared.postNoContent(
                "/api/events/\(event.id)/live-gallery",
                body: UploadBody(url: cloudinary.secure_url, public_id: cloudinary.public_id)
            )
            
            // Refresh
            await fetchGallery()
        } catch {
            errorMessage = "Upload failed"
        }
    }
}

struct GalleryImage: Codable, Identifiable {
    let id: UUID
    let url: String
    let uploaderName: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, url
        case uploaderName = "uploader_name"
        case createdAt = "created_at"
    }
}