import ActivityKit
import Foundation

struct VPNActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable, Sendable {
        var displayTitle: String
        var shortLabel: String
    }
}
