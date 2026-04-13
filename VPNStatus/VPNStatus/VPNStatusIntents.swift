import AppIntents
import Foundation

// MARK: - Parameter enum (optional combined action)

enum VPNModeIntentParam: String, AppEnum {
    case work
    case external
    case none

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "VPN Mode"

    static var caseDisplayRepresentations: [VPNModeIntentParam: DisplayRepresentation] = [
        .work: "Work",
        .external: "External",
        .none: "None (clear)"
    ]
}

// MARK: - Individual shortcuts

struct ShowWorkVPNIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Work VPN"
    static var description = IntentDescription("Updates the Live Activity to show Work VPN.")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        try await Task { @MainActor in
            try await LiveActivityManager.shared.startOrUpdate(status: .work)
        }.value
        return .result()
    }
}

struct ShowExternalVPNIntent: AppIntent {
    static var title: LocalizedStringResource = "Show External VPN"
    static var description = IntentDescription("Updates the Live Activity to show External VPN.")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        try await Task { @MainActor in
            try await LiveActivityManager.shared.startOrUpdate(status: .external)
        }.value
        return .result()
    }
}

struct ClearVPNIntent: AppIntent {
    static var title: LocalizedStringResource = "Clear VPN"
    static var description = IntentDescription("Stops the VPN Live Activity.")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        try await Task { @MainActor in
            try await LiveActivityManager.shared.stop()
        }.value
        return .result()
    }
}

// MARK: - Combined action

struct SetVPNStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Set VPN Status"
    static var description = IntentDescription("Sets Work, External, or clears the Live Activity.")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Mode")
    var mode: VPNModeIntentParam

    init() {
        self.mode = .work
    }

    func perform() async throws -> some IntentResult {
        try await Task { @MainActor in
            switch mode {
            case .work:
                try await LiveActivityManager.shared.startOrUpdate(status: .work)
            case .external:
                try await LiveActivityManager.shared.startOrUpdate(status: .external)
            case .none:
                try await LiveActivityManager.shared.stop()
            }
        }.value
        return .result()
    }
}

// MARK: - App Shortcuts (discoverability in Shortcuts app)

struct VPNStatusShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        [
            AppShortcut(
                intent: ShowWorkVPNIntent(),
                phrases: [
                    "Work VPN in \(.applicationName)",
                    "Show Work VPN in \(.applicationName)"
                ],
                shortTitle: "Show Work VPN",
                systemImageName: "network"
            ),
            AppShortcut(
                intent: ShowExternalVPNIntent(),
                phrases: [
                    "External VPN in \(.applicationName)",
                    "Show External VPN in \(.applicationName)"
                ],
                shortTitle: "Show External VPN",
                systemImageName: "network.badge.shield.half.filled"
            ),
            AppShortcut(
                intent: ClearVPNIntent(),
                phrases: [
                    "Clear VPN in \(.applicationName)",
                    "Stop VPN status in \(.applicationName)"
                ],
                shortTitle: "Clear VPN",
                systemImageName: "xmark.circle"
            ),
            AppShortcut(
                intent: SetVPNStatusIntent(),
                phrases: [
                    "Set VPN status in \(.applicationName)"
                ],
                shortTitle: "Set VPN Status",
                systemImageName: "slider.horizontal.3"
            )
        ]
    }
}
