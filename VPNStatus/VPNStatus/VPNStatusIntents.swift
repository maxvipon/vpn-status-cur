import AppIntents
import Foundation

// MARK: - Actions

struct SetVPNStatusIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Set VPN Status"
    static var description = IntentDescription("Sets custom labels for Live Activity and Dynamic Island.")

    static var openAppWhenRun: Bool = false

    @Parameter(title: "Live Activity Label")
    var liveActivityLabel: String

    @Parameter(title: "Dynamic Island Label")
    var dynamicIslandLabel: String

    init() {
        self.liveActivityLabel = "Work VPN"
        self.dynamicIslandLabel = "Work"
    }

    func perform() async throws -> some IntentResult {
        try await Task { @MainActor in
            try await LiveActivityManager.shared.startOrUpdate(
                status: .work,
                liveActivityLabel: liveActivityLabel,
                dynamicIslandLabel: dynamicIslandLabel
            )
        }.value
        return .result()
    }
}

struct ClearVPNIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Clear VPN Status"
    static var description = IntentDescription("Stops the VPN Live Activity.")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult {
        try await Task { @MainActor in
            try await LiveActivityManager.shared.stop()
        }.value
        return .result()
    }
}

// MARK: - App Shortcuts (discoverability in Shortcuts app)

struct VPNStatusShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SetVPNStatusIntent(),
            phrases: [
                "Set VPN status in \(.applicationName)"
            ],
            shortTitle: "Set VPN Status",
            systemImageName: "network"
        )
        AppShortcut(
            intent: ClearVPNIntent(),
            phrases: [
                "Clear VPN status in \(.applicationName)",
                "Stop VPN status in \(.applicationName)"
            ],
            shortTitle: "Clear VPN Status",
            systemImageName: "xmark.circle"
        )
    }
}
