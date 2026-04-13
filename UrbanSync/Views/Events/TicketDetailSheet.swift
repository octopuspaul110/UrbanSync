//
//  TicketDetailSheet.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 12/04/2026.
//


import SwiftUI
import CoreImage.CIFilterBuiltins
 
struct TicketDetailSheet: View {
    let ticket: Ticket
    @Environment(\.dismiss) private var dismiss
 
    var body: some View {
        VStack(spacing: 20) {
            // \u2500\u2500 Drag Indicator \u2500\u2500
            // (Handled by .presentationDragIndicator(.visible) on the parent .sheet)
 
            // \u2500\u2500 Event Title \u2500\u2500
            Text(ticket.title ?? "Event")
                .font(.jakartaTitle3)
                .foregroundColor(.urbanTextPrimary)
                .multilineTextAlignment(.center)
 
            // \u2500\u2500 QR Code \u2500\u2500
            // Generated locally from the qr_code string.
            // No network needed — works offline.
            if let qrImage = generateQRCode(from: ticket.qrCode) {
                Image(uiImage: qrImage)
                    .interpolation(.none)  // Keep QR code crisp, no blurring.
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 220, height: 220)
                    .padding(16)
                    .background(Color.white)  // White background for scanner contrast.
                    .cornerRadius(16)
            }
 
            // \u2500\u2500 Ticket Info \u2500\u2500
            VStack(spacing: 8) {
                if let time = ticket.startTime {
                    Label(time.fullFormatted, systemImage: "calendar")
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextSecondary)
                }
                if let venue = ticket.venueName {
                    Label(venue, systemImage: "mappin.and.ellipse")
                        .font(.jakartaSubheadline)
                        .foregroundColor(.urbanTextSecondary)
                }
                if let tier = ticket.tierName {
                    Text(tier)
                        .font(.jakartaCaption)
                        .foregroundColor(.urbanAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.urbanAccent.opacity(0.15))
                        .cornerRadius(8)
                }
            }
 
            // \u2500\u2500 Status \u2500\u2500
            Text(ticket.status.uppercased())
                .font(.jakarta(.bold, size: 14))
                .foregroundColor(ticket.status == "confirmed" ? .urbanMint : .urbanGold)
 
            Spacer()
 
            Text("Show this QR code at the door")
                .font(.jakartaCaption)
                .foregroundColor(.urbanTextTertiary)
        }
        .padding(24)
    }
 
    // \u2500\u2500 Generate QR Code from String \u2500\u2500
    // Uses Core Image's built-in QR code generator.
    // No third-party library needed.
    private func generateQRCode(from string: String) -> UIImage? {
        // CIFilter.qrCodeGenerator() is a built-in Core Image filter.
        let filter = CIFilter.qrCodeGenerator()
        // Set the data to encode (the qr_code string from the backend).
        filter.message = Data(string.utf8)
        // Error correction level: M (medium, 15% recovery).
        filter.correctionLevel = "M"
 
        // The filter produces a tiny image. Scale it up.
        guard let ciImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        return UIImage(ciImage: scaledImage)
    }
}
