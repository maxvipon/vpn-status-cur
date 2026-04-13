import Foundation

/// Persists the last manually selected VPN status for the main app and intents.
enum VPNStatusStorage {
    private static var suite: UserDefaults {
        UserDefaults(suiteName: AppGroup.id) ?? .standard
    }

    private static let key = "lastVPNStatus"

    static func load() -> VPNStatus {
        guard let raw = suite.string(forKey: key),
              let status = VPNStatus(rawValue: raw) else {
            return .none
        }
        return status
    }

    static func save(_ status: VPNStatus) {
        suite.set(status.rawValue, forKey: key)
    }
}

enum AppGroup {
    static let id = "group.com.vpnstatus.shared"
}
