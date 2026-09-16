import SwiftUI

struct IdentificationResultView: View {
    @ObservedObject var viewModel: ScanViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header with back button
                    HStack {
                        Button {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(12)
                                .liquidGlass(cornerRadius: 16, material: .thinMaterial, opacity: 0.8, hasSpecularBorder: true)
                        }

                        Spacer()

                        Text("Identification Result")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.primary)

                        Spacer()

                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // Photo Thumbnail Card in Liquid Glass
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)
                            .padding(.horizontal, 20)
                    }

                    // Primary Match Card
                    if let match = viewModel.selectedMatch {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(match.bestCommonName)
                                        .font(.title2.weight(.bold))
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
                                    Image(systemName: condition.isHealthy ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(condition.isHealthy ? .botanicalEmerald : .botanicalAmber)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Health Diagnosis: \(condition.name)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.primary)
                                        Text(condition.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill((condition.isHealthy ? Color.botanicalJade : Color.botanicalAmber).opacity(0.12))
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

                    // Navigation to Full Care Profile
                    NavigationLink {
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
                                localImage: viewModel.selectedImage
                            )
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("View Full Care Profile & Health")
                                .font(.headline.weight(.bold))
                            Image(systemName: "arrow.right")
                                .font(.subheadline.weight(.bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.botanicalMint)
                        )
                        .shadow(color: Color.botanicalMint.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .ambientGlassBackground()
            .navigationBarHidden(true)
        }
    }
}
