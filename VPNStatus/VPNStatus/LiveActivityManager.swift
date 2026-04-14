import ActivityKit
import Foundation

/// Starts, updates, or ends the VPN Live Activity. Does not read system VPN state.
@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private init() {}

    func startOrUpdate(
        status: VPNStatus,
        liveActivityLabel: String? = nil,
        dynamicIslandLabel: String? = nil
    ) async throws {
        guard status != .none else {
            try await stop()
            return
        }

        VPNStatusStorage.save(status)
        let trimmedLiveLabel = liveActivityLabel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedLiveLabel = trimmedLiveLabel.isEmpty ? status.displayTitle : trimmedLiveLabel
        let trimmedIslandLabel = dynamicIslandLabel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let normalizedIslandLabel = trimmedIslandLabel.isEmpty
            ? String(normalizedLiveLabel.prefix(8))
            : String(trimmedIslandLabel.prefix(8))

        let state = VPNActivityAttributes.ContentState(
            liveActivityLabel: normalizedLiveLabel,
            dynamicIslandLabel: normalizedIslandLabel
        )
        let content = ActivityContent(state: state, staleDate: nil)

        if let activity = Activity<VPNActivityAttributes>.activities.first {
            await activity.update(content)
            return
        }

        _ = try Activity.request(
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
