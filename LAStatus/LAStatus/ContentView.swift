import SwiftUI
import Foundation

struct ContentView: View {
    @State private var message: String?
    @State private var selectedButton: SelectedButton?
    @State private var isApplying = false

    private enum SelectedButton {
        case corp
        case external
        case hide
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    actionsSection
                    if let message {
                        errorCallout(message)
                    }
                    shortcutsHelpCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Live Activity Status")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TEST")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
                .padding(.leading, 4)

            VStack(spacing: 18) {
                actionButton(
                    title: String(localized: "Show Live Activity: Corp VPN"),
                    isSelected: selectedButton == .corp,
                    systemImage: "key.shield.fill",
                    accentColor: .green
                ) {
                    Task {
                        await apply(
                            .active,
                            liveActivityTitle: "Corporate VPN",
                            dynamicIslandLabel: "Corp",
                            dynamicIslandIcon: "key.shield.fill",
                            elementsColor: .green,
                            selected: .corp
                        )
                    }
                }

                actionButton(
                    title: String(localized: "Show Live Activity: External VPN"),
                    isSelected: selectedButton == .external,
                    systemImage: "network",
                    accentColor: .blue
                ) {
                    Task {
                        await apply(
                            .active,
                            liveActivityTitle: "External VPN",
                            dynamicIslandLabel: "Ext",
                            dynamicIslandIcon: "network",
                            elementsColor: .blue,
                            selected: .external
                        )
                    }
                }

                actionButton(
                    title: String(localized: "Hide Live Activity"),
                    isSelected: selectedButton == .hide,
                    systemImage: "xmark.circle.fill",
                    accentColor: .red
                ) {
                    Task {
                        await apply(.none, selected: .hide)
                    }
                }
            }
        }
    }

    private func actionButton(
        title: String,
        isSelected: Bool,
        systemImage: String,
        accentColor: Color = .blue,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)

                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(18)
            .foregroundStyle(isSelected ? Color.white : accentColor)
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(isSelected ? accentColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(accentColor, lineWidth: 1.2)
            )
        }
        .buttonStyle(PressInButtonStyle())
        .animation(.easeInOut(duration: 0.25), value: isSelected)
        .disabled(isApplying)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("How to use with Shortcuts")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
            VStack(alignment: .leading, spacing: 8) {
                numberedTextRow(number: "1.", text: "Add action **Show Live Activity**.")
                numberedTextRow(number: "2.", text: "Set Live Activity **Title**.")
                numberedTextRow(number: "3.", text: "Set Dynamic Island **Label**.")
                numberedTextRow(number: "4.", text: "Optional: set Dynamic Island **Icon name** from **[SF Symbols](https://developer.apple.com/sf-symbols/)** (default: `network`).")
                numberedTextRow(number: "5.", text: "Optional: set **Color** (default: **White**).")
                Text("Use **Hide Live Activity** action to stop the Live Activity.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            }
        }
    }

    private func numberedTextRow(number: String, text: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 18, alignment: .leading)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @MainActor
    private func apply(
        _ newStatus: LAStatus,
        liveActivityTitle: String? = nil,
        dynamicIslandLabel: String? = nil,
        dynamicIslandIcon: String? = nil,
        elementsColor: LAStatusColor = .white,
        selected: SelectedButton? = nil
    ) async {
        guard !isApplying else { return }
        isApplying = true
        defer { isApplying = false }
        message = nil
        do {
            if newStatus == .none {
                try await LALiveActivityManager.shared.stop()
            } else {
                try await LALiveActivityManager.shared.startOrUpdate(
                    status: newStatus,
                    liveActivityTitle: liveActivityTitle,
                    dynamicIslandLabel: dynamicIslandLabel,
                    dynamicIslandIcon: dynamicIslandIcon,
                    elementsColor: elementsColor
                )
            }
            if let selected {
                self.selectedButton = selected
            }
        } catch {
            message = error.localizedDescription
        }
    }
}

private struct PressInButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .brightness(configuration.isPressed ? -0.03 : 0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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
