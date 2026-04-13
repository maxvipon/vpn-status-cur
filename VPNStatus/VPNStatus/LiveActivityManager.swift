import ActivityKit
import Foundation

/// Starts, updates, or ends the VPN Live Activity. Does not read system VPN state.
@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private init() {}

    func startOrUpdate(status: VPNStatus) async throws {
        guard status != .none else {
            try await stop()
            return
        }

        VPNStatusStorage.save(status)

        let state = VPNActivityAttributes.ContentState(
            displayTitle: status.displayTitle,
            shortLabel: status.shortLabel
        )
        let content = ActivityContent(state: state, staleDate: nil)

        if let activity = Activity<VPNActivityAttributes>.activities.first {
            await activity.update(content)
            return
        }

        _ = try await Activity.request(
            attributes: VPNActivityAttributes(),
            content: content,
            pushType: nil
        )
    }

    func stop() async throws {
        VPNStatusStorage.save(.none)

        for activity in Activity<VPNActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }
}
