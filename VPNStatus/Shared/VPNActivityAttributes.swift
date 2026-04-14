import ActivityKit
import Foundation

struct VPNActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        var liveActivityLabel: String
        var dynamicIslandLabel: String
    }
}
