import SwiftUI

struct ContentView: View {
    @State private var message: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    actionsSection
                    if let message {
                        errorCallout(message)
                    }
                    shortcutsHelpCard
                    footerNote
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("VPN Status")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Live activity")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.leading, 4)

            VStack(spacing: 12) {
                actionButton(
                    title: "Set VPN status: Work"
                ) {
                    Task {
                        await apply(
                            .work,
                            liveActivityLabel: "Work VPN",
                            dynamicIslandLabel: "Work"
                        )
                    }
                }

                actionButton(
                    title: "Set VPN status: External"
                ) {
                    Task {
                        await apply(
                            .external,
                            liveActivityLabel: "External VPN",
                            dynamicIslandLabel: "External"
                        )
                    }
                }

                Button(role: .destructive) {
                    Task { await apply(.none) }
                } label: {
                    Label {
                        Text("Clear VPN status")
                    } icon: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    private func actionButton(
        title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                WorkVPNIcon(size: 22)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private func errorCallout(_ text: String) -> some View {
        Label {
            Text(text)
                .font(.footnote)
                .foregroundStyle(.primary)
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.orange.opacity(0.14))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.orange.opacity(0.35), lineWidth: 0.5)
        }
        .accessibilityElement(children: .combine)
    }

    private var shortcutsHelpCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to use with Shortcuts")
                .font(.subheadline.weight(.semibold))
            Text("1. Add action `Set VPN Status`.\n2. Set `Live Activity Label` (normal length text).\n3. Set `Dynamic Island Label` (short text up to 8 chars).")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Use `Clear VPN Status` to stop the Live Activity.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
    }

    private var footerNote: some View {
        Text("Status here and in Shortcuts is manual only — it does not reflect the system VPN connection.")
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .padding(.top, 8)
            .padding(.horizontal, 8)
    }

    private func apply(
        _ newStatus: VPNStatus,
        liveActivityLabel: String? = nil,
        dynamicIslandLabel: String? = nil
    ) async {
        message = nil
        do {
            if newStatus == .none {
                try await LiveActivityManager.shared.stop()
            } else {
                try await LiveActivityManager.shared.startOrUpdate(
                    status: newStatus,
                    liveActivityLabel: liveActivityLabel,
                    dynamicIslandLabel: dynamicIslandLabel
                )
            }
        } catch {
            message = error.localizedDescription
        }
    }
}

#Preview("Light") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
