import ActivityKit
import SwiftUI
import WidgetKit

struct LAStatusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LAActivityAttributes.self) { context in
            HStack(spacing: 8) {
                Text(context.state.liveActivityLabel)
                    .font(.headline)
                    .foregroundStyle(Self.uiColor(context.state.iconTextColor))
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.35))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.liveActivityLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Self.uiColor(context.state.iconTextColor))
                }
            } compactLeading: {
                StatusIcon(
                    size: 24,
                    systemName: context.state.iconSymbolName,
                    accessibilityLabel: context.state.liveActivityLabel
                )
                    .foregroundStyle(Self.uiColor(context.state.iconTextColor))
            } compactTrailing: {
                Text(context.state.dynamicIslandLabel)
                    .font(.caption2.weight(.semibold))
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(Self.uiColor(context.state.iconTextColor))
            } minimal: {
                StatusIcon(
                    size: 24,
                    systemName: context.state.iconSymbolName,
                    accessibilityLabel: context.state.liveActivityLabel
                )
                    .foregroundStyle(Self.uiColor(context.state.iconTextColor))
            }
            .keylineTint(Self.uiColor(context.state.iconTextColor))
        }
    }
}

private extension LAStatusLiveActivity {
    static func uiColor(_ color: LAStatusColor) -> Color {
        switch color {
        case .accent: return .accentColor
        case .white: return .white
        case .black: return .black
        case .gray: return .gray
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        }
    }
}
