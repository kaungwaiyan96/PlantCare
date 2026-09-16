import SwiftUI

struct GlowingProgressBar: View {
    var progress: Double // 0.0 to 1.0
    var label: String = "Identification Confidence"
    @State private var animatedProgress: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int((animatedProgress * 100).rounded()))%")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.primary.opacity(0.1))
                        .frame(height: 12)

                    // Fill bar with gradient and glow
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.botanicalSage, Color.botanicalMint, Color.botanicalEmerald],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geometry.size.width * animatedProgress), height: 12)
                        .shadow(color: Color.botanicalMint.opacity(0.8), radius: 8, x: 0, y: 0)
                }
            }
            .frame(height: 12)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = min(max(progress, 0.0), 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animatedProgress = min(max(newValue, 0.0), 1.0)
            }
        }
    }
}
