import ActivityKit
import SwiftUI
import WidgetKit

struct VPNStatusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VPNActivityAttributes.self) { context in
            HStack(spacing: 8) {
                WorkVPNIcon(size: 22)
                Text(context.state.liveActivityLabel)
                    .font(.headline)
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.35))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    WorkVPNIcon(size: 28)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.liveActivityLabel)
                        .font(.subheadline.weight(.semibold))
                }
            } compactLeading: {
                WorkVPNIcon(size: 18)
            } compactTrailing: {
                Text(context.state.dynamicIslandLabel)
                    .font(.caption2.weight(.semibold))
                    .minimumScaleFactor(0.5)
            } minimal: {
                WorkVPNIcon(size: 14)
            }
            .keylineTint(Color.accentColor)
        }
    }
}
