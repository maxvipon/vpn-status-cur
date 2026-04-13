import Foundation

/// Manually selected VPN mode (not tied to system VPN state).
enum VPNStatus: String, CaseIterable, Codable, Sendable {
    case work = "Work VPN"
    case external = "External VPN"
    case none = "No VPN"

    var displayTitle: String { rawValue }

    var shortLabel: String {
        switch self {
        case .work: return "Work"
        case .external: return "Ext"
        case .none: return "Off"
        }
    }
}
