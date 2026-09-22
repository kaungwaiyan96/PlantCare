import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Dedicated Botanist Profile & Garden Dashboard Sheet
struct UserProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var savedPlants: [SavedPlant]

    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("userFirstName") private var userFirstName: String = "Gardener"
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userProfileImageFilename") private var userProfileImageFilename: String = ""

    // Botanical Preference AppStorage bindings
    @AppStorage("wateringRemindersEnabled") private var wateringReminders: Bool = true
    @AppStorage("temperatureUnit") private var temperatureUnit: String = "°C"
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedback: Bool = true
    @AppStorage("autoDiagnoseFoliage") private var autoDiagnose: Bool = true

    @State private var showSignOutAlert: Bool = false
    @State private var showEditProfileSheet: Bool = false

    private var displayName: String {
        let trimmed = userFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Botanist" : trimmed
    }

    private var initialLetter: String {
        String(displayName.prefix(1)).uppercased()
    }

    private var gardenCount: Int {
        savedPlants.count > 0 ? savedPlants.count : 4
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 1. Hero Botanist Avatar & Rank
                        heroBotanistCard

                        // 2. Four-Metric Botanist Stats Grid
                        statsGridSection

                        // 3. Badges & Milestones Carousel
                        achievementsSection

                        // 4. Botanical Preferences Card
                        preferencesSection

                        // 5. Academic Capstone Banner
                        academicProjectBanner

                        // 6. Sign Out Button
                        signOutButton

                        Spacer().frame(height: 20)
                    }
                    .padding(.vertical, 16)
                }
                .ambientGlassBackground()
            }
            .navigationTitle("Botanist Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(.botanicalEmerald)
                }
            }
            .sheet(isPresented: $showEditProfileSheet) {
                EditProfileSheet()
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    dismiss()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isLoggedIn = false
                    }
                }
            } message: {
                Text("Are you sure you want to sign out? You can sign back in or continue as guest at any time.")
            }
        }
    }

    // MARK: - 1. Hero Botanist Card
    private var heroBotanistCard: some View {
        VStack(spacing: 14) {
            ZStack {
                // Luminous botanical outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.botanicalEmerald, Color.botanicalMint, Color.botanicalJade],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.botanicalEmerald.opacity(0.35), radius: 10, x: 0, y: 4)

                // Avatar background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.botanicalEmerald.opacity(0.25),
                                Color.botanicalJade.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 86, height: 86)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )

                if !userProfileImageFilename.isEmpty,
                   let profileImage = ImageStorageService.shared.loadImage(filename: userProfileImageFilename) {
                    Image(uiImage: profileImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 86, height: 86)
                        .clipShape(Circle())
                } else {
                    // Initial Monogram
                    Text(initialLetter)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.botanicalEmerald)
                }

                // Interactive Camera Edit Badge
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    showEditProfileSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.botanicalEmerald)
                            .frame(width: 28, height: 28)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    .shadow(color: Color.black.opacity(0.18), radius: 4, x: 0, y: 2)
                }
                .offset(x: 34, y: 34)
            }
            .contentShape(Circle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                showEditProfileSheet = true
            }

            VStack(spacing: 4) {
                Text(displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Active Botanist Session" : userEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Dedicated Edit Account Button
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    showEditProfileSheet = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                        Text("Edit Account")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.botanicalEmerald)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.botanicalMint.opacity(0.22))
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.botanicalEmerald.opacity(0.35), lineWidth: 1)
                    )
                }
                .padding(.top, 4)
            }

            // Rank Pill
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.botanicalEmerald)

                Text("Level 3 Botanist • Plant Parent")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.botanicalEmerald)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.botanicalMint.opacity(0.22))
            )
            .overlay(
                Capsule()
                    .stroke(Color.botanicalEmerald.opacity(0.3), lineWidth: 1)
            )

            // Botanical XP Progress Bar
            VStack(spacing: 6) {
                HStack {
                    Text("Rank Progress")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1,450 / 2,000 XP")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.primary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 6)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.botanicalMint, Color.botanicalEmerald],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * 0.725, height: 6)
                            .shadow(color: Color.botanicalMint.opacity(0.6), radius: 4, x: 0, y: 0)
                    }
                }
                .frame(height: 6)
            }
            .padding(.horizontal, 32)
            .padding(.top, 4)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 24, material: .ultraThinMaterial, opacity: 0.9, hasSpecularBorder: true)
        .padding(.horizontal, 20)
    }

    // MARK: - 2. Four-Metric Botanist Stats Grid
    private var statsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
            statMetricCard(
                value: "12",
                title: "Scanned",
                subtitle: "Identifications",
                icon: "camera.viewfinder",
                accentColor: .botanicalEmerald
            )

            statMetricCard(
                value: "\(gardenCount)",
                title: "In Garden",
                subtitle: "Thriving Species",
                icon: "leaf.fill",
                accentColor: .botanicalJade
            )

            statMetricCard(
                value: "7 Days",
                title: "Care Streak",
                subtitle: "Active Hydration",
                icon: "flame.fill",
                accentColor: .botanicalAmber
            )

            statMetricCard(
                value: "98%",
                title: "Health Index",
                subtitle: "Garden Vitality",
                icon: "heart.fill",
                accentColor: .botanicalMint
            )
        }
        .padding(.horizontal, 20)
    }

    private func statMetricCard(value: String, title: String, subtitle: String, icon: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary.opacity(0.85))

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
    }

    // MARK: - 3. Badges & Milestones Carousel
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Botanist Milestones")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)

                Spacer()

                Text("4 of 5 Unlocked")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.botanicalEmerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.botanicalMint.opacity(0.2)))
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    badgeCard(
                        icon: "medal.fill",
                        title: "First Leaf",
                        description: "Identified 1st plant",
                        status: "Unlocked",
                        isUnlocked: true,
                        accentColor: Color(hex: 0xD4AF37)
                    )

                    badgeCard(
                        icon: "leaf.circle.fill",
                        title: "Green Thumb",
                        description: "3+ plants in garden",
                        status: "Unlocked",
                        isUnlocked: true,
                        accentColor: .botanicalMint
                    )

                    badgeCard(
                        icon: "drop.circle.fill",
                        title: "Hydration Hero",
                        description: "7-day care consistency",
                        status: "Unlocked",
                        isUnlocked: true,
                        accentColor: .botanicalEmerald
                    )

                    badgeCard(
                        icon: "cross.vial.fill",
                        title: "Flora Doctor",
                        description: "Foliage health diagnosed",
                        status: "Unlocked",
                        isUnlocked: true,
                        accentColor: .botanicalAmber
                    )

                    badgeCard(
                        icon: "crown.fill",
                        title: "Flora Master",
                        description: "Scan 25 unique flora",
                        status: "12 / 25",
                        isUnlocked: false,
                        accentColor: Color(hex: 0x9B59B6)
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func badgeCard(icon: String, title: String, description: String, status: String, isUnlocked: Bool, accentColor: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(isUnlocked ? 0.2 : 0.08))
                    .frame(width: 46, height: 46)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isUnlocked ? accentColor : .secondary.opacity(0.5))
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Text(status)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(isUnlocked ? .botanicalEmerald : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(isUnlocked ? Color.botanicalMint.opacity(0.2) : Color.secondary.opacity(0.12))
                )
        }
        .padding(14)
        .frame(width: 136, height: 160)
        .liquidGlass(cornerRadius: 18, material: .thinMaterial, opacity: isUnlocked ? 0.9 : 0.65, hasSpecularBorder: true)
    }

    // MARK: - 4. Botanical Preferences Card
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Care Preferences")
                .font(.headline.weight(.bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 20)

            VStack(spacing: 14) {
                // Watering Reminders Toggle
                Toggle(isOn: $wateringReminders) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.botanicalEmerald.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.botanicalEmerald)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Watering Reminders")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Timely push alerts for plant care")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(.botanicalEmerald)

                Divider().opacity(0.2)

                // Temperature Scale Picker
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.botanicalAmber.opacity(0.15))
                            .frame(width: 32, height: 32)
                        Image(systemName: "thermometer.medium")
                            .font(.system(size: 16))
                            .foregroundColor(.botanicalAmber)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Temperature Scale")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                        Text("Display metric or imperial degrees")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Picker("Temperature Unit", selection: $temperatureUnit) {
                        Text("°C").tag("°C")
                        Text("°F").tag("°F")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 96)
                }

                Divider().opacity(0.2)

                // Haptic Feedback Toggle
                Toggle(isOn: $hapticFeedback) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.botanicalMint.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "waveform")
                                .font(.system(size: 15))
                                .foregroundColor(.botanicalMint)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tactile Haptics")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Sensory tap confirmation on actions")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(.botanicalEmerald)

                Divider().opacity(0.2)

                // Auto-Diagnose Foliage Toggle
                Toggle(isOn: $autoDiagnose) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.botanicalJade.opacity(0.15))
                                .frame(width: 32, height: 32)
                            Image(systemName: "cross.case.fill")
                                .font(.system(size: 15))
                                .foregroundColor(.botanicalJade)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto-Diagnose Foliage")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                            Text("Run health audit alongside species scan")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(.botanicalEmerald)
            }
            .padding(18)
            .liquidGlass(cornerRadius: 22, material: .ultraThinMaterial, opacity: 0.9, hasSpecularBorder: true)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - 5. Academic Capstone Banner
    private var academicProjectBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.botanicalEmerald.opacity(0.18))
                        .frame(width: 32, height: 32)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.botanicalEmerald)
                }

                Text("PlantCare Capstone")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)

                Spacer()

                Text("v1.0")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.botanicalEmerald)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.botanicalMint.opacity(0.2)))
            }

            Text("Architected with SwiftData local cache, Liquid Glass design tokens, and dual-pipeline botanical vision (PlantNet AI + Perenual API).")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)

            HStack(spacing: 6) {
                ForEach(["iOS 17+", "SwiftData", "Liquid Glass", "PlantNet API"], id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.12))
                        )
                }
            }
            .padding(.top, 2)
        }
        .padding(18)
        .liquidGlass(cornerRadius: 20, material: .thinMaterial, opacity: 0.85, hasSpecularBorder: true)
        .padding(.horizontal, 20)
    }

    // MARK: - 6. Sign Out Button
    private var signOutButton: some View {
        Button(role: .destructive) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            showSignOutAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .semibold))
                Text("Sign Out of PlantCare")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.red.opacity(0.09))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.red.opacity(0.25), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }
}

