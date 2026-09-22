import SwiftUI

struct IdentificationResultView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @State private var navigateToProfile: Bool = false

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Breathing space so top image does not touch the frosted header edge
                    Spacer().frame(height: 12)

                    // Photo Thumbnail Card in Liquid Glass
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 230)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.white.opacity(0.55), .white.opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.2
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 7)
                            .padding(.horizontal, 20)
                    }

                    // Primary Match Card
                    if let match = viewModel.selectedMatch {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(match.bestCommonName)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)

                                    Text(match.species.scientificNameWithoutAuthor)
                                        .font(.subheadline.italic())
                                        .foregroundColor(.secondary)
                                }
                                Spacer()

                                if let family = match.species.family?.scientificNameWithoutAuthor {
                                    Text(family)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.botanicalEmerald)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(Color.botanicalMint.opacity(0.25))
                                        )
                                }
                            }

                            Divider()
                                .background(Color.secondary.opacity(0.2))

                            // Glowing Confidence Score Progress Bar
                            GlowingProgressBar(
                                progress: match.score,
                                label: "Species Match Confidence"
                            )

                            // Health Condition Summary preview if available
                            if let condition = viewModel.condition {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill((condition.isHealthy ? Color.botanicalJade : Color.botanicalAmber).opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Image(systemName: condition.isHealthy ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(condition.isHealthy ? .botanicalEmerald : .botanicalAmber)
                                    }

                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text("Health Diagnosis")
                                                .font(.caption.weight(.medium))
                                                .foregroundColor(.secondary)
                                            Spacer()
                                            Text(condition.name)
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(condition.isHealthy ? .botanicalEmerald : .botanicalAmber)
                                        }
                                        Text(condition.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill((condition.isHealthy ? Color.botanicalJade : Color.botanicalAmber).opacity(0.08))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke((condition.isHealthy ? Color.botanicalEmerald : Color.botanicalAmber).opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(20)
                        .liquidGlass(cornerRadius: 24, material: .ultraThinMaterial, opacity: 0.9, hasSpecularBorder: true)
                        .padding(.horizontal, 20)
                    }

                    // Alternative Candidates List
                    if viewModel.matches.count > 1 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Alternative Species Matches")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.matches.dropFirst()) { altMatch in
                                        Button {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            Task {
                                                await viewModel.selectCandidate(altMatch)
                                            }
                                        } label: {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(altMatch.bestCommonName)
                                                    .font(.subheadline.weight(.bold))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                Text(altMatch.species.scientificNameWithoutAuthor)
                                                    .font(.caption.italic())
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                                Text("\(altMatch.confidencePercentage)% match")
                                                    .font(.caption2.weight(.semibold))
                                                    .foregroundColor(.botanicalEmerald)
                                            }
                                            .padding(14)
                                            .frame(width: 170)
                                            .liquidGlass(cornerRadius: 18, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Clear spacing at bottom so content is fully scrollable above the pinned dock
                    Spacer().frame(height: 20)
                }
            }
            .ambientGlassBackground()
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial, in: Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                }
                .contentShape(Circle())

                Spacer()

                Text("Identification Result")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)

                Spacer()

                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.95))
                    .overlay(
                        Divider().opacity(0.2),
                        alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
            )
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                navigateToProfile = true
            } label: {
                HStack(spacing: 8) {
                    Text("View Full Care Profile & Health")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color.botanicalEmerald, Color.botanicalJade],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.45), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.botanicalEmerald.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.95))
                    .overlay(
                        Divider().opacity(0.2),
                        alignment: .top
                    )
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            if let match = viewModel.selectedMatch {
                PlantProfileView(
                    plantName: match.bestCommonName,
                    scientificName: match.species.scientificNameWithoutAuthor,
                    imageURL: match.images?.first?.url?.o ?? "https://images.unsplash.com/photo-1614594975525-e45190c55d0b",
                    watering: viewModel.careDetails?.watering ?? "Moderate watering",
                    sunlight: viewModel.careDetails?.sunlight ?? "Bright indirect light",
                    growthCycle: viewModel.careDetails?.cycle ?? "Perennial",
                    careInstructions: viewModel.careDetails?.careInstructions ?? "Keep soil moist.",
                    conditionName: viewModel.condition?.name,
                    conditionDescription: viewModel.condition?.description,
                    localImage: viewModel.selectedImage,
                    onSaveSuccess: {
                        navigateToProfile = false
                        viewModel.reset()
                    }
                )
            }
        }
        .navigationBarHidden(true)
        .onAppear { isTabBarHidden.wrappedValue = true }
        .onDisappear { isTabBarHidden.wrappedValue = false }
    }
}
