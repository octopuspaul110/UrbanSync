//
//  QRScannerView.swift
//  UrbanSync
//

import SwiftUI
import AVFoundation

struct QRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scannedCode: String?
    @State private var checkInResult: CheckInResult?
    @State private var isCheckingIn = false
    @State private var errorMessage: String?
    @State private var showResult = false
    
    struct CheckInResult: Codable {
        let checked_in: Bool
        let holder_name: String
        let tier_name: String?
        let event_title: String?
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            QRCodeScanner { code in
                guard scannedCode == nil, !isCheckingIn else { return }
                scannedCode = code
                Task { await processCode(code) }
            }
            .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Scan Ticket QR")
                        .font(.jakarta(.semiBold, size: 16))
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
                // Scan frame guide
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                        .frame(width: 260, height: 260)
                    
                    // Corner marks
                    ForEach(0..<4) { i in
                        cornerMark
                            .rotationEffect(.degrees(Double(i) * 90))
                            .offset(
                                x: i == 0 || i == 3 ? -120 : 120,
                                y: i < 2 ? -120 : 120
                            )
                    }
                }
                
                Spacer()
                
                Text(isCheckingIn ? "Checking in..." : "Position QR code within the frame")
                    .font(.jakartaCaption)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.bottom, 80)
            }
            
            if isCheckingIn {
                ZStack {
                    Color.black.opacity(0.6).ignoresSafeArea()
                    ProgressView().tint(.white).scaleEffect(1.5)
                }
            }
        }
        .alert("Check-in Result", isPresented: $showResult) {
            Button("Scan Another") {
                scannedCode = nil
                checkInResult = nil
                errorMessage = nil
            }
            Button("Done", role: .cancel) { dismiss() }
        } message: {
            if let result = checkInResult {
                Text("✅ \(result.holder_name) checked in for \(result.tier_name ?? "ticket")")
            } else if let error = errorMessage {
                Text("❌ \(error)")
            } else {
                Text("")
            }
        }
    }
    
    private var cornerMark: some View {
        ZStack {
            Rectangle().fill(Color.urbanAccent).frame(width: 24, height: 4)
            Rectangle().fill(Color.urbanAccent).frame(width: 4, height: 24)
        }
        .offset(x: 12, y: 12)
    }
    
    private func processCode(_ code: String) async {
        isCheckingIn = true
        defer { isCheckingIn = false }
        
        // Determine if it's a ticket QR (raw nanoid) or event link
        if code.starts(with: "https://urbansync.app/e/") || code.starts(with: "urbansync://event/") {
            // It's an event QR, just open it
            // Extract slug or id and navigate (or just dismiss with info)
            errorMessage = "This is an event QR, not a ticket. Open the link in your browser to view the event."
            showResult = true
            return
        }
        
        // Treat as ticket QR code (nanoid string)
        do {
            struct CheckInBody: Encodable { let qr_code: String }
            let result: CheckInResult = try await APIClient.shared.post(
                "/api/tickets/checkin-by-code",
                body: CheckInBody(qr_code: code)
            )
            checkInResult = result
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            showResult = true
        } catch let error as APIError {
            switch error {
            case .serverError(_, let message):
                errorMessage = message
            default:
                errorMessage = "Could not check in. Try again."
            }
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            showResult = true
        } catch {
            errorMessage = "Unexpected error"
            showResult = true
        }
    }
}

// AVFoundation QR scanner
struct QRCodeScanner: UIViewControllerRepresentable {
    let onCodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.onCodeScanned = onCodeScanned
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onCodeScanned: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        let session = AVCaptureSession()
        if session.canAddInput(input) { session.addInput(input) }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
        }
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
        
        captureSession = session
        previewLayer = preview
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let value = object.stringValue else { return }
        onCodeScanned?(value)
    }
}