// MARK: - Edit Profile & Account Sheet
struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("userFirstName") private var userFirstName: String = "Gardener"
    @AppStorage("userEmail") private var userEmail: String = ""
    @AppStorage("userProfileImageFilename") private var userProfileImageFilename: String = ""

    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isPhotoRemoved: Bool = false
    @State private var isSaving: Bool = false

    private var previewInitial: String {
        let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String((trimmed.isEmpty ? "B" : trimmed).prefix(1)).uppercased()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // 1. Avatar Preview & Photo Picker Controls
                        VStack(spacing: 14) {
                            ZStack {
                                // Outer luminous ring
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.botanicalEmerald, Color.botanicalMint, Color.botanicalJade],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 108, height: 108)
                                    .shadow(color: Color.botanicalEmerald.opacity(0.3), radius: 10, x: 0, y: 4)

                                // Current or Newly Selected Avatar
                                if let image = selectedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 98, height: 98)
                                        .clipShape(Circle())
                                } else if !isPhotoRemoved && !userProfileImageFilename.isEmpty,
                                          let existingImage = ImageStorageService.shared.loadImage(filename: userProfileImageFilename) {
                                    Image(uiImage: existingImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 98, height: 98)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.botanicalEmerald.opacity(0.25),
                                                    Color.botanicalJade.opacity(0.12)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 98, height: 98)
                                        .overlay(
                                            Text(previewInitial)
                                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                                .foregroundColor(.botanicalEmerald)
                                        )
                                }
                            }

                            // Action buttons: Pick Photo / Remove Photo
                            HStack(spacing: 12) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.caption.weight(.semibold))
                                        Text((selectedImage != nil || (!isPhotoRemoved && !userProfileImageFilename.isEmpty)) ? "Change Photo" : "Add Photo")
                                            .font(.caption.weight(.semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.botanicalEmerald)
                                    .clipShape(Capsule())
                                    .shadow(color: Color.botanicalEmerald.opacity(0.3), radius: 6, y: 3)
                                }

                                if selectedImage != nil || (!isPhotoRemoved && !userProfileImageFilename.isEmpty) {
                                    Button {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        selectedPhotoItem = nil
                                        selectedImage = nil
                                        isPhotoRemoved = true
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "trash")
                                                .font(.caption)
                                            Text("Remove")
                                                .font(.caption.weight(.medium))
                                        }
                                        .foregroundColor(.red.opacity(0.9))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial, in: Capsule())
                                        .overlay(Capsule().stroke(Color.red.opacity(0.25), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)

                        // 2. Editable User Information Card
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Account Details")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.primary)

                            // Name Input
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Name")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.botanicalEmerald)
                                        .frame(width: 22)

                                    TextField("Your name", text: $editedName)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.35))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                            }

                            // Email Input
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email Address")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.botanicalEmerald)
                                        .frame(width: 22)

                                    TextField("Email", text: $editedEmail)
                                        .font(.body)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled(true)
                                        .foregroundColor(.primary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.35))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                        .liquidGlass(cornerRadius: 24, material: .ultraThinMaterial, opacity: 0.9, hasSpecularBorder: true)
                        .padding(.horizontal, 20)

                        // 3. Primary Save Changes Button (No arrow, Apple HIG compliant)
                        Button {
                            saveChanges()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Save Changes")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color.botanicalEmerald, Color.botanicalJade],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(color: Color.botanicalEmerald.opacity(0.35), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .disabled(isSaving || editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.bottom, 24)
                }
                .ambientGlassBackground()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(.body.weight(.bold))
                    .foregroundColor(.botanicalEmerald)
                    .disabled(isSaving || editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                editedName = userFirstName
                editedEmail = userEmail
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.selectedImage = uiImage
                            self.isPhotoRemoved = false
                        }
                    }
                }
            }
        }
    }

    private func saveChanges() {
        isSaving = true
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            userFirstName = trimmedName
        }
        userEmail = editedEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        // Handle photo persistence
        if isPhotoRemoved {
            if !userProfileImageFilename.isEmpty {
                ImageStorageService.shared.deleteImage(filename: userProfileImageFilename)
                userProfileImageFilename = ""
            }
        } else if let newImage = selectedImage {
            if !userProfileImageFilename.isEmpty {
                ImageStorageService.shared.deleteImage(filename: userProfileImageFilename)
            }
            if let newFilename = try? ImageStorageService.shared.saveImage(newImage) {
                userProfileImageFilename = newFilename
            }
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss()
    }
}
