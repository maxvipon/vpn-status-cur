import ActivityKit
import SwiftUI
import WidgetKit

struct VPNStatusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VPNActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text(context.state.displayTitle)
                        .font(.headline)
                } icon: {
                    Image(systemName: "network")
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.35))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "network")
                        .symbolRenderingMode(.hierarchical)
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.displayTitle)
                        .font(.headline)
                }
            } compactLeading: {
                Image(systemName: "network")
            } compactTrailing: {
                Text(context.state.shortLabel)
                    .font(.caption2.weight(.semibold))
                    .minimumScaleFactor(0.5)
            } minimal: {
                Image(systemName: "network")
            }
            .keylineTint(Color.accentColor)
        }
    }
}
