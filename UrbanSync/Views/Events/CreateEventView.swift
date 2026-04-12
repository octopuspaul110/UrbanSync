//
//  CreateEventView.swift
//  UrbanSync
//
//  Created by Adegbite Paul  on 11/04/2026.
//

import SwiftUI
import PhotosUI
import Combine

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm = CreateEventViewModel()
    @State private var showAirplane = false
    @State private var createdEventName = ""
    
    // Cover image
    @State private var selectedCoverItem: PhotosPickerItem?
    @State private var coverImage: UIImage?
    
    // Metadata
    @State private var theme        = ""
    @State private var speakerList  = ""
    @State private var agenda       = ""
    @State private var dressTips    = ""
    
    @State private var createdJoinCode        = ""
    @State private var createdPrivateJoinCode = ""
    @State private var slug                   = ""
    
    let categories = [
        ("celebration", "Celebrations"),
        ("nightlife", "Nightlife"),
        ("tech", "Tech"),
        ("heritage", "Heritage"),
        ("religious", "Religious"),
        ("corporate", "Corporate"),
        ("community", "Community"),
        ("public_square", "Public"),
        ("concert", "Concerts"),
        ("sports", "Sports"),
    ]
    
    var body: some View {
        NavigationStack{
            ZStack {
                Color.urbanBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing : 20){
//                        Cover Image
                        coverImageSection
                        
//                        Title
                        formField(title : "Event Title") {
                            TextField("Enter the Title of your Event",text: $vm.title)
                        }
                        
//                        Category Picker
                        formField(title : "Category"){
                            Picker("Category",selection: $vm.category){
                                ForEach(categories,id : \.0) {cat in
                                    Text(cat.1).tag(cat.0)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.urbanAccent)
                        }
                        
//                        Description
                        formField(title : "Description"){
                            TextField("Tell people about your event",
                                      text : $vm.description,
                                      axis: .vertical)
                            .lineLimit(4...8)
                        }
                        
//                        Venue
                        venueSection
//                        Date and time
                        dateSection
                        
                        // Dress Code
                        formField(title: "Dress Code") {
                            TextField("e.g Black tie, Smart casual, Ankara", text: $vm.dressCode)
                        }
                        
//                        Visibility
                        formField(title : "Visibility") {
                            Picker("", selection: $vm.visibility) {
                                Text("Public").tag("public")
                                Text("Private").tag("private")
                                Text("unlisted").tag("unlisted")
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Recurrence
                        recurrenceSection
                        
                        // Max Capacity
                        formField(title: "Max Capacity (optional)") {
                            TextField("Leave empty for unlimited", value: $vm.maxCapacity, format: .number)
                                .keyboardType(.numberPad)
                        }
                        
//                        Gifting Toggle and Paid event
                        togglesSection
                        
//                        Metadata section
                        metadataSection
                        
//                        Error Message
                        if let error = vm.errorMessage {
                            Text(error)
                                .foregroundColor(.urbanCoral)
                                .padding()
                        }
//                        Submit
                        submitButton
                    }
                    .padding(16)
                }
            }
            .navigationTitle(Text("Create Event"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.urbanTextPrimary)
                }
            }
            .overlay {
                AirplaneAnimation(
                    isShowing       : $showAirplane,
                    eventName       : $createdEventName,
                    joinCode        : $createdJoinCode,
                    privateJoinCode : $createdPrivateJoinCode,
                    slug            : $slug
                ) {
                    dismiss()
                }
            }
        }
    }
    @ViewBuilder
    private var recurrenceSection: some View {
        formField(title: "Repeat") {
            Picker("", selection: $vm.recurrence) {
                Text("Does not repeat").tag("none")
                Text("Daily").tag("daily")
                Text("Weekly").tag("weekly")
                Text("Biweekly").tag("biweekly")
                Text("Monthly").tag("monthly")
                Text("Custom dates").tag("custom")
            }
            .pickerStyle(.menu)
            .tint(.urbanAccent)
        }

        if vm.recurrence != "none" {
            if vm.recurrence == "weekly" || vm.recurrence == "biweekly" {
                dayPickerSection
            }

            if vm.recurrence == "daily" || vm.recurrence == "monthly" {
                formField(title: vm.recurrence == "daily" ? "Every N days" : "Every N months") {
                    Stepper("\(vm.recurrenceInterval)", value: $vm.recurrenceInterval, in: 1...12)
                        .foregroundColor(.urbanTextPrimary)
                }
            }

            recurrenceEndDateSection

            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.urbanAccent)
                    .font(.system(size: 14))
                Text(recurrenceSummary)
                    .font(.jakartaCaption)
                    .foregroundColor(.urbanTextSecondary)
            }
            .padding(12)
            .background(Color.urbanAccent.opacity(0.1))
            .cornerRadius(10)
        }
    }

    @ViewBuilder
    private var dayPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Repeat on")
                .font(.caption)
                .foregroundColor(.urbanTextPrimary)

            let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    let isSelected = vm.recurrenceDays.contains(index)
                    Button {
                        if isSelected {
                            vm.recurrenceDays.removeAll { $0 == index }
                        } else {
                            vm.recurrenceDays.append(index)
                        }
                    } label: {
                        Text(days[index])
                            .font(.system(size: 11, weight: .medium))
                            .frame(width: 34, height: 34)
                            .background(isSelected ? Color.urbanAccent : Color.urbanSurface)
                            .foregroundColor(isSelected ? .white : .urbanTextSecondary)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recurrenceEndDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle("Set end date", isOn: Binding(
                get: { vm.recurrenceEndDate != nil },
                set: { vm.recurrenceEndDate = $0 ? Date().addingTimeInterval(86400 * 30) : nil }
            ))
            .tint(.urbanAccent)
            .foregroundColor(.urbanTextPrimary)
            .padding()
            .background(Color.urbanSurface)
            .cornerRadius(12)

            if vm.recurrenceEndDate != nil {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { vm.recurrenceEndDate ?? Date() },
                        set: { vm.recurrenceEndDate = $0 }
                    ),
                    in: vm.endDate...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .tint(.urbanAccent)
                .padding()
                .background(Color.urbanSurface)
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var togglesSection: some View {
        Toggle("Enable Gifting", isOn: $vm.giftingEnabled)
            .tint(.urbanAccent)
            .foregroundColor(.urbanTextPrimary)
            .padding()
            .background(Color.urbanSurface)
            .cornerRadius(12)

        Toggle("Paid Event", isOn: $vm.isPaid)
            .tint(.urbanAccent)
            .foregroundColor(.urbanTextPrimary)
            .padding()
            .background(Color.urbanSurface)
            .cornerRadius(12)
    }

    @ViewBuilder
    private var venueSection: some View {
        formField(title: "Venue Name") {
            TextField("e.g Eko Hotel, Victoria Island", text: $vm.VenueName)
        }
        formField(title: "City") {
            TextField("Lagos", text: $vm.city)
        }
        formField(title: "State") {
            TextField("e.g Lagos, Abuja", text: $vm.state)
        }
    }

    @ViewBuilder
    private var dateSection: some View {
        formField(title: "Start Date & Time") {
            DatePicker("", selection: $vm.startDate, in: Date()...)
                .datePickerStyle(.compact)
                .tint(.urbanAccent)
        }
        formField(title: "End Date & Time") {
            DatePicker("", selection: $vm.endDate, in: vm.startDate...)
                .tint(.urbanAccent)
        }
    }
//    recurrence summary
    private var recurrenceSummary: String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        switch vm.recurrence {
        case "daily":
            return "Repeats every \(vm.recurrenceInterval == 1 ? "day" : "\(vm.recurrenceInterval) days")"
        case "weekly":
            let names = vm.recurrenceDays.sorted().map { days[$0] }.joined(separator: ", ")
            return "Repeats every week\(names.isEmpty ? "" : " on \(names)")"
        case "biweekly":
            let names = vm.recurrenceDays.sorted().map { days[$0] }.joined(separator: ", ")
            return "Repeats every 2 weeks\(names.isEmpty ? "" : " on \(names)")"
        case "monthly":
            return "Repeats every \(vm.recurrenceInterval == 1 ? "month" : "\(vm.recurrenceInterval) months")"
        case "custom":
            return "You'll be able to add specific dates after creating the event"
        default:
            return ""
        }
    }
    
    // Cover Image
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
                        Text("Uploading photo...")
                            .font(.caption)
                            .foregroundColor(.urbanTextSecondary)
                    }
                }
            }
        }
    
        // Metadata
        // Shows different fields based on the selected category
        @ViewBuilder
        private var metadataSection: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("Extra Details")
                    .font(.jakartaSubheadline.weight(.medium))
                    .foregroundColor(.urbanTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                switch vm.category {
                case "tech", "corporate":
                    formField(title: "Speakers / Lineup") {
                        TextField("e.g John Doe, Jane Smith", text: $speakerList, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    formField(title: "Agenda / Schedule") {
                        TextField("e.g 10am - Opening, 11am - Keynote", text: $agenda, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    formField(title: "Theme") {
                        TextField("e.g Future of AI, Web3 Africa", text: $theme)
                    }

                case "nightlife", "concert":
                    formField(title: "Lineup / Artists") {
                        TextField("e.g Wizkid, Burna Boy", text: $speakerList, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    formField(title: "Theme / Vibe") {
                        TextField("e.g All White, Afrobeats Night", text: $theme)
                    }
                    formField(title: "Dress Tips") {
                        TextField("e.g No slippers, Smart casual only", text: $dressTips)
                    }

                case "heritage", "religious", "community", "public_square":
                    formField(title: "Theme") {
                        TextField("e.g New Yam Festival 2026", text: $theme)
                    }
                    formField(title: "Additional Info") {
                        TextField("Anything else attendees should know", text: $agenda, axis: .vertical)
                            .lineLimit(2...4)
                    }

                case "sports":
                    formField(title: "Teams / Participants") {
                        TextField("e.g Lagos FC vs Abuja United", text: $speakerList)
                    }
                    formField(title: "Additional Info") {
                        TextField("e.g Bring your own water, parking available", text: $agenda, axis: .vertical)
                            .lineLimit(2...4)
                    }

                default:
                    formField(title: "Theme") {
                        TextField("e.g Black & Gold, Garden Party", text: $theme)
                    }
                }
            }
        }
    // Build metadata before submit
    private func buildMetadata() {
        var meta: [String: String] = [:]

        if !theme.isEmpty       { meta["theme"]        = theme }
        if !speakerList.isEmpty { meta["speakers"]     = speakerList }
        if !agenda.isEmpty      { meta["agenda"]       = agenda }
        if !dressTips.isEmpty   { meta["dress_tips"]   = dressTips }

        vm.metadata = meta
    }
    
    @ViewBuilder
    private func formField<Content : View>(title : String, @ViewBuilder content : () -> Content) -> some View {
        VStack(alignment: .leading,spacing: 8) {
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
    
    @ViewBuilder
    private var submitButton: some View {
        Button {
            Task {
                buildMetadata()
                let success = await vm.createEvent()
                if success {
                    createdEventName       = vm.title
                    createdJoinCode        = vm.createdJoinCode ?? ""
                    createdPrivateJoinCode = vm.createdPrivateJoinCode ?? ""
                    slug                   = vm.createdSlug ?? ""       
                    withAnimation { showAirplane = true }
                }
            }
        } label: {
            HStack(spacing: 5) {
                Text(vm.isSubmitting ? "Creating..." : "Create Event")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.title.isEmpty ? Color.urbanSurfaceLight : Color.urbanAccent)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                if vm.isSubmitting {
                    ProgressView().tint(.urbanAccent)
                }
            }
        }
        .disabled(vm.title.isEmpty || vm.isSubmitting)
    }
}

#Preview {
    CreateEventView()
}
