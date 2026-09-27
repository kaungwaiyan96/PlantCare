import SwiftUI

enum MetricType {
    case watering
    case sunlight
    case cycle
    case date
    case careLevel

    var iconName: String {
        switch self {
        case .watering: return "drop.fill"
        case .sunlight: return "sun.max.fill"
        case .cycle: return "leaf.arrow.triangle.circlepath"
        case .date: return "calendar"
        case .careLevel: return "sparkles"
        }
    }

    var tintColor: Color {
        switch self {
        case .watering: return .cyan
        case .sunlight: return .orange
        case .cycle: return .botanicalJade
        case .date: return .purple
        case .careLevel: return .botanicalEmerald
        }
    }

    var title: String {
        switch self {
        case .watering: return "Watering"
        case .sunlight: return "Sunlight"
        case .cycle: return "Cycle"
        case .date: return "Saved Date"
        case .careLevel: return "Care Level"
        }
    }
}

struct GlassMetricBadge: View {
    var type: MetricType
    var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: type.iconName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(type.tintColor)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(type.tintColor.opacity(0.15))
                    )

                Text(type.title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 94, alignment: .topLeading)
        .padding(14)
        .liquidGlass(
            cornerRadius: 20,
            material: .thinMaterial,
            opacity: 0.8,
            hasSpecularBorder: true
        )
    }
}